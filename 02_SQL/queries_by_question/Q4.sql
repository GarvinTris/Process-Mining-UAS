-- =====================================================
-- Q04: PAINT AND ROAD-TEST REWORK
-- =====================================================
-- STEP 0: CREATE EVENT LOG VIEWS
CREATE
OR REPLACE VIEW raw_event_log_source AS
SELECT
    *
FROM
    read_csv_auto (
        'UAS Process Data Mining/01_DATA/raw/raw_event_log.csv',
        header = true
    );

CREATE
OR REPLACE VIEW celonis_event_log_clean AS
SELECT
    *
FROM
    read_csv_auto (
        'UAS Process Data Mining/01_DATA/raw/validation/celonis_event_log_clean.csv',
        header = true
    );

-- =====================================================
-- QUERY 1: DUPLICATE SOURCE RECORD DETECTION
-- =====================================================
WITH
    duplicate_check AS (
        SELECT
            UPPER(TRIM(CAST(event_id AS VARCHAR))) AS event_key,
            COUNT(*) AS source_records
        FROM
            raw_event_log_source
        GROUP BY
            1
    )
SELECT
    COUNT(*) FILTER (
        WHERE
            source_records > 1
    ) AS duplicate_event_groups,
    SUM(
        CASE
            WHEN source_records > 1 THEN source_records - 1
            ELSE 0
        END
    ) AS duplicate_source_rows,
    COUNT(*) FILTER (
        WHERE
            source_records = 1
    ) AS unique_event_groups
FROM
    duplicate_check;

-- =====================================================
-- QUERY 2: GENUINE REWORK ACTIVITY SUMMARY
-- =====================================================
SELECT
    activity,
    COUNT(*) AS total_executions,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(SUM(activity_total_cost), 2) AS recorded_rework_cost
FROM
    celonis_event_log_clean
WHERE
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y')
    OR activity ILIKE '%rework%'
    OR activity ILIKE '%defect rectified%'
GROUP BY
    activity
ORDER BY
    recorded_rework_cost DESC;

-- =====================================================
-- QUERY 3: RECORDED REWORK COST BY CASE
-- =====================================================
SELECT
    case_id,
    COUNT(*) AS rework_executions,
    ROUND(SUM(activity_total_cost), 2) AS recorded_rework_cost
FROM
    celonis_event_log_clean
WHERE
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y')
    OR activity ILIKE '%rework%'
    OR activity ILIKE '%defect rectified%'
GROUP BY
    case_id
ORDER BY
    recorded_rework_cost DESC;

-- =====================================================
-- QUERY 4: REPEATED ACTIVITIES WITHIN SAME CASE
-- =====================================================
SELECT
    case_id,
    activity,
    COUNT(*) AS execution_count,
    COUNT(DISTINCT event_id) AS unique_event_ids,
    ROUND(SUM(activity_total_cost), 2) AS total_activity_cost
FROM
    celonis_event_log_clean
GROUP BY
    case_id,
    activity
HAVING
    COUNT(*) > 1
ORDER BY
    execution_count DESC,
    total_activity_cost DESC;

-- =====================================================
-- QUERY 5: TOTAL RECORDED REWORK COST
-- =====================================================
SELECT
    COUNT(*) AS total_rework_events,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(SUM(activity_total_cost), 2) AS total_recorded_rework_cost
FROM
    celonis_event_log_clean
WHERE
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y')
    OR activity ILIKE '%rework%'
    OR activity ILIKE '%defect rectified%';

-- =====================================================
-- QUERY 6: REWORK INCIDENCE BY CASE
-- =====================================================
WITH
    case_rework AS (
        SELECT
            case_id,
            BOOL_OR (
                LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y')
                OR activity ILIKE '%rework%'
                OR activity ILIKE '%defect rectified%'
            ) AS has_rework
        FROM
            celonis_event_log_clean
        GROUP BY
            case_id
    )
SELECT
    COUNT(*) AS total_cases,
    COUNT(*) FILTER (
        WHERE
            has_rework
    ) AS rework_cases,
    COUNT(*) FILTER (
        WHERE
            NOT has_rework
    ) AS cases_without_recorded_rework,
    ROUND(
        COUNT(*) FILTER (
            WHERE
                has_rework
        ) * 100.0 / COUNT(*),
        2
    ) AS rework_incidence_percentage
FROM
    case_rework;