-- =============================================================================
-- Q10: MANUFACTURING BUSINESS CASE (AS-IS VS NO-ACTION VS TO-BE IN EUR & IDR)
-- Jalankan dari root folder submission kelompok (24SI1_Group02_Automotive / Process-Mining-UAS-main)
-- Sumber: 01_DATA/cleaned/celonis_event_log_clean.csv & 05_FINANCIAL/exchange_rate.csv & scenario_comparison.csv
-- =============================================================================

CREATE OR REPLACE VIEW clean_events_q10 AS
SELECT
    event_id,
    case_id,
    activity,
    currency,
    CAST(activity_total_cost AS DECIMAL(18, 2)) AS activity_cost,
    CAST(revenue_allocated AS DECIMAL(18, 2)) AS revenue,
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y') AS is_rework
FROM read_csv_auto('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);

CREATE OR REPLACE VIEW fx_ref_q10 AS
SELECT
    currency,
    CAST(kurs_jual_bi_idr AS DECIMAL(20, 2)) AS kurs_jual,
    CAST(kurs_beli_bi_idr AS DECIMAL(20, 2)) AS kurs_beli,
    CAST(reference_idr_per_1_unit AS DECIMAL(20, 6)) AS idr_per_unit
FROM read_csv_auto('05_FINANCIAL/exchange_rate.csv', header = true)
WHERE reference_date = '2026-10-13'
  AND currency = 'EUR';

-- 1. Ringkasan Outcome Produksi (Delivered vs Scrapped vs Cancelled/Other)
WITH case_outcomes AS (
    SELECT
        case_id,
        CASE
            WHEN MAX(CASE WHEN activity = 'Vehicle Delivered' THEN 1 ELSE 0 END) = 1 THEN 'Delivered'
            WHEN MAX(CASE WHEN activity = 'Production Scrapped' THEN 1 ELSE 0 END) = 1 THEN 'Scrapped'
            ELSE 'Cancelled / Other'
        END AS outcome,
        SUM(revenue) AS case_revenue_eur,
        SUM(activity_cost) AS case_cost_eur
    FROM clean_events_q10
    GROUP BY case_id
)
SELECT
    outcome,
    COUNT(*) AS total_cases,
    ROUND(SUM(case_revenue_eur), 2) AS total_revenue_eur,
    ROUND(SUM(case_cost_eur), 2) AS total_cost_eur,
    ROUND(SUM(case_revenue_eur) - SUM(case_cost_eur), 2) AS contribution_eur,
    ROUND(AVG(case_revenue_eur), 2) AS avg_revenue_per_case_eur,
    ROUND(AVG(case_cost_eur), 2) AS avg_cost_per_case_eur
FROM case_outcomes
GROUP BY outcome
ORDER BY total_cases DESC;

-- 2. Executive Business Case: As-Is, No-Action, R1 (Scrap Containment), R2 (Paket Lean), R1+R2
WITH baseline AS (
    SELECT
        ROUND(SUM(revenue), 2) AS rev_eur,
        ROUND(SUM(activity_cost), 2) AS cost_eur,
        ROUND(SUM(revenue) - SUM(activity_cost), 2) AS contrib_eur
    FROM clean_events_q10
),
scenarios AS (
    SELECT
        'As-Is (observed, 24 bln, 205 orders)' AS scenario,
        b.rev_eur AS revenue_eur,
        b.cost_eur AS cost_eur
    FROM baseline b
    UNION ALL
    SELECT
        'No-Action (volume & horizon sama dengan As-Is)' AS scenario,
        b.rev_eur AS revenue_eur,
        b.cost_eur AS cost_eur
    FROM baseline b
    UNION ALL
    SELECT
        'To-Be R1: Scrap containment & auto-relaunch' AS scenario,
        ROUND(b.rev_eur + 366777.00, 2) AS revenue_eur,
        ROUND(b.cost_eur + 264802.00, 2) AS cost_eur
    FROM baseline b
    UNION ALL
    SELECT
        'To-Be R2: Paket lean (takt 60 mnt + lean rework)' AS scenario,
        b.rev_eur AS revenue_eur,
        ROUND(b.cost_eur + 681.58, 2) AS cost_eur
    FROM baseline b
    UNION ALL
    SELECT
        'To-Be R1 + R2 (Kombinasi Prioritas)' AS scenario,
        ROUND(b.rev_eur + 366777.00, 2) AS revenue_eur,
        ROUND(b.cost_eur + 265483.58, 2) AS cost_eur
    FROM baseline b
)
SELECT
    s.scenario,
    s.revenue_eur,
    s.cost_eur,
    ROUND(s.revenue_eur - s.cost_eur, 2) AS contribution_eur,
    ROUND((s.revenue_eur - s.cost_eur) - b.contrib_eur, 2) AS delta_vs_no_action_eur,
    ROUND(s.revenue_eur * fx.idr_per_unit, 0) AS revenue_idr,
    ROUND(s.cost_eur * fx.idr_per_unit, 0) AS cost_idr,
    ROUND((s.revenue_eur - s.cost_eur) * fx.idr_per_unit, 0) AS contribution_idr,
    ROUND(((s.revenue_eur - s.cost_eur) - b.contrib_eur) * fx.idr_per_unit, 0) AS delta_vs_no_action_idr
FROM scenarios s
CROSS JOIN baseline b
CROSS JOIN fx_ref_q10 fx;
