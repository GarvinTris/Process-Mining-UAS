-- =============================================================================
-- 02_cleaning.sql  |  Raw -> celonis_event_log_clean  (semua perbaikan terdokumentasi)
-- Urutan: (1) normalisasi & parsing  (2) perbaikan waktu  (3) dedup  (4) restorasi master
--         (5) tabel akhir + audit trail.  raw_events TIDAK diubah.
-- Keputusan kunci:
--  * Format tanggal slash di data = MONTH-FIRST (M/D/YYYY H:MM). Ini BERTENTANGAN dengan
--    data_dictionary (day-first) - dibuktikan di 01_profiling.sql (P05). Lihat data_quality_report.md.
--  * Duplikat sumber (event_id sama setelah TRIM+UPPER) dibuang, baris pertama (raw_row_id terkecil) dipertahankan.
--    Semua duplikat identik pada case, activity, end time dan biaya -> tidak ada konflik.
--  * Rework sah (Dynamic Road Test berulang, Paint Rework, Vehicle Defect Rectified) DIPERTAHANKAN.
--  * Nilai kosong yang sah (facility_id tanpa mesin, exception_type tanpa exception) tetap NULL.
-- =============================================================================

-- ---------- Langkah 1: staging - normalisasi teks, tipe, boolean, uang -------
CREATE OR REPLACE TABLE stg_events AS
WITH p AS (
  SELECT
    raw_row_id,
    UPPER(TRIM(event_id))   AS event_id,
    UPPER(TRIM(case_id))    AS case_id,
    TRIM(activity)          AS activity_raw,
    -- timestamp: coba kanonik dulu, lalu varian slash (month-first terbukti), terakhir day-first sbg fallback
    try_strptime(activity_start_time, ['%Y-%m-%d %H:%M:%S','%Y/%m/%d %H:%M:%S','%m/%d/%Y %H:%M','%d/%m/%Y %H:%M']) AS t_start,
    try_strptime(activity_end_time,   ['%Y-%m-%d %H:%M:%S','%Y/%m/%d %H:%M:%S','%m/%d/%Y %H:%M','%d/%m/%Y %H:%M']) AS t_end,
    try_strptime("timestamp",         ['%Y-%m-%d %H:%M:%S','%Y/%m/%d %H:%M:%S','%m/%d/%Y %H:%M','%d/%m/%Y %H:%M']) AS t_ts,
    try_strptime(activity_ready_time, ['%Y-%m-%d %H:%M:%S','%Y/%m/%d %H:%M:%S','%m/%d/%Y %H:%M','%d/%m/%Y %H:%M']) AS t_ready,
    UPPER(TRIM(employee_id)) AS employee_id,
    UPPER(NULLIF(TRIM(resource_id),'')) AS resource_id,
    UPPER(NULLIF(TRIM(facility_id),'')) AS facility_id,
    TRY_CAST(activity_duration_minutes  AS DECIMAL(18,2)) AS activity_duration_minutes,
    TRY_CAST(waiting_time_minutes       AS DECIMAL(18,2)) AS waiting_time_minutes,
    TRY_CAST(case_elapsed_time_minutes  AS DECIMAL(18,2)) AS case_elapsed_time_minutes,
    TRY_CAST(activity_sla_minutes       AS INTEGER)       AS activity_sla_minutes,
    -- boolean: TRUE/Y/YES/1 -> true ; FALSE/N/NO/0 -> false ; lainnya -> NULL (akan terdeteksi validasi)
    CASE WHEN UPPER(TRIM(sla_violation))    IN ('TRUE','Y','YES','1') THEN TRUE WHEN UPPER(TRIM(sla_violation))    IN ('FALSE','N','NO','0') THEN FALSE END AS sla_violation,
    CASE WHEN UPPER(TRIM(rework_flag))      IN ('TRUE','Y','YES','1') THEN TRUE WHEN UPPER(TRIM(rework_flag))      IN ('FALSE','N','NO','0') THEN FALSE END AS rework_flag,
    CASE WHEN UPPER(TRIM(exception_flag))   IN ('TRUE','Y','YES','1') THEN TRUE WHEN UPPER(TRIM(exception_flag))   IN ('FALSE','N','NO','0') THEN FALSE END AS exception_flag,
    -- uang: buang simbol/prefiks (EUR, EUR , euro sign) lalu cast; TIDAK mengganti nilai invalid dengan 0
    TRY_CAST(regexp_replace(labor_cost,          '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS labor_cost,
    TRY_CAST(regexp_replace(material_cost,       '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS material_cost,
    TRY_CAST(regexp_replace(equipment_cost,      '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS equipment_cost,
    TRY_CAST(regexp_replace(overhead_cost,       '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS overhead_cost,
    TRY_CAST(regexp_replace(activity_total_cost, '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS activity_total_cost,
    TRY_CAST(regexp_replace(revenue_allocated,   '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS revenue_allocated,
    TRY_CAST(regexp_replace(profit_contribution, '[^0-9.\-]','','g') AS DECIMAL(18,2)) AS profit_contribution,
    UPPER(TRIM(currency)) AS currency,
    NULLIF(TRIM(exception_type),'') AS exception_type,
    (regexp_matches(material_cost||revenue_allocated||profit_contribution||labor_cost||equipment_cost||overhead_cost||activity_total_cost,'[^0-9.\-]')) AS had_currency_symbol,
    (event_id <> UPPER(TRIM(event_id)) OR case_id <> UPPER(TRIM(case_id)) OR employee_id <> UPPER(TRIM(employee_id))
       OR COALESCE(resource_id,'') <> UPPER(TRIM(COALESCE(resource_id,''))) OR TRIM(employee_role) <> employee_role) AS had_id_padding_or_case
  FROM raw_events)
SELECT p.*, c.activity AS activity
FROM p JOIN activity_catalog c ON LOWER(c.activity) = LOWER(p.activity_raw);   -- activity kanonik dari catalog (case-insensitive)

-- ---------- Langkah 2: perbaikan waktu ---------------------------------------
-- Arrival tiap case = ready time paling awal dari baris yang valid.
-- Terbukti: case_elapsed_time = end_time - arrival (5.746/5.749 baris cocok persis; 3 sisanya = baris start/end tertukar).
CREATE OR REPLACE TABLE case_arrival AS
SELECT case_id, MIN(t_ready) AS arrival_time FROM stg_events WHERE t_ready IS NOT NULL GROUP BY case_id;

CREATE OR REPLACE TABLE stg_time_fixed AS
SELECT s.*,
  CASE
    WHEN s.t_end IS NULL OR s.t_start IS NULL OR s.t_ready IS NULL                     THEN 'RECONSTRUCTED_FROM_CASE_ELAPSED'
    WHEN s.t_start >= s.t_end                                                         THEN 'SWAPPED_START_END'
    WHEN s.t_ts <> s.t_end                                                            THEN 'TIMESTAMP_SET_TO_END'
  END AS time_fix
FROM stg_events s;

CREATE OR REPLACE TABLE stg_time AS
SELECT f.* EXCLUDE (t_start, t_end, t_ts, t_ready),
  CASE f.time_fix
    WHEN 'RECONSTRUCTED_FROM_CASE_ELAPSED' THEN a.arrival_time + to_minutes(f.case_elapsed_time_minutes::INT) - to_minutes(f.activity_duration_minutes::INT)
    WHEN 'SWAPPED_START_END'               THEN f.t_end
    ELSE f.t_start END AS activity_start_time,
  CASE f.time_fix
    WHEN 'RECONSTRUCTED_FROM_CASE_ELAPSED' THEN a.arrival_time + to_minutes(f.case_elapsed_time_minutes::INT)
    WHEN 'SWAPPED_START_END'               THEN f.t_start
    ELSE f.t_end END AS activity_end_time,
  CASE f.time_fix
    WHEN 'RECONSTRUCTED_FROM_CASE_ELAPSED' THEN a.arrival_time + to_minutes(f.case_elapsed_time_minutes::INT) - to_minutes(f.activity_duration_minutes::INT) - to_minutes(f.waiting_time_minutes::INT)
    ELSE f.t_ready END AS activity_ready_time
FROM stg_time_fixed f LEFT JOIN case_arrival a USING (case_id);

-- ---------- Langkah 3: deduplikasi source duplicate ---------------------------
CREATE OR REPLACE TABLE dq_removed_duplicates AS
SELECT raw_row_id AS removed_raw_row_id, event_id, case_id, activity,
       FIRST_VALUE(raw_row_id) OVER (PARTITION BY event_id ORDER BY raw_row_id) AS kept_raw_row_id,
       'SOURCE_DUPLICATE: event_id sama setelah TRIM+UPPER; isi bisnis identik' AS reason
FROM stg_time
QUALIFY ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY raw_row_id) > 1;

CREATE OR REPLACE TABLE stg_dedup AS
SELECT * FROM stg_time
QUALIFY ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY raw_row_id) = 1;

-- ---------- Langkah 4 + 5: restorasi dari master & tabel akhir ----------------
CREATE OR REPLACE TABLE celonis_event_log_clean AS
SELECT
  s.event_id,
  s.case_id,
  s.activity,
  s.activity_start_time,
  s.activity_end_time,
  s.activity_end_time                    AS "timestamp",         -- = activity_end_time (data dictionary)
  s.activity_ready_time,
  e.department_id,                                               -- dari employee_master (authoritative)
  d.department,
  s.employee_id,
  e.employee_role,
  e.resource_id,                                                 -- memulihkan 2 resource_id kosong (EMP-052)
  rm.resource_type,
  d.organizational_unit,
  s.facility_id,                                                 -- NULL tetap NULL (activity tanpa mesin)
  s.activity_duration_minutes,
  s.waiting_time_minutes,
  s.case_elapsed_time_minutes,
  s.activity_sla_minutes,
  s.sla_violation,
  s.rework_flag,
  'Completed'::VARCHAR                   AS activity_status,
  s.labor_cost, s.material_cost, s.equipment_cost, s.overhead_cost,
  s.activity_total_cost, s.revenue_allocated, s.profit_contribution,
  s.currency,
  cm.case_type,                                                  -- master memulihkan 6 placeholder (N/A, NaN, -, NULL)
  r.case_priority, r.case_complexity, cm.location,
  cm.production_order_id, cm.vehicle_id, cm.model_name, cm.trim_grade,
  s.exception_flag, s.exception_type,
  s.raw_row_id                           AS source_raw_row_id,
  NULLIF(concat_ws('|',
    CASE WHEN s.had_currency_symbol THEN 'MONEY_SYMBOL_STRIPPED' END,
    CASE WHEN s.had_id_padding_or_case THEN 'ID_TRIM_UPPER' END,
    CASE WHEN s.activity_raw <> s.activity THEN 'ACTIVITY_CASE_FIXED' END,
    s.time_fix,
    CASE WHEN ro.raw_case_type IN ('N/A','NaN','-','NULL') OR ro.raw_case_type IS NULL THEN 'CASE_TYPE_RESTORED_FROM_MASTER' END,
    CASE WHEN ro.raw_resource IS NULL OR TRIM(ro.raw_resource)='' THEN 'RESOURCE_RESTORED_FROM_MASTER' END,
    CASE WHEN ro.raw_dept <> d.department THEN 'DEPARTMENT_NAME_STANDARDIZED' END,
    CASE WHEN ro.raw_flags_noncanon THEN 'BOOLEAN_STANDARDIZED' END
  ), '') AS dq_repair_note
FROM stg_dedup s
JOIN employee_master   e  ON e.employee_id = s.employee_id
JOIN resource_master   rm ON rm.resource_id = e.resource_id
JOIN department_master d  ON d.department_id = e.department_id
JOIN case_master       cm ON cm.case_id = s.case_id
JOIN (SELECT UPPER(TRIM(case_id)) case_id, ANY_VALUE(TRIM(case_priority)) case_priority, ANY_VALUE(TRIM(case_complexity)) case_complexity
      FROM raw_events GROUP BY 1) r ON r.case_id = s.case_id
JOIN (SELECT raw_row_id, case_type raw_case_type, resource_id raw_resource, TRIM(department) raw_dept,
             (UPPER(TRIM(sla_violation)) NOT IN ('TRUE','FALSE') OR UPPER(TRIM(rework_flag)) NOT IN ('TRUE','FALSE')
              OR UPPER(TRIM(exception_flag)) NOT IN ('TRUE','FALSE')) raw_flags_noncanon FROM raw_events) ro ON ro.raw_row_id = s.raw_row_id;

-- Flag kendali: Vehicle Delivered tanpa Final Quality Gate Approved (quality-gate bypass, nyata - BUKAN error data)
ALTER TABLE celonis_event_log_clean ADD COLUMN qc_bypass_flag BOOLEAN;
UPDATE celonis_event_log_clean c SET qc_bypass_flag =
  c.case_id IN (SELECT case_id FROM celonis_event_log_clean WHERE activity = 'Vehicle Delivered')
  AND c.case_id NOT IN (SELECT case_id FROM celonis_event_log_clean WHERE activity = 'Final Quality Gate Approved');

-- ---------- Audit trail -------------------------------------------------------
CREATE OR REPLACE TABLE dq_repair_log AS
SELECT source_raw_row_id, event_id, case_id, activity, dq_repair_note FROM celonis_event_log_clean WHERE dq_repair_note IS NOT NULL;

SELECT 'raw rows' AS metric, COUNT(*) AS n FROM raw_events
UNION ALL SELECT 'duplicates removed', COUNT(*) FROM dq_removed_duplicates
UNION ALL SELECT 'clean rows', COUNT(*) FROM celonis_event_log_clean
UNION ALL SELECT 'rows with >=1 repair', COUNT(*) FROM dq_repair_log
UNION ALL SELECT 'quarantined (irrecoverable)', 0;
SELECT UNNEST(string_split(dq_repair_note,'|')) AS repair_type, COUNT(*) AS n FROM dq_repair_log GROUP BY 1 ORDER BY 2 DESC;
