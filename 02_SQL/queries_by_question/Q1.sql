-- =====================================================
-- Q01: MANUFACTURING PROCESS VARIANTS
-- Tujuan:
-- 1. Mengetahui variasi actual production process.
-- 2. Mengambil 3 process variants yang paling sering terjadi.
-- 3. Membandingkan Throughput Time, Activity Cost,
--    Revenue, dan Profit Contribution per vehicle.
-- =====================================================
WITH
    base AS (
        SELECT
            case_id,
            event_id,
            activity,
            TRY_CAST (activity_start_time AS TIMESTAMP) AS start_time,
            TRY_CAST (activity_end_time AS TIMESTAMP) AS end_time,
            TRY_CAST (activity_total_cost AS DOUBLE) AS activity_cost,
            TRY_CAST (revenue_allocated AS DOUBLE) AS revenue,
            TRY_CAST (profit_contribution AS DOUBLE) AS recorded_contribution
        FROM
            READ_CSV_AUTO('01_DATA/cleaned/celonis_event_log_clean.csv', header = TRUE)
    ),
    -- Membentuk urutan aktivitas untuk setiap Production Order
    case_process AS (
        SELECT
            case_id,
            STRING_AGG(
                activity,
                ' -> '
                ORDER BY
                    start_time,
                    event_id
            ) AS process_variant,
            DATE_DIFF('minute', MIN(start_time), MAX(end_time)) AS throughput_time_minutes,
            SUM(activity_cost) AS total_activity_cost,
            SUM(revenue) AS total_revenue,
            -- Profit Contribution = Revenue - Activity Cost
            SUM(revenue) - SUM(activity_cost) AS profit_contribution,
            -- Untuk memeriksa kesesuaian nilai contribution dari dataset
            SUM(recorded_contribution) AS recorded_profit_contribution
        FROM
            base
        WHERE
            case_id IS NOT NULL
            AND activity IS NOT NULL
            AND start_time IS NOT NULL
            AND end_time IS NOT NULL
        GROUP BY
            case_id
    ),
    -- Menghitung KPI untuk setiap Process Variant
    variant_analysis AS (
        SELECT
            process_variant,
            COUNT(*) AS total_vehicles,
            ROUND(AVG(throughput_time_minutes), 2) AS avg_throughput_time_minutes,
            ROUND(AVG(total_activity_cost), 2) AS avg_activity_cost_eur,
            ROUND(AVG(total_revenue), 2) AS avg_revenue_eur,
            ROUND(AVG(profit_contribution), 2) AS avg_profit_contribution_eur,
            ROUND(AVG(profit_contribution - recorded_profit_contribution), 2) AS avg_contribution_validation_difference_eur
        FROM
            case_process
        GROUP BY
            process_variant
    ),
    -- Mengurutkan variant berdasarkan jumlah kendaraan
    ranked_variants AS (
        SELECT
            *,
            ROW_NUMBER() OVER (
                ORDER BY
                    total_vehicles DESC,
                    process_variant
            ) AS variant_rank
        FROM
            variant_analysis
    )
    -- Menampilkan 3 Process Variants teratas
SELECT
    variant_rank,
    process_variant,
    total_vehicles,
    avg_throughput_time_minutes,
    avg_activity_cost_eur,
    avg_revenue_eur,
    avg_profit_contribution_eur,
    avg_contribution_validation_difference_eur
FROM
    ranked_variants
WHERE
    variant_rank <= 3
ORDER BY
    variant_rank;
