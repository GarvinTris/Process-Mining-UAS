-- Enhance these starting checks for completeness, uniqueness, validity and referential integrity.
SELECT
    COUNT(*) AS source_rows
FROM
    raw_events;

SELECT
    COUNT(*) AS no_case_id
FROM
    raw_events
WHERE
    case_id IS NULL
    OR TRIM(case_id) = '';

SELECT
    COUNT(*) AS no_activity
FROM
    raw_events
WHERE
    activity IS NULL
    OR TRIM(activity) = '';

-- TODO: test correct event/case relationships, queueing, exclusive machine use and financial identities.
-- TODO: preserve legitimate rework and overlapping process activities; verify sale recognition once per delivered case.
-- 2. Financial Events View & Validation (Financial Identities Check)
-- Memastikan struktur finansial bersih dari string 'EUR' dan memeriksa konsistensi kontribusi
CREATE
OR REPLACE VIEW financial_events AS
SELECT
    event_id,
    case_id,
    activity,
    activity_start_time,
    activity_end_time,
    TRY_CAST (
        REPLACE (
            REPLACE (COALESCE(activity_total_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS activity_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (COALESCE(revenue_allocated, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS revenue,
    TRY_CAST (
        REPLACE (
            REPLACE (COALESCE(profit_contribution, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS recorded_contribution,
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y') AS is_rework
FROM
    raw_events;

-- Audit Data Finansial & Identitas Finansial (Sesuai Panduan Hal. 11)
SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) FILTER (
        WHERE
            case_id IS NULL
            OR event_id IS NULL
    ) AS missing_identifiers,
    COUNT(*) FILTER (
        WHERE
            activity_cost IS NULL
            OR revenue IS NULL
            OR recorded_contribution IS NULL
    ) AS invalid_financial_rows,
    COUNT(*) FILTER (
        WHERE
            ABS(recorded_contribution - (revenue - activity_cost)) > 0.01
    ) AS inconsistent_contribution_rows
FROM
    financial_events;

-- 3. TODO: Test Correct Event/Case Relationships & Timestamp Sequence
-- Menguji apakah waktu mulai aktivitas mendahului waktu selesai (kronologi logis)
SELECT
    COUNT(*) AS invalid_time_sequence
FROM
    raw_events
WHERE
    TRY_CAST (activity_start_time AS TIMESTAMP) > TRY_CAST (activity_end_time AS TIMESTAMP);

-- 4. TODO: Queueing, Exclusive Machine Use & Relationship Validation
-- Memeriksa apakah ada event dalam satu case yang bertumpuk secara tidak wajar atau konflik alokasi resource
SELECT
    case_id,
    COUNT(*) AS total_case_events,
    COUNT(DISTINCT event_id) AS unique_case_events
FROM
    raw_events
GROUP BY
    case_id
HAVING
    COUNT(*) <> COUNT(DISTINCT event_id);

-- 5. TODO: Preserve Legitimate Rework & Verify Sale Recognition Once Per Delivered Case
-- Memeriksa konsistensi pengakuan pendapatan (revenue) hanya pada case yang sah / terkirim
-- serta mendeteksi anomali negatif revenue yang tidak wajar.
SELECT
    case_id,
    COUNT(
        CASE
            WHEN LOWER(activity) LIKE '%deliver%'
            OR LOWER(activity) LIKE '%sales%' THEN 1
        END
    ) AS delivery_events_count,
    SUM(
        TRY_CAST (
            REPLACE (
                REPLACE (COALESCE(revenue_allocated, '0'), 'EUR', ''),
                ' ',
                ''
            ) AS DECIMAL(18, 2)
        )
    ) AS total_revenue_allocated
FROM
    raw_events
GROUP BY
    case_id
HAVING
    SUM(
        TRY_CAST (
            REPLACE (
                REPLACE (COALESCE(revenue_allocated, '0'), 'EUR', ''),
                ' ',
                ''
            ) AS DECIMAL(18, 2)
        )
    ) < 0;
