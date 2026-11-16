-- =====================================================
-- Q06: RESOURCE DEPENDENCY, WAITING QUEUES, AND CAPACITY ANALYSIS
-- =====================================================


-- =====================================================
-- STEP 0: LOAD CLEAN EVENT LOG AND MASTER DATA
-- =====================================================

CREATE OR REPLACE VIEW celonis_event_log_clean AS
SELECT *
FROM read_csv_auto(
    'UAS Process Data Mining/01_DATA/raw/validation/celonis_event_log_clean.csv',
    header = true
);


CREATE OR REPLACE VIEW facility_master AS
SELECT *
FROM read_csv_auto(
    'UAS Process Data Mining/01_DATA/raw/facility_master.csv',
    header = true
);


CREATE OR REPLACE VIEW resource_master AS
SELECT *
FROM read_csv_auto(
    'UAS Process Data Mining/01_DATA/raw/resource_master.csv',
    header = true
);


-- =====================================================
-- QUERY 1: WAITING QUEUES VS PROCESSING DURATION
-- AND SLA VIOLATIONS BY PRODUCTION CELL TYPE
-- =====================================================

SELECT
    f.facility_type,

    COUNT(DISTINCT c.facility_id) AS available_cells,

    STRING_AGG(
        DISTINCT c.activity,
        ', ' ORDER BY c.activity
    ) AS activities_performed,

    COUNT(*) AS total_executions,

    ROUND(
        AVG(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS avg_wait_mins,

    ROUND(
        MAX(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS max_wait_mins,

    ROUND(
        SUM(TRY_CAST(c.waiting_time_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_wait_hours,

    ROUND(
        AVG(TRY_CAST(c.activity_duration_minutes AS DOUBLE)),
        2
    ) AS avg_proc_mins,

    ROUND(
        SUM(TRY_CAST(c.activity_duration_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_proc_hours,

    ROUND(
        AVG(TRY_CAST(c.waiting_time_minutes AS DOUBLE))
        /
        NULLIF(
            AVG(TRY_CAST(c.activity_duration_minutes AS DOUBLE)),
            0
        ),
        2
    ) AS wait_to_proc_ratio,

    SUM(
        CASE
            WHEN LOWER(TRIM(CAST(c.sla_violation AS VARCHAR)))
                IN ('true', '1', 'yes', 'y')
            THEN 1
            ELSE 0
        END
    ) AS sla_violations,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(TRIM(CAST(c.sla_violation AS VARCHAR)))
                    IN ('true', '1', 'yes', 'y')
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS sla_violation_pct,

    ROUND(
        SUM(TRY_CAST(c.activity_total_cost AS DECIMAL(18,2))),
        2
    ) AS total_cost_eur

FROM celonis_event_log_clean c

JOIN facility_master f
    ON c.facility_id = f.facility_id

GROUP BY f.facility_type

ORDER BY total_wait_hours DESC;


-- =====================================================
-- QUERY 2: RESOURCE SCHEDULING AND RESOURCE IMBALANCE
-- =====================================================

SELECT
    c.resource_id,

    r.resource_type,

    r.department,

    r.capacity,

    COUNT(*) AS total_executions,

    COUNT(DISTINCT c.case_id) AS total_cases,

    ROUND(
        AVG(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS avg_wait_mins,

    ROUND(
        MAX(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS max_wait_mins,

    ROUND(
        SUM(TRY_CAST(c.waiting_time_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_wait_hours,

    ROUND(
        AVG(TRY_CAST(c.activity_duration_minutes AS DOUBLE)),
        2
    ) AS avg_processing_mins,

    ROUND(
        SUM(TRY_CAST(c.activity_duration_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_processing_hours,

    SUM(
        CASE
            WHEN LOWER(TRIM(CAST(c.sla_violation AS VARCHAR)))
                IN ('true', '1', 'yes', 'y')
            THEN 1
            ELSE 0
        END
    ) AS sla_violations,

    ROUND(
        SUM(TRY_CAST(c.activity_total_cost AS DECIMAL(18,2))),
        2
    ) AS total_cost_eur

FROM celonis_event_log_clean c

LEFT JOIN resource_master r
    ON c.resource_id = r.resource_id

WHERE c.resource_id IS NOT NULL

GROUP BY
    c.resource_id,
    r.resource_type,
    r.department,
    r.capacity

ORDER BY total_wait_hours DESC;


-- =====================================================
-- QUERY 3: PRODUCTION CELL IMBALANCE AND BOTTLENECK
-- =====================================================

SELECT
    f.facility_type,

    c.facility_id,

    f.capacity,

    COUNT(*) AS executions,

    COUNT(DISTINCT c.case_id) AS total_cases,

    ROUND(
        AVG(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS avg_wait_mins,

    ROUND(
        MAX(TRY_CAST(c.waiting_time_minutes AS DOUBLE)),
        2
    ) AS max_wait_mins,

    ROUND(
        SUM(TRY_CAST(c.waiting_time_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_wait_hours,

    ROUND(
        AVG(TRY_CAST(c.activity_duration_minutes AS DOUBLE)),
        2
    ) AS avg_proc_mins,

    ROUND(
        SUM(TRY_CAST(c.activity_duration_minutes AS DOUBLE)) / 60.0,
        2
    ) AS total_proc_hours,

    ROUND(
        AVG(TRY_CAST(c.waiting_time_minutes AS DOUBLE))
        /
        NULLIF(
            AVG(TRY_CAST(c.activity_duration_minutes AS DOUBLE)),
            0
        ),
        2
    ) AS wait_to_proc_ratio,

    SUM(
        CASE
            WHEN LOWER(TRIM(CAST(c.sla_violation AS VARCHAR)))
                IN ('true', '1', 'yes', 'y')
            THEN 1
            ELSE 0
        END
    ) AS sla_violations,

    ROUND(
        SUM(TRY_CAST(c.activity_total_cost AS DECIMAL(18,2))),
        2
    ) AS total_cost_eur

FROM celonis_event_log_clean c

JOIN facility_master f
    ON c.facility_id = f.facility_id

WHERE f.facility_type IN (
    'Paint Booth',
    'Press Line',
    'Chassis Line',
    'Kitting Station'
)

GROUP BY
    f.facility_type,
    c.facility_id,
    f.capacity

ORDER BY
    f.facility_type,
    total_wait_hours DESC;


-- =====================================================
-- QUERY 4: OVERLAPPING PARALLEL OPERATIONS
-- =====================================================

WITH overlapping_events AS (

    SELECT
        a.case_id,

        a.event_id AS event_a,
        b.event_id AS event_b,

        a.activity AS activity_a,
        b.activity AS activity_b,

        a.resource_id AS resource_a,
        b.resource_id AS resource_b,

        a.facility_id AS facility_a,
        b.facility_id AS facility_b,

        GREATEST(
            TRY_CAST(a.activity_start_time AS TIMESTAMP),
            TRY_CAST(b.activity_start_time AS TIMESTAMP)
        ) AS overlap_start,

        LEAST(
            TRY_CAST(a.activity_end_time AS TIMESTAMP),
            TRY_CAST(b.activity_end_time AS TIMESTAMP)
        ) AS overlap_end

    FROM celonis_event_log_clean a

    JOIN celonis_event_log_clean b
        ON a.case_id = b.case_id

        AND a.event_id < b.event_id

        AND TRY_CAST(a.activity_start_time AS TIMESTAMP)
            < TRY_CAST(b.activity_end_time AS TIMESTAMP)

        AND TRY_CAST(b.activity_start_time AS TIMESTAMP)
            < TRY_CAST(a.activity_end_time AS TIMESTAMP)

    WHERE
        a.activity_start_time IS NOT NULL
        AND b.activity_start_time IS NOT NULL
)

SELECT
    LEAST(activity_a, activity_b)
        || ' || ' ||
    GREATEST(activity_a, activity_b)
        AS parallel_branch_pair,

    COUNT(*) AS overlapping_event_pairs,

    COUNT(DISTINCT case_id) AS overlapping_cases,

    ROUND(
        AVG(
            EPOCH(overlap_end - overlap_start) / 60.0
        ),
        2
    ) AS avg_overlap_mins,

    SUM(
        CASE
            WHEN resource_a = resource_b
             AND resource_a IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS same_resource_conflicts,

    SUM(
        CASE
            WHEN facility_a = facility_b
             AND facility_a IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS same_facility_conflicts

FROM overlapping_events

GROUP BY 1

ORDER BY overlapping_event_pairs DESC;


-- =====================================================
-- END OF Q06
-- =====================================================