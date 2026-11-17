-- =============================================================================
-- Q07: QUALITY IMPROVEMENT SCENARIO (20% AVOIDABLE REWORK REDUCTION)
-- Jalankan dari root folder submission kelompok (24SI1_Group02_Automotive / Process-Mining-UAS-main)
-- Sumber: 01_DATA/cleaned/celonis_event_log_clean.csv & 01_DATA/employee_master.csv & 05_FINANCIAL/exchange_rate.csv
-- =============================================================================

CREATE OR REPLACE VIEW clean_events_q07 AS
SELECT
    event_id,
    case_id,
    activity,
    currency,
    CAST(activity_total_cost AS DECIMAL(18, 2)) AS activity_cost,
    CAST(revenue_allocated AS DECIMAL(18, 2)) AS revenue,
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y') AS is_rework
FROM read_csv_auto('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);

CREATE OR REPLACE VIEW fx_ref_q07 AS
SELECT
    CAST(reference_idr_per_1_unit AS DECIMAL(20, 6)) AS idr_per_unit
FROM read_csv_auto('05_FINANCIAL/exchange_rate.csv', header = true)
WHERE reference_date = '2026-10-13'
  AND currency = 'EUR';

-- 1. Rework Baseline Breakdown per Aktivitas
SELECT
    CASE
        WHEN activity = 'Paint Rework Completed' THEN 'Paint Rework Completed'
        WHEN activity = 'Vehicle Defect Rectified' THEN 'Vehicle Defect Rectified'
        WHEN activity = 'Dynamic Road Test' AND is_rework THEN 'Repeated Dynamic Road Test'
    END AS rework_category,
    COUNT(*) AS rework_events,
    COUNT(DISTINCT case_id) AS affected_cases,
    ROUND(SUM(activity_cost), 2) AS recorded_rework_cost_eur,
    CASE
        WHEN activity = 'Paint Rework Completed' THEN 0.70
        WHEN activity = 'Vehicle Defect Rectified' THEN 0.50
        WHEN activity = 'Dynamic Road Test' AND is_rework THEN 0.50
    END AS avoidable_share,
    ROUND(SUM(activity_cost) * CASE
        WHEN activity = 'Paint Rework Completed' THEN 0.70
        WHEN activity = 'Vehicle Defect Rectified' THEN 0.50
        WHEN activity = 'Dynamic Road Test' AND is_rework THEN 0.50
    END, 2) AS avoidable_base_eur,
    ROUND(SUM(activity_cost) * CASE
        WHEN activity = 'Paint Rework Completed' THEN 0.70
        WHEN activity = 'Vehicle Defect Rectified' THEN 0.50
        WHEN activity = 'Dynamic Road Test' AND is_rework THEN 0.50
    END * 0.20, 2) AS direct_savings_20pct_eur
FROM clean_events_q07
WHERE is_rework
   OR activity IN ('Paint Rework Completed', 'Vehicle Defect Rectified')
GROUP BY 1, 5
ORDER BY recorded_rework_cost_eur DESC;

-- 2. Simulasi What-If Q07: As-Is vs No-Action vs To-Be (Full SPC vs Lean Standard Work)
WITH baseline AS (
    SELECT
        ROUND(SUM(revenue), 2) AS as_is_revenue_eur,
        ROUND(SUM(activity_cost), 2) AS as_is_cost_eur,
        ROUND(SUM(revenue) - SUM(activity_cost), 2) AS as_is_contribution_eur,
        COUNT(DISTINCT CASE WHEN activity IN ('Primer Application Completed', 'Color Coat Applied') THEN case_id END) AS paint_cases,
        ROUND(SUM(CASE
            WHEN activity = 'Paint Rework Completed' THEN activity_cost * 0.70
            WHEN activity = 'Vehicle Defect Rectified' THEN activity_cost * 0.50
            WHEN activity = 'Dynamic Road Test' AND is_rework THEN activity_cost * 0.50
            ELSE 0
        END), 2) AS avoidable_rework_base_eur
    FROM clean_events_q07
),
qc_rate AS (
    SELECT AVG(CAST(hourly_cost_eur AS DECIMAL(18, 4))) AS avg_qc_hourly_eur
    FROM read_csv_auto('01_DATA/employee_master.csv', header = true)
    WHERE employee_role = 'Quality Inspector'
),
scenarios AS (
    SELECT
        'As-Is / No-Action' AS scenario,
        0.00 AS direct_savings_eur,
        0.00 AS impl_cost_eur,
        0.00 AS add_opex_eur
    UNION ALL
    SELECT
        'To-Be Q07-A: Full SPC / Inline Paint Checkpoint' AS scenario,
        ROUND(b.avoidable_rework_base_eur * 0.20, 2) AS direct_savings_eur,
        15000.00 AS impl_cost_eur,
        ROUND(b.paint_cases * (8.0 / 60.0) * q.avg_qc_hourly_eur, 2) AS add_opex_eur
    FROM baseline b CROSS JOIN qc_rate q
    UNION ALL
    SELECT
        'To-Be Q07-B: Lean Standard Work & Defect Pareto' AS scenario,
        ROUND(b.avoidable_rework_base_eur * 0.20, 2) AS direct_savings_eur,
        2500.00 AS impl_cost_eur,
        1000.00 AS add_opex_eur
    FROM baseline b
)
SELECT
    s.scenario,
    b.as_is_contribution_eur,
    s.direct_savings_eur,
    s.impl_cost_eur,
    s.add_opex_eur,
    ROUND(s.direct_savings_eur - s.impl_cost_eur - s.add_opex_eur, 2) AS net_benefit_eur,
    ROUND((s.direct_savings_eur - s.impl_cost_eur - s.add_opex_eur) * fx.idr_per_unit, 0) AS net_benefit_idr,
    ROUND(b.as_is_contribution_eur + s.direct_savings_eur - s.impl_cost_eur - s.add_opex_eur, 2) AS to_be_contribution_eur,
    ROUND((b.as_is_contribution_eur + s.direct_savings_eur - s.impl_cost_eur - s.add_opex_eur) * fx.idr_per_unit, 0) AS to_be_contribution_idr
FROM scenarios s
CROSS JOIN baseline b
CROSS JOIN fx_ref_q07 fx;
