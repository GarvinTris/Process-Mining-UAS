-- =============================================================================
-- Q08: PRODUCTION BOTTLENECK CAPACITY (RESCHEDULING VS OVERTIME VS EQUIPMENT)
-- Jalankan dari root folder submission kelompok (24SI1_Group02_Automotive / Process-Mining-UAS-main)
-- Sumber: 01_DATA/cleaned/celonis_event_log_clean.csv, employee_master.csv, capacity_simulation_results.csv, exchange_rate.csv
-- =============================================================================

CREATE OR REPLACE VIEW clean_events_q08 AS
SELECT
    event_id,
    case_id,
    activity,
    resource_id,
    CAST(activity_start_time AS TIMESTAMP) AS start_ts,
    CAST(waiting_time_minutes AS DOUBLE) AS waiting_minutes,
    CAST(activity_duration_minutes AS DOUBLE) AS duration_minutes,
    LOWER(TRIM(CAST(sla_violation AS VARCHAR))) IN ('true', '1', 'yes', 'y') AS is_sla_violation,
    CAST(activity_total_cost AS DECIMAL(18, 2)) AS activity_cost,
    CAST(revenue_allocated AS DECIMAL(18, 2)) AS revenue
FROM read_csv_auto('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);

CREATE OR REPLACE VIEW fx_ref_q08 AS
SELECT
    CAST(reference_idr_per_1_unit AS DECIMAL(20, 6)) AS idr_per_unit
FROM read_csv_auto('05_FINANCIAL/exchange_rate.csv', header = true)
WHERE reference_date = '2026-10-13'
  AND currency = 'EUR';

-- 1. Bottleneck Leaderboard dari Event Log Aktual (Top 10 Waiting Time & SLA Violations)
SELECT
    activity,
    COUNT(*) AS executions,
    ROUND(SUM(waiting_minutes), 2) AS total_wait_min,
    ROUND(SUM(waiting_minutes) / 60.0, 2) AS total_wait_hours,
    ROUND(AVG(waiting_minutes), 2) AS avg_wait_min,
    COUNT(*) FILTER (WHERE is_sla_violation) AS sla_violations
FROM clean_events_q08
GROUP BY activity
ORDER BY total_wait_min DESC
LIMIT 10;

-- 2. Deteksi Lonjakan Order (Surge Arrival) per Tanggal
SELECT
    CAST(start_ts AS DATE) AS production_date,
    COUNT(DISTINCT case_id) AS active_cases,
    ROUND(SUM(waiting_minutes) / 60.0, 2) AS total_wait_hours,
    COUNT(*) FILTER (WHERE is_sla_violation) AS sla_violations
FROM clean_events_q08
GROUP BY 1
ORDER BY active_cases DESC
LIMIT 10;

-- 3. Perbandingan Biaya & Dampak Kapasitas: Rescheduling vs Overtime vs Equipment Investment
WITH baseline AS (
    SELECT
        ROUND(SUM(revenue) - SUM(activity_cost), 2) AS as_is_contribution_eur
    FROM clean_events_q08
),
ot_rates AS (
    SELECT
        AVG(CASE WHEN employee_role = 'Paint Technician' THEN CAST(hourly_cost_eur AS DOUBLE) END) AS paint_rate,
        AVG(CASE WHEN employee_role = 'Press Operator' THEN CAST(hourly_cost_eur AS DOUBLE) END) AS press_rate,
        AVG(CASE WHEN employee_role = 'Assembly Technician' THEN CAST(hourly_cost_eur AS DOUBLE) END) AS assembly_rate
    FROM read_csv_auto('01_DATA/employee_master.csv', header = true)
),
sim AS (
    SELECT *
    FROM read_csv_auto('05_FINANCIAL/capacity_simulation_results.csv', header = true)
),
options AS (
    SELECT
        'A60: Rescheduling (Takt 60 menit)' AS option_name,
        3000.00 AS impl_cost_eur,
        1000.00 AS add_opex_or_dep_24m_eur,
        389.00 AS wip_carrying_savings_eur,
        0.00 AS incremental_revenue_eur
    UNION ALL
    SELECT
        'B2: Overtime Staffing (+2 Paint, +1 Press, +1 Assembly)' AS option_name,
        0.00 AS impl_cost_eur,
        ROUND((2 * paint_rate + 1 * press_rate + 1 * assembly_rate) * 50.0 * 1.5, 2) AS add_opex_or_dep_24m_eur,
        0.00 AS wip_carrying_savings_eur,
        0.00 AS incremental_revenue_eur
    FROM ot_rates
    UNION ALL
    SELECT
        'C1: Equipment (+1 Paint Booth, CapEx EUR 1.5M, dep 24 bln)' AS option_name,
        1500000.00 AS impl_cost_eur,
        ROUND(1500000.00 * 2.0 / 10.0, 2) AS add_opex_or_dep_24m_eur,
        0.00 AS wip_carrying_savings_eur,
        0.00 AS incremental_revenue_eur
    UNION ALL
    SELECT
        'C3: Equipment (+1 Press, +1 Paint, +1 Chassis, CapEx EUR 5.8M)' AS option_name,
        5800000.00 AS impl_cost_eur,
        ROUND(5800000.00 * 2.0 / 10.0, 2) AS add_opex_or_dep_24m_eur,
        0.00 AS wip_carrying_savings_eur,
        0.00 AS incremental_revenue_eur
)
SELECT
    o.option_name,
    o.impl_cost_eur,
    o.add_opex_or_dep_24m_eur,
    o.wip_carrying_savings_eur,
    o.incremental_revenue_eur,
    ROUND(o.wip_carrying_savings_eur + o.incremental_revenue_eur - (CASE WHEN o.option_name LIKE 'A60%' THEN o.impl_cost_eur + o.add_opex_or_dep_24m_eur ELSE o.add_opex_or_dep_24m_eur END), 2) AS net_impact_24m_eur,
    ROUND((o.wip_carrying_savings_eur + o.incremental_revenue_eur - (CASE WHEN o.option_name LIKE 'A60%' THEN o.impl_cost_eur + o.add_opex_or_dep_24m_eur ELSE o.add_opex_or_dep_24m_eur END)) * fx.idr_per_unit, 0) AS net_impact_24m_idr
FROM options o
CROSS JOIN baseline b
CROSS JOIN fx_ref_q08 fx;
