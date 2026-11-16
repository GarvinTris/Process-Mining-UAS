-- STEP 1: HAPUS VIEW LAMA
DROP VIEW IF EXISTS raw_events;

-- STEP 2: IMPORT ULANG RAW EVENT LOG SEBAGAI TABLE
CREATE TABLE raw_events AS
SELECT *
FROM read_csv(
    'UAS Process Data Mining/01_DATA/raw/raw_event_log.csv',
    header = true,
    all_varchar = true
);

-- STEP 3: CEK JUMLAH RECORD
SELECT COUNT(*) AS rows_imported
FROM raw_events;

-- STEP 4: CEK STRUKTUR KOLOM
DESCRIBE raw_events;