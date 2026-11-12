-- Activate only once you have built and validated your cleaned event table.
-- COPY (SELECT * FROM celonis_event_log_clean ORDER BY case_id,timestamp,event_id)
-- TO 'exports/celonis_event_log_clean.csv' (HEADER TRUE,DELIMITER ',');
SELECT 'Validate cleaning, then enable the export command above' AS next_action;
