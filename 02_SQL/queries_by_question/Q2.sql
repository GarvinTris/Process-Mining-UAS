-- Q02: PRODUCTION OUTCOMES AND SCRAP COST
WITH
    base AS (
        SELECT
            case_id,
            activity,
            COALESCE(activity_total_cost, 0) AS activity_cost,
            COALESCE(revenue_allocated, 0) AS revenue,
            COALESCE(profit_contribution, 0) AS profit_contribution
        FROM
            READ_CSV_AUTO('01_DATA/cleaned/celonis_event_log_clean.csv', header = TRUE)
    ),
    case_summary AS (
        SELECT
            case_id,
            MAX(
                CASE
                    WHEN activity = 'Vehicle Delivered' THEN 1
                    ELSE 0
                END
            ) AS delivered_flag,
            MAX(
                CASE
                    WHEN activity = 'Production Scrapped' THEN 1
                    ELSE 0
                END
            ) AS scrapped_flag,
            MAX(
                CASE
                    WHEN activity = 'Order Cancelled' THEN 1
                    ELSE 0
                END
            ) AS cancelled_flag,
            SUM(activity_cost) AS total_cost,
            SUM(revenue) AS total_revenue,
            SUM(profit_contribution) AS total_profit_contribution
        FROM
            base
        GROUP BY
            case_id
    ),
    classified_orders AS (
        SELECT
            case_id,
            CASE
                WHEN scrapped_flag = 1 THEN 'Scrapped'
                WHEN cancelled_flag = 1 THEN 'Cancelled'
                WHEN delivered_flag = 1 THEN 'Completed'
                ELSE 'Other'
            END AS production_outcome,
            total_cost,
            total_revenue,
            total_profit_contribution
        FROM
            case_summary
    )
SELECT
    production_outcome,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_cost), 2) AS total_consumed_cost,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(SUM(total_profit_contribution), 2) AS total_profit_contribution,
    ROUND(AVG(total_cost), 2) AS average_cost_per_order
FROM
    classified_orders
WHERE
    production_outcome IN ('Completed', 'Scrapped', 'Cancelled')
GROUP BY
    production_outcome
ORDER BY
    CASE production_outcome
        WHEN 'Completed' THEN 1
        WHEN 'Scrapped' THEN 2
        WHEN 'Cancelled' THEN 3
    END;
