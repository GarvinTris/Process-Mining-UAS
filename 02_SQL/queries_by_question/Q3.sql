-- =========================================================
-- Q03 ADDITIONAL: COMPLETION RATE AND DELIVERY TIME
-- Mengukur order yang mencapai Vehicle Delivered.
-- =========================================================
WITH
    base AS (
        SELECT
            case_id,
            activity,
            TRY_CAST (activity_start_time AS TIMESTAMP) AS start_time
        FROM
            READ_CSV_AUTO('01_DATA/cleaned/celonis_event_log_clean.csv', header = TRUE)
    ),
    case_delivery AS (
        SELECT
            case_id,
            MIN(start_time) FILTER(
                WHERE
                    LOWER(activity) = 'production order received'
            ) AS order_received_time,
            MAX(start_time) FILTER(
                WHERE
                    LOWER(activity) = 'vehicle delivered'
            ) AS vehicle_delivered_time
        FROM
            base
        WHERE
            case_id IS NOT NULL
        GROUP BY
            case_id
    )
SELECT
    COUNT(*) AS total_production_orders,
    COUNT(vehicle_delivered_time) AS delivered_orders,
    COUNT(*) - COUNT(vehicle_delivered_time) AS orders_not_yet_delivered,
    ROUND(100.0 * COUNT(vehicle_delivered_time) / NULLIF(COUNT(*), 0), 2) AS completion_rate_percentage,
    ROUND(
        AVG(DATE_DIFF('minute', order_received_time, vehicle_delivered_time)) FILTER(
            WHERE
                order_received_time IS NOT NULL
                AND vehicle_delivered_time IS NOT NULL
        ),
        2
    ) AS avg_order_to_delivery_minutes
FROM
    case_delivery;
