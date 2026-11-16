-- Student work area: expand with your own documented SQL repairs; no answers supplied.
CREATE OR REPLACE VIEW cleaning_workspace AS SELECT * FROM raw_events;
SELECT COUNT(*) AS work_records FROM cleaning_workspace;
-- TODO: normalize event_id, apply safe deduplication, preserve unique rework executions.
-- TODO: load clean masters and recover correct activity and resource mappings.
-- TODO: parse day-first timestamps and MYR amounts; validate genuinely optional NULL fields.
-- TODO: preserve inspection deviations, genuine high process costs and authorized CPO price adjustments.
-- TODO: create celonis_event_log_clean, quarantining essential irrecoverable timestamps.
