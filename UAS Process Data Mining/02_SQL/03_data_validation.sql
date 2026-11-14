-- Enhance these starting checks for completeness, uniqueness, validity and referential integrity.
SELECT COUNT(*) AS source_rows FROM raw_events;
SELECT COUNT(*) AS no_case_id FROM raw_events WHERE case_id IS NULL OR TRIM(case_id)='';
SELECT COUNT(*) AS no_activity FROM raw_events WHERE activity IS NULL OR TRIM(activity)='';
-- TODO: test correct event/case relationships, queueing, exclusive machine use and financial identities.
-- TODO: preserve legitimate rework and overlapping process activities; verify sale recognition once per delivered case.
