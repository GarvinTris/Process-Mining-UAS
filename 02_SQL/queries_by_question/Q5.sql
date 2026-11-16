-- =========================================================
-- Q05: PARTS AVAILABILITY AND SHORTAGE
-- =========================================================
-- QUERY 1: Materials and Parts activity performance
SELECT
    activity,
    COUNT(*) AS total_executions,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(AVG(TRY_CAST (waiting_time_minutes AS DOUBLE)), 2) AS avg_waiting_minutes,
    ROUND(
        AVG(TRY_CAST (activity_duration_minutes AS DOUBLE)),
        2
    ) AS avg_processing_minutes,
    ROUND(
        SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))),
        2
    ) AS total_activity_cost
FROM
    celonis_event_log_clean
WHERE
    activity ILIKE '%material%'
    OR activity ILIKE '%part%'
    OR activity ILIKE '%supplier%'
GROUP BY
    activity
ORDER BY
    avg_waiting_minutes DESC;

-- QUERY 2: Identify shortage-related activities
SELECT
    activity,
    COUNT(*) AS total_events,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(
        SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))),
        2
    ) AS total_cost
FROM
    celonis_event_log_clean
WHERE
    activity ILIKE '%shortage%'
    OR activity ILIKE '%supplier%'
    OR activity ILIKE '%material unavailable%'
GROUP BY
    activity
ORDER BY
    total_events DESC;

-- =====================================================
-- Q05 QUERY 3: PRODUCTION LEAD TIME AND COST PER ORDER
-- =====================================================
WITH
    case_metrics AS (
        SELECT
            case_id,
            MIN(TRY_CAST (activity_start_time AS TIMESTAMP)) FILTER (
                WHERE
                    activity = 'Production Order Received'
            ) AS production_start,
            MAX(TRY_CAST (activity_end_time AS TIMESTAMP)) FILTER (
                WHERE
                    activity = 'Vehicle Delivered'
            ) AS delivery_time,
            SUM(TRY_CAST (activity_duration_minutes AS DOUBLE)) AS total_processing_minutes,
            SUM(TRY_CAST (waiting_time_minutes AS DOUBLE)) AS total_waiting_minutes,
            SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))) AS total_order_cost,
            BOOL_OR (activity = 'Supplier Shortage Resolved') AS has_shortage
        FROM
            celonis_event_log_clean
        GROUP BY
            case_id
    )
SELECT
    case_id,
    CASE
        WHEN has_shortage THEN 'With Shortage'
        ELSE 'Without Shortage'
    END AS shortage_group,
    ROUND(
        DATE_DIFF ('second', production_start, delivery_time) / 3600.0,
        2
    ) AS production_lead_time_hours,
    ROUND(total_processing_minutes, 2) AS total_processing_minutes,
    ROUND(total_waiting_minutes, 2) AS total_waiting_minutes,
    ROUND(total_order_cost, 2) AS total_cost_per_order
FROM
    case_metrics
WHERE
    delivery_time IS NOT NULL
    AND production_start IS NOT NULL
ORDER BY
    production_lead_time_hours DESC;

-- =====================================================
-- Q05 QUERY 4: SHORTAGE VS NON-SHORTAGE COMPARISON
-- =====================================================
WITH
    case_metrics AS (
        SELECT
            case_id,
            MIN(TRY_CAST (activity_start_time AS TIMESTAMP)) FILTER (
                WHERE
                    activity = 'Production Order Received'
            ) AS production_start,
            MAX(TRY_CAST (activity_end_time AS TIMESTAMP)) FILTER (
                WHERE
                    activity = 'Vehicle Delivered'
            ) AS delivery_time,
            SUM(TRY_CAST (activity_duration_minutes AS DOUBLE)) AS processing_minutes,
            SUM(TRY_CAST (waiting_time_minutes AS DOUBLE)) AS waiting_minutes,
            SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))) AS total_cost,
            BOOL_OR (activity = 'Supplier Shortage Resolved') AS has_shortage
        FROM
            celonis_event_log_clean
        GROUP BY
            case_id
    ),
    delivered_cases AS (
        SELECT
            *,
            DATE_DIFF ('second', production_start, delivery_time) / 3600.0 AS lead_time_hours
        FROM
            case_metrics
        WHERE
            production_start IS NOT NULL
            AND delivery_time IS NOT NULL
    )
SELECT
    CASE
        WHEN has_shortage THEN 'With Shortage'
        ELSE 'Without Shortage'
    END AS shortage_group,
    COUNT(*) AS delivered_cases,
    ROUND(MEDIAN (lead_time_hours), 2) AS median_lead_time_hours,
    ROUND(AVG(lead_time_hours), 2) AS avg_lead_time_hours,
    ROUND(AVG(waiting_minutes), 2) AS avg_waiting_minutes,
    ROUND(AVG(processing_minutes), 2) AS avg_processing_minutes,
    ROUND(AVG(total_cost), 2) AS avg_cost_per_order
FROM
    delivered_cases
GROUP BY
    has_shortage
ORDER BY
    has_shortage;

-- =====================================================
-- Q05 QUERY 5: PROCESS VARIANT BY SHORTAGE STATUS
-- =====================================================
WITH
    case_variants AS (
        SELECT
            case_id,
            BOOL_OR (activity = 'Supplier Shortage Resolved') AS has_shortage,
            STRING_AGG (
                activity,
                ' -> '
                ORDER BY
                    TRY_CAST (activity_start_time AS TIMESTAMP),
                    event_id
            ) AS process_variant,
            SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))) AS total_order_cost
        FROM
            celonis_event_log_clean
        GROUP BY
            case_id
    ),
    variant_summary AS (
        SELECT
            CASE
                WHEN has_shortage THEN 'With Shortage'
                ELSE 'Without Shortage'
            END AS shortage_group,
            process_variant,
            COUNT(*) AS total_cases,
            AVG(total_order_cost) AS avg_order_cost
        FROM
            case_variants
        GROUP BY
            has_shortage,
            process_variant
    )
SELECT
    shortage_group,
    process_variant,
    total_cases,
    ROUND(avg_order_cost, 2) AS avg_order_cost
FROM
    variant_summary
ORDER BY
    total_cases DESC;

-- =====================================================
-- Q05 QUERY 6: ROOT CAUSE HYPOTHESIS
-- =====================================================
SELECT
    exception_type,
    case_complexity,
    case_priority,
    model_name,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(AVG(TRY_CAST (waiting_time_minutes AS DOUBLE)), 2) AS avg_waiting_minutes,
    ROUND(
        SUM(TRY_CAST (activity_total_cost AS DECIMAL(18, 2))),
        2
    ) AS total_activity_cost
FROM
    celonis_event_log_clean
WHERE
    activity = 'Supplier Shortage Resolved'
GROUP BY
    exception_type,
    case_complexity,
    case_priority,
    model_name
ORDER BY
    affected_cases DESC;