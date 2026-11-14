-- Open student directory in VS Code and use it as the DuckDB working directory.
-- Import all raw columns as text: no implicit type correction or repair.
CREATE
OR REPLACE TABLE raw_events AS
SELECT
    *
FROM
    read_csv (
        '01_DATA/raw/raw_event_log.csv',
        header = true,
        all_varchar = true
    );

SELECT
    COUNT(*) AS rows_imported
FROM
    raw_events;

DESCRIBE raw_events;
