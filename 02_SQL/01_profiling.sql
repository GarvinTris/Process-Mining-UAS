-- =============================================================================
-- 01_profiling.sql  |  Profiling raw_events (read-only, tidak mengubah data)
-- Dimensi DQ: Completeness, Uniqueness, Consistency, Validity, Accuracy vs master,
-- Referential integrity.  Hasil ringkas -> 01_DATA/validation/data_quality_report.md
-- =============================================================================

-- P01 Volume dasar ------------------------------------------------------------
SELECT COUNT(*)                                   AS raw_rows,
       COUNT(DISTINCT raw_row_id)                 AS unique_raw_row_id,
       COUNT(DISTINCT event_id)                   AS distinct_event_id_as_is,
       COUNT(DISTINCT UPPER(TRIM(event_id)))      AS distinct_event_id_normalized,
       COUNT(DISTINCT case_id)                    AS distinct_case_as_is,
       COUNT(DISTINCT UPPER(TRIM(case_id)))       AS distinct_case_normalized
FROM raw_events;

-- P02 Activity: variasi casing (harus 35 activity di catalog) -----------------
SELECT activity, COUNT(*) AS n,
       activity IN (SELECT activity FROM activity_catalog) AS exact_in_catalog,
       LOWER(activity) IN (SELECT LOWER(activity) FROM activity_catalog) AS in_catalog_ci
FROM raw_events GROUP BY activity ORDER BY exact_in_catalog, n DESC;

-- P03 Department & role: ID huruf kecil, nama non-kanonik, role dengan spasi ---
SELECT department_id, department, COUNT(*) n FROM raw_events
GROUP BY ALL HAVING department_id <> UPPER(TRIM(department_id))
   OR department NOT IN (SELECT department FROM department_master);
SELECT employee_role, COUNT(*) n FROM raw_events GROUP BY 1 ORDER BY 2 DESC;

-- P04 Uniqueness: event_id berulang setelah normalisasi (TRIM+UPPER) ----------
SELECT n_rows, COUNT(*) AS n_event_id FROM (
  SELECT UPPER(TRIM(event_id)) e, COUNT(*) n_rows FROM raw_events GROUP BY 1)
GROUP BY n_rows ORDER BY n_rows;
-- Apakah duplikat identik (source duplicate) atau berbeda isi (konflik)?
WITH g AS (
  SELECT UPPER(TRIM(event_id)) e,
         COUNT(DISTINCT UPPER(TRIM(case_id)))   n_case,
         COUNT(DISTINCT LOWER(TRIM(activity)))  n_act,
         COUNT(DISTINCT activity_end_time)      n_end,
         COUNT(DISTINCT activity_total_cost)    n_cost
  FROM raw_events GROUP BY 1 HAVING COUNT(*) > 1)
SELECT COUNT(*) AS dup_groups, SUM((n_case>1)::INT) AS case_conflict, SUM((n_act>1)::INT) AS act_conflict,
       SUM((n_end>1)::INT) AS end_conflict, SUM((n_cost>1)::INT) AS cost_conflict FROM g;
-- case_id+activity berulang BUKAN otomatis duplikat (rework Dynamic Road Test)
SELECT activity, COUNT(*) AS cases_with_repeat FROM (
  SELECT UPPER(TRIM(case_id)) c, activity, COUNT(DISTINCT UPPER(TRIM(event_id))) n
  FROM raw_events WHERE activity = 'Dynamic Road Test' GROUP BY 1,2 HAVING n > 1) GROUP BY 1;

-- P05 Timestamp: pola string & bukti format (month-first vs day-first) --------
SELECT regexp_replace(regexp_replace(activity_end_time,'[0-9]','9','g'),'[A-Za-z]','a','g') AS pola,
       COUNT(*) n, MIN(activity_end_time) AS contoh
FROM raw_events GROUP BY 1 ORDER BY 2 DESC;
-- Bukti: tidak ada komponen pertama >12, banyak komponen kedua >12 => MONTH-FIRST (M/D/YYYY)
SELECT COUNT(*) FILTER (WHERE TRY_CAST(split_part(activity_end_time,'/',1) AS INT) > 12) AS first_part_gt12,
       COUNT(*) FILTER (WHERE TRY_CAST(split_part(activity_end_time,'/',2) AS INT) > 12) AS second_part_gt12
FROM raw_events;
-- Bukti kedua: interpretasi mana yang cocok dengan activity_duration_minutes?
SELECT COUNT(*) FILTER (WHERE date_diff('minute', try_strptime(activity_start_time,'%m/%d/%Y %H:%M'),
                                                  try_strptime(activity_end_time,  '%m/%d/%Y %H:%M')) = activity_duration_minutes::INT) AS match_month_first,
       COUNT(*) FILTER (WHERE date_diff('minute', try_strptime(activity_start_time,'%d/%m/%Y %H:%M'),
                                                  try_strptime(activity_end_time,  '%d/%m/%Y %H:%M')) = activity_duration_minutes::INT) AS match_day_first
FROM raw_events;
-- Nilai bukan-waktu
SELECT raw_row_id, case_id, activity, activity_start_time FROM raw_events
WHERE try_strptime(activity_start_time,'%m/%d/%Y %H:%M') IS NULL;
-- Start > End (urutan tertukar) dan timestamp <> end
SELECT raw_row_id, case_id, activity, activity_start_time, activity_end_time, "timestamp", activity_duration_minutes
FROM raw_events
WHERE try_strptime(activity_start_time,'%m/%d/%Y %H:%M') >= try_strptime(activity_end_time,'%m/%d/%Y %H:%M')
   OR try_strptime("timestamp",'%m/%d/%Y %H:%M') <> try_strptime(activity_end_time,'%m/%d/%Y %H:%M');

-- P06 Money: simbol/prefiks mata uang (EUR, €) --------------------------------
SELECT raw_row_id, material_cost, revenue_allocated, profit_contribution FROM raw_events
WHERE material_cost ~ '[^0-9.\-]' OR revenue_allocated ~ '[^0-9.\-]' OR profit_contribution ~ '[^0-9.\-]'
   OR labor_cost ~ '[^0-9.\-]' OR equipment_cost ~ '[^0-9.\-]' OR overhead_cost ~ '[^0-9.\-]' OR activity_total_cost ~ '[^0-9.\-]';

-- P07 Boolean: representasi tak kanonik (N, Y, 1/0, dst.) ---------------------
SELECT 'sla_violation' kolom, sla_violation nilai, COUNT(*) n FROM raw_events GROUP BY 2
UNION ALL SELECT 'rework_flag',    rework_flag,    COUNT(*) FROM raw_events GROUP BY 2
UNION ALL SELECT 'exception_flag', exception_flag, COUNT(*) FROM raw_events GROUP BY 2
ORDER BY 1, 3 DESC;

-- P08 Completeness: blank/NULL per kolom, + placeholder (N/A, NaN, -, NULL) ---
SELECT 'resource_id NULL'  AS issue, COUNT(*) n FROM raw_events WHERE resource_id IS NULL OR TRIM(resource_id)=''
UNION ALL SELECT 'facility_id NULL (valid utk activity tanpa mesin)', COUNT(*) FROM raw_events WHERE facility_id IS NULL
UNION ALL SELECT 'exception_type NULL (valid bila tanpa exception)',   COUNT(*) FROM raw_events WHERE exception_type IS NULL
UNION ALL SELECT 'case_type placeholder', COUNT(*) FROM raw_events WHERE case_type IS NULL OR case_type IN ('N/A','NaN','-','NULL','')
UNION ALL SELECT 'employee_id NULL', COUNT(*) FROM raw_events WHERE employee_id IS NULL OR TRIM(employee_id)='';

-- P09 Padding/casing pada identifier ------------------------------------------
SELECT 'event_id' kolom, COUNT(*) FILTER (WHERE event_id<>UPPER(TRIM(event_id))) n FROM raw_events
UNION ALL SELECT 'case_id',     COUNT(*) FILTER (WHERE case_id<>UPPER(TRIM(case_id))) FROM raw_events
UNION ALL SELECT 'employee_id', COUNT(*) FILTER (WHERE employee_id<>UPPER(TRIM(employee_id))) FROM raw_events
UNION ALL SELECT 'resource_id', COUNT(*) FILTER (WHERE resource_id<>UPPER(TRIM(resource_id))) FROM raw_events;

-- P10 Referential integrity vs master (setelah normalisasi) -------------------
SELECT 'case_id tidak ada di case_master' chk, COUNT(*) n FROM raw_events r
  WHERE UPPER(TRIM(case_id)) NOT IN (SELECT case_id FROM case_master)
UNION ALL SELECT 'employee_id orphan', COUNT(*) FROM raw_events
  WHERE UPPER(TRIM(employee_id)) NOT IN (SELECT employee_id FROM employee_master)
UNION ALL SELECT 'facility_id orphan', COUNT(*) FROM raw_events
  WHERE facility_id IS NOT NULL AND UPPER(TRIM(facility_id)) NOT IN (SELECT facility_id FROM facility_master)
UNION ALL SELECT 'resource_id orphan', COUNT(*) FROM raw_events
  WHERE resource_id IS NOT NULL AND UPPER(TRIM(resource_id)) NOT IN (SELECT resource_id FROM resource_master)
UNION ALL SELECT 'department_id orphan', COUNT(*) FROM raw_events
  WHERE UPPER(TRIM(department_id)) NOT IN (SELECT department_id FROM department_master)
UNION ALL SELECT 'model_name orphan', COUNT(*) FROM raw_events
  WHERE TRIM(model_name) NOT IN (SELECT model_name FROM vehicle_model_master)
UNION ALL SELECT 'trim_grade orphan', COUNT(*) FROM raw_events
  WHERE TRIM(trim_grade) NOT IN (SELECT trim_grade FROM trim_grade_master);

-- P11 Accuracy vs master: employee -> resource -> department -> role ----------
SELECT COUNT(*) FILTER (WHERE UPPER(TRIM(r.resource_id)) <> e.resource_id)    AS resource_mismatch,
       COUNT(*) FILTER (WHERE r.resource_id IS NULL)                          AS resource_missing,
       COUNT(*) FILTER (WHERE UPPER(TRIM(r.department_id)) <> e.department_id) AS dept_id_mismatch,
       COUNT(*) FILTER (WHERE TRIM(r.employee_role) <> e.employee_role)        AS role_mismatch
FROM raw_events r JOIN employee_master e ON e.employee_id = UPPER(TRIM(r.employee_id));

-- P12 Distribusi biaya/durasi (outlier bukan otomatis error) ------------------
SELECT activity, COUNT(*) n,
       MIN(TRY_CAST(regexp_replace(activity_total_cost,'[^0-9.\-]','','g') AS DECIMAL(18,2))) AS min_cost,
       quantile_cont(TRY_CAST(regexp_replace(activity_total_cost,'[^0-9.\-]','','g') AS DECIMAL(18,2)), 0.5) AS median_cost,
       MAX(TRY_CAST(regexp_replace(activity_total_cost,'[^0-9.\-]','','g') AS DECIMAL(18,2))) AS max_cost
FROM raw_events GROUP BY 1 ORDER BY max_cost DESC LIMIT 10;
