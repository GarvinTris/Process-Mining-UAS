-- Starter profiling queries. Extend with master-key checks, format counts and an assessment report.
SELECT
    COUNT(*) AS raw_rows,
    COUNT(DISTINCT TRIM(case_id)) AS source_cases
FROM
    raw_events;

SELECT
    activity,
    COUNT(*) AS occurrences
FROM
    raw_events
GROUP BY
    activity
ORDER BY
    occurrences DESC;

SELECT
    UPPER(TRIM(event_id)) AS normalized_event_id,
    COUNT(*) AS repeated_sources
FROM
    raw_events
GROUP BY
    normalized_event_id
HAVING
    COUNT(*) > 1
ORDER BY
    repeated_sources DESC;

SELECT
    department,
    COUNT(*) AS event_count
FROM
    raw_events
GROUP BY
    department
ORDER BY
    event_count DESC;

SELECT
    COUNT(*) AS blank_employee_ids
FROM
    raw_events
WHERE
    employee_id IS NULL
    OR TRIM(employee_id) = '';

-- TODO: identify timestamp variants, formatting anomalies, relational issues, and suspicious numeric values.
-- Cek apakah nilai timestamp yang kosong atau format yang tidak valid
SELECT
    COUNT(*) AS missing_timestamps
FROM
    raw_events
WHERE
    activity_start_time IS NULL
    OR activity_end_time IS NULL
    OR timestamp IS NULL;

-- Cek anomali durasi: waktu selesai lebih awal dari waktu mulai
SELECT
    raw_row_id,
    case_id,
    activity,
    activity_start_time,
    activity_end_time
FROM
    raw_events
WHERE
    activity_end_time < activity_start_time;

-- Cek employee_id yang tidak ada di employee_master
SELECT DISTINCT
    r.employee_id
FROM
    read_csv_auto ('01_DATA/raw/raw_event_log.csv') r
    LEFT JOIN read_csv_auto ('01_DATA/raw/employee_master.csv') e ON r.employee_id = e.employee_id
WHERE
    e.employee_id IS NULL
    AND r.employee_id IS NOT NULL
    AND TRIM(r.employee_id) <> '';

-- Cek facility_id yang tidak ada di facility_master
SELECT DISTINCT
    r.facility_id
FROM
    read_csv_auto ('01_DATA/raw/raw_event_log.csv') r
    LEFT JOIN read_csv_auto ('01_DATA/raw/facility_master.csv') f ON r.facility_id = f.facility_id
WHERE
    f.facility_id IS NULL
    AND r.facility_id IS NOT NULL
    AND TRIM(r.facility_id) <> '';

-- Contoh pemeriksaan nilai negatif atau nol pada kolom numerik
-- Sesuaikan nama kolom jika ada kolom durasi/biaya di tabel Anda
SELECT
    raw_row_id,
    case_id,
    activity
FROM
    raw_events
WHERE
    1 = 0;

-- Ganti dengan kondisi kolom numerik spesifik jika ada, contoh: numeric_column < 0