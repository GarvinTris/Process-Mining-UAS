-- =============================================================================
-- Q09: MATERIAL FLOW OPTIMIZATION (SHORTAGE & PARTS KITTING)
-- Jalankan dari root folder submission kelompok (24SI1_Group02_Automotive / Process-Mining-UAS-main)
-- Sumber: 01_DATA/cleaned/celonis_event_log_clean.csv & 05_FINANCIAL/exchange_rate.csv
-- =============================================================================

CREATE OR REPLACE VIEW clean_events_q09 AS
SELECT
    event_id,
    case_id,
    activity,
    case_complexity,
    CAST(activity_start_time AS TIMESTAMP) AS start_ts,
    CAST(activity_end_time AS TIMESTAMP) AS end_ts,
    CAST(activity_total_cost AS DECIMAL(18, 2)) AS activity_cost,
    CAST(revenue_allocated AS DECIMAL(18, 2)) AS revenue
FROM read_csv_auto('01_DATA/cleaned/celonis_event_log_clean.csv', header = true);

CREATE OR REPLACE VIEW fx_ref_q09 AS
SELECT
    CAST(reference_idr_per_1_unit AS DECIMAL(20, 6)) AS idr_per_unit
FROM read_csv_auto('05_FINANCIAL/exchange_rate.csv', header = true)
WHERE reference_date = '2026-10-13'
  AND currency = 'EUR';

-- 1. Segmentasi Shortage berdasarkan Case Complexity
WITH case_agg AS (
    SELECT
        case_id,
        MAX(case_complexity) AS case_complexity,
        MAX(CASE WHEN activity = 'Supplier Shortage Resolved' THEN 1 ELSE 0 END) AS has_shortage,
        MAX(CASE WHEN activity = 'Vehicle Delivered' THEN 1 ELSE 0 END) AS is_delivered,
        SUM(activity_cost) AS case_cost,
        SUM(revenue) AS case_revenue,
        DATE_DIFF('minute', MIN(start_ts), MAX(end_ts)) / 60.0 AS lead_time_hours
    FROM clean_events_q09
    GROUP BY case_id
)
SELECT
    case_complexity,
    has_shortage,
    COUNT(*) AS total_cases,
    SUM(is_delivered) AS delivered_cases,
    ROUND(AVG(case_cost), 2) AS avg_case_cost_eur,
    ROUND(MEDIAN(lead_time_hours), 2) AS median_lead_time_hours
FROM case_agg
GROUP BY case_complexity, has_shortage
ORDER BY case_complexity, has_shortage;

-- 2. Simulasi What-If Q09: Menurunkan Shortage Rate High Complexity ke Target 12%
WITH shortage_stats AS (
    SELECT
        COUNT(*) AS shortage_events,
        COUNT(DISTINCT case_id) AS shortage_cases,
        ROUND(SUM(activity_cost), 2) AS total_shortage_resolution_cost_eur
    FROM clean_events_q09
    WHERE activity = 'Supplier Shortage Resolved'
),
high_complex AS (
    SELECT
        COUNT(DISTINCT case_id) AS total_high_cases,
        COUNT(DISTINCT CASE WHEN activity = 'Supplier Shortage Resolved' THEN case_id END) AS high_shortage_cases
    FROM clean_events_q09
    WHERE case_complexity = 'High'
),
calc AS (
    SELECT
        s.total_shortage_resolution_cost_eur,
        s.shortage_cases,
        ROUND(s.total_shortage_resolution_cost_eur / s.shortage_cases, 2) AS avg_cost_per_shortage_case_eur,
        h.total_high_cases,
        h.high_shortage_cases,
        ROUND(h.total_high_cases * 0.12, 0) AS target_high_shortage_cases,
        GREATEST(0, h.high_shortage_cases - ROUND(h.total_high_cases * 0.12, 0)) AS avoided_shortage_cases,
        ROUND(GREATEST(0, h.high_shortage_cases - ROUND(h.total_high_cases * 0.12, 0)) * (s.total_shortage_resolution_cost_eur / s.shortage_cases), 2) AS direct_shortage_savings_eur
    FROM shortage_stats s CROSS JOIN high_complex h
),
options AS (
    SELECT
        'Q09-A: Lean Material Planning (BOM Pre-check + Alert)' AS option_name,
        c.direct_shortage_savings_eur,
        3000.00 AS impl_cost_eur,
        1000.00 AS add_opex_24m_eur
    FROM calc c
    UNION ALL
    SELECT
        'Q09-B: Safety Stock Buffer (EUR 60k, 12%/yr holding 24 bln)' AS option_name,
        c.direct_shortage_savings_eur,
        8000.00 AS impl_cost_eur,
        ROUND(60000.00 * 0.12 * 2.0, 2) AS add_opex_24m_eur
    FROM calc c
)
SELECT
    o.option_name,
    o.direct_shortage_savings_eur,
    o.impl_cost_eur,
    o.add_opex_24m_eur,
    ROUND(o.direct_shortage_savings_eur - o.impl_cost_eur - o.add_opex_24m_eur, 2) AS net_benefit_eur,
    ROUND((o.direct_shortage_savings_eur - o.impl_cost_eur - o.add_opex_24m_eur) * fx.idr_per_unit, 0) AS net_benefit_idr
FROM options o
CROSS JOIN fx_ref_q09 fx;
