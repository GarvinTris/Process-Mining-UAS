-- =============================================================================
-- 03_validation.sql  |  Validasi celonis_event_log_clean. Setiap baris: expected = 0 (atau nilai tertera)
-- Kolom status = PASS bila actual = expected. Tidak ada FAIL yang boleh tersisa sebelum export.
-- =============================================================================
CREATE OR REPLACE TABLE validation_results AS
WITH c AS (SELECT * FROM celonis_event_log_clean),
arr AS (SELECT case_id, MIN(activity_ready_time) a FROM c GROUP BY 1),
chk(id, dimensi, uji, expected, actual) AS (
  SELECT 'V01','Uniqueness','event_id duplikat', 0, COUNT(*) - COUNT(DISTINCT event_id) FROM c
  UNION ALL SELECT 'V02','Uniqueness','source_raw_row_id duplikat', 0, COUNT(*) - COUNT(DISTINCT source_raw_row_id) FROM c
  UNION ALL SELECT 'V03','Completeness','case_id/activity/timestamp NULL', 0, COUNT(*) FILTER (WHERE case_id IS NULL OR activity IS NULL OR "timestamp" IS NULL) FROM c
  UNION ALL SELECT 'V04','Completeness','start/end/ready NULL', 0, COUNT(*) FILTER (WHERE activity_start_time IS NULL OR activity_end_time IS NULL OR activity_ready_time IS NULL) FROM c
  UNION ALL SELECT 'V05','Validity','ready <= start < end dilanggar', 0, COUNT(*) FILTER (WHERE NOT (activity_ready_time <= activity_start_time AND activity_start_time < activity_end_time)) FROM c
  UNION ALL SELECT 'V06','Consistency','timestamp <> activity_end_time', 0, COUNT(*) FILTER (WHERE "timestamp" <> activity_end_time) FROM c
  UNION ALL SELECT 'V07','Accuracy','duration <> end-start (menit)', 0, COUNT(*) FILTER (WHERE date_diff('minute',activity_start_time,activity_end_time) <> activity_duration_minutes) FROM c
  UNION ALL SELECT 'V08','Accuracy','waiting <> start-ready (menit)', 0, COUNT(*) FILTER (WHERE date_diff('minute',activity_ready_time,activity_start_time) <> waiting_time_minutes) FROM c
  UNION ALL SELECT 'V09','Accuracy','case_elapsed <> end - arrival case', 0, COUNT(*) FILTER (WHERE date_diff('minute',arr.a,c.activity_end_time) <> c.case_elapsed_time_minutes) FROM c JOIN arr USING (case_id)
  UNION ALL SELECT 'V10','Validity','SLA flag <> (wait+duration > SLA)', 0, COUNT(*) FILTER (WHERE sla_violation <> ((waiting_time_minutes+activity_duration_minutes) > activity_sla_minutes)) FROM c
  UNION ALL SELECT 'V11','Finance','total <> labor+material+equipment+overhead', 0, COUNT(*) FILTER (WHERE ABS(activity_total_cost-(labor_cost+material_cost+equipment_cost+overhead_cost))>0.01) FROM c
  UNION ALL SELECT 'V12','Finance','profit <> revenue - total', 0, COUNT(*) FILTER (WHERE ABS(profit_contribution-(revenue_allocated-activity_total_cost))>0.01) FROM c
  UNION ALL SELECT 'V13','Finance','revenue >0 selain Vehicle Delivered', 0, COUNT(*) FILTER (WHERE revenue_allocated>0 AND activity<>'Vehicle Delivered') FROM c
  UNION ALL SELECT 'V14','Finance','revenue <0 selain Authorized Sales Credit', 0, COUNT(*) FILTER (WHERE revenue_allocated<0 AND activity<>'Authorized Sales Credit') FROM c
  UNION ALL SELECT 'V15','Finance','case dengan >1 pengakuan revenue positif', 0, (SELECT COUNT(*) FROM (SELECT case_id FROM c WHERE revenue_allocated>0 GROUP BY 1 HAVING COUNT(*)>1))
  UNION ALL SELECT 'V16','Finance','Vehicle Delivered tanpa revenue >0', 0, COUNT(*) FILTER (WHERE activity='Vehicle Delivered' AND revenue_allocated<=0) FROM c
  UNION ALL SELECT 'V17','Finance','Invoice/Payment dengan revenue <> 0', 0, COUNT(*) FILTER (WHERE activity IN ('Sales Invoice Posted','Customer Payment Applied') AND revenue_allocated<>0) FROM c
  UNION ALL SELECT 'V18','Finance','currency <> EUR', 0, COUNT(*) FILTER (WHERE currency<>'EUR') FROM c
  UNION ALL SELECT 'V19','Ref. integrity','case_id tidak di case_master', 0, COUNT(*) FILTER (WHERE case_id NOT IN (SELECT case_id FROM case_master)) FROM c
  UNION ALL SELECT 'V20','Ref. integrity','employee_id tidak di employee_master', 0, COUNT(*) FILTER (WHERE employee_id NOT IN (SELECT employee_id FROM employee_master)) FROM c
  UNION ALL SELECT 'V21','Ref. integrity','resource_id <> employee_master / NULL', 0, COUNT(*) FILTER (WHERE resource_id IS NULL OR resource_id NOT IN (SELECT resource_id FROM employee_master WHERE employee_id=c.employee_id)) FROM c
  UNION ALL SELECT 'V22','Ref. integrity','facility_id orphan', 0, COUNT(*) FILTER (WHERE facility_id IS NOT NULL AND facility_id NOT IN (SELECT facility_id FROM facility_master)) FROM c
  UNION ALL SELECT 'V23','Ref. integrity','facility tidak sesuai tipe di activity_catalog / hilang padahal wajib', 0,
         COUNT(*) FILTER (WHERE (a.facility_type IS NULL) <> (c.facility_id IS NULL) OR (c.facility_id IS NOT NULL AND f.facility_type<>a.facility_type))
         FROM c JOIN activity_catalog a USING (activity) LEFT JOIN facility_master f ON f.facility_id=c.facility_id
  UNION ALL SELECT 'V24','Ref. integrity','role/department <> activity_catalog', 0, COUNT(*) FILTER (WHERE c.employee_role<>a.required_role OR c.department_id<>a.department_id) FROM c JOIN activity_catalog a USING (activity)
  UNION ALL SELECT 'V25','Ref. integrity','model/trim/vehicle <> case_master', 0, COUNT(*) FILTER (WHERE (c.model_name,c.trim_grade,c.vehicle_id,c.production_order_id) <> (m.model_name,m.trim_grade,m.vehicle_id,m.production_order_id)) FROM c JOIN case_master m USING (case_id)
  UNION ALL SELECT 'V26','Ref. integrity','activity di luar catalog', 0, COUNT(*) FILTER (WHERE activity NOT IN (SELECT activity FROM activity_catalog)) FROM c
  UNION ALL SELECT 'V27','Capacity','overlap pada facility_id yang sama (kapasitas 1)', 0,
         (SELECT COUNT(*) FROM c a JOIN c b ON a.facility_id=b.facility_id AND a.event_id<b.event_id AND a.activity_start_time<b.activity_end_time AND b.activity_start_time<a.activity_end_time)
  UNION ALL SELECT 'V28','Capacity','overlap pada employee duty-slot yang sama (kapasitas 1)', 0,
         (SELECT COUNT(*) FROM c a JOIN c b ON a.employee_id=b.employee_id AND a.event_id<b.event_id AND a.activity_start_time<b.activity_end_time AND b.activity_start_time<a.activity_end_time)
  UNION ALL SELECT 'V29','Case path','case tanpa Production Order Received di awal', 0,
         (SELECT COUNT(*) FROM (SELECT case_id, ARG_MIN(activity, (activity_end_time, activity_start_time, event_id)) f FROM c GROUP BY 1) WHERE f<>'Production Order Received')
  UNION ALL SELECT 'V30','Case path','case tanpa Production Order Closed di akhir', 0,
         (SELECT COUNT(*) FROM (SELECT case_id, ARG_MAX(activity, (activity_end_time, activity_start_time, event_id)) l FROM c GROUP BY 1) WHERE l<>'Production Order Closed')
  UNION ALL SELECT 'V31','Case path','case dengan >1 outcome (Delivered/Scrapped/Cancelled)', 0,
         (SELECT COUNT(*) FROM (SELECT case_id FROM c WHERE activity IN ('Vehicle Delivered','Production Scrapped','Order Cancelled') GROUP BY 1 HAVING COUNT(*)>1))
  UNION ALL SELECT 'V32','Case path','jumlah case (harus = case_master)', (SELECT COUNT(*) FROM case_master), COUNT(DISTINCT case_id) FROM c
  UNION ALL SELECT 'V33','Preservation','Dynamic Road Test berulang (rework sah) dipertahankan', 22,
         (SELECT COUNT(*) FROM (SELECT case_id FROM c WHERE activity='Dynamic Road Test' GROUP BY 1 HAVING COUNT(*)>1))
  UNION ALL SELECT 'V34','Preservation','Paint Rework Completed dipertahankan', 26, COUNT(*) FILTER (WHERE activity='Paint Rework Completed') FROM c
  UNION ALL SELECT 'V35','Preservation','Supplier Shortage Resolved dipertahankan', 38, COUNT(*) FILTER (WHERE activity='Supplier Shortage Resolved') FROM c
  UNION ALL SELECT 'V36','Control','quality-gate bypass (Delivered tanpa Final Quality Gate) - TEMUAN KENDALI, bukan error', 4, (SELECT COUNT(DISTINCT case_id) FROM c WHERE qc_bypass_flag)
)
SELECT *, CASE WHEN expected = actual THEN 'PASS' ELSE 'FAIL' END AS status FROM chk;

SELECT * FROM validation_results ORDER BY id;
SELECT status, COUNT(*) FROM validation_results GROUP BY 1;

-- Rekonsiliasi raw -> clean
SELECT (SELECT COUNT(*) FROM raw_events) AS raw_rows,
       (SELECT COUNT(*) FROM dq_removed_duplicates) AS duplicates_removed,
       (SELECT COUNT(*) FROM celonis_event_log_clean) AS clean_rows,
       (SELECT COUNT(*) FROM raw_events) - (SELECT COUNT(*) FROM dq_removed_duplicates) - (SELECT COUNT(*) FROM celonis_event_log_clean) AS selisih_harus_0;
