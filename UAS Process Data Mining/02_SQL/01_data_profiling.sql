-- Starter profiling queries. Extend with master-key checks, format counts and an assessment report.
SELECT COUNT(*) AS raw_rows,COUNT(DISTINCT TRIM(case_id)) AS source_cases FROM raw_events;
SELECT activity,COUNT(*) AS occurrences FROM raw_events GROUP BY activity ORDER BY occurrences DESC;
SELECT UPPER(TRIM(event_id)) AS normalized_event_id,COUNT(*) AS repeated_sources
FROM raw_events GROUP BY normalized_event_id HAVING COUNT(*)>1 ORDER BY repeated_sources DESC;
SELECT department,COUNT(*) AS event_count FROM raw_events GROUP BY department ORDER BY event_count DESC;
SELECT COUNT(*) AS blank_employee_ids FROM raw_events WHERE employee_id IS NULL OR TRIM(employee_id)='';
-- TODO: identify timestamp variants, formatting anomalies, relational issues, and suspicious numeric values.
