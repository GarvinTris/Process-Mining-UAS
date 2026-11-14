-- =============================================================================
-- 05_celonis_export.sql  |  Export deterministik + re-import audit
-- Mapping Celonis: Case = case_id | Activity = activity | Timestamp = "timestamp" (completion time)
-- (Opsional Celonis: Start Time = activity_start_time untuk Performance/Resource analysis)
-- Format timestamp: YYYY-MM-DD HH:MM:SS (UTC); file UTF-8 (default DuckDB). Jalankan 03_validation.sql dulu: tidak boleh ada FAIL.
-- =============================================================================
COPY (
  SELECT * EXCLUDE (source_raw_row_id, dq_repair_note), source_raw_row_id, dq_repair_note
  FROM celonis_event_log_clean
  ORDER BY case_id, "timestamp", activity_start_time, event_id
) TO '01_DATA/cleaned/celonis_event_log_clean.csv' (HEADER TRUE, DELIMITER ',');

-- Re-import audit (baca ulang file akhir)
CREATE OR REPLACE TABLE reimport AS
SELECT * FROM read_csv('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);

SELECT COUNT(*) AS rows_reimported,
       COUNT(DISTINCT event_id) AS unique_events,
       COUNT(DISTINCT case_id)  AS cases,
       COUNT(*) FILTER (WHERE case_id IS NULL OR activity IS NULL OR "timestamp" IS NULL) AS invalid_core_fields,
       typeof(ANY_VALUE("timestamp")) AS timestamp_type,
       typeof(ANY_VALUE(activity_total_cost)) AS cost_type,
       ROUND(SUM(revenue_allocated),2) AS revenue,
       ROUND(SUM(activity_total_cost),2) AS cost,
       ROUND(SUM(profit_contribution),2) AS contribution
FROM reimport;
-- Determinisme: urutan file = urutan ORDER BY
SELECT COUNT(*) AS out_of_order_rows FROM (
  SELECT case_id, "timestamp", LAG(case_id) OVER () p_case, LAG("timestamp") OVER () p_ts FROM reimport)
WHERE case_id = p_case AND "timestamp" < p_ts;
