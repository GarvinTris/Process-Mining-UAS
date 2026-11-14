-- =============================================================================
-- 04_financial_analysis.sql  |  Baseline finansial + asumsi skenario + kurs BI
-- Sumber: celonis_event_log_clean (hasil 02_cleaning.sql, lolos 03_validation.sql). BUKAN raw CSV.
-- Profit Contribution = SUM(revenue_allocated) - SUM(activity_total_cost)  (BUKAN net profit)
-- =============================================================================
-- 01 | Muat file cleaned hasil export (membuktikan re-import) -------------------
CREATE
OR REPLACE TABLE clean_events AS
SELECT
    *
FROM
    read_csv (
        '01_DATA/cleaned/celonis_event_log_clean.csv',
        header = true
    );

CREATE
OR REPLACE VIEW financial_events AS
SELECT
    event_id,
    case_id,
    activity,
    currency,
    CAST(activity_total_cost AS DECIMAL(18, 2)) AS activity_cost,
    CAST(revenue_allocated AS DECIMAL(18, 2)) AS revenue,
    CAST(profit_contribution AS DECIMAL(18, 2)) AS recorded_contribution,
    rework_flag AS is_rework,
    CAST(waiting_time_minutes AS DOUBLE) AS waiting_minutes
FROM
    clean_events;

-- 02 | Validasi finansial sebelum agregasi (semua harus 0 / total = unique) -----
SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT event_id) AS unique_events,
    COUNT(*) FILTER (
        WHERE
            case_id IS NULL
            OR event_id IS NULL
    ) AS missing_identifiers,
    COUNT(*) FILTER (
        WHERE
            activity_cost IS NULL
            OR revenue IS NULL
            OR recorded_contribution IS NULL
    ) AS invalid_financial_rows,
    COUNT(*) FILTER (
        WHERE
            ABS(recorded_contribution - (revenue - activity_cost)) > 0.01
    ) AS inconsistent_contribution_rows
FROM
    financial_events;

-- 03 | Case-level rollup + baseline seluruh dataset ------------------------------
CREATE
OR REPLACE VIEW case_financials AS
SELECT
    case_id,
    COUNT(*) AS total_events,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(activity_cost), 2) AS total_cost,
    ROUND(SUM(revenue) - SUM(activity_cost), 2) AS profit_contribution
FROM
    financial_events
GROUP BY
    case_id;

CREATE
OR REPLACE TABLE financial_baseline AS
SELECT
    COUNT(*) AS total_cases,
    SUM(total_events) AS total_events,
    ROUND(SUM(total_revenue), 2) AS revenue_eur,
    ROUND(SUM(total_cost), 2) AS operational_cost_eur,
    ROUND(SUM(profit_contribution), 2) AS profit_contribution_eur,
    ROUND(SUM(total_cost) / COUNT(*), 2) AS cost_per_case_eur,
    ROUND(SUM(profit_contribution) / COUNT(*), 2) AS contribution_per_case_eur
FROM
    case_financials;

SELECT
    *
FROM
    financial_baseline;

-- 04 | High-cost activity & rework-related cost (screening) ---------------------
SELECT
    activity,
    COUNT(*) AS executions,
    ROUND(SUM(activity_cost), 2) AS total_cost,
    ROUND(AVG(activity_cost), 2) AS avg_cost
FROM
    financial_events
GROUP BY
    activity
ORDER BY
    total_cost DESC
LIMIT
    10;

SELECT
    ROUND(SUM(activity_cost), 2) AS rework_related_cost_eur
FROM
    financial_events
WHERE
    is_rework
    OR activity IN (
        'Paint Rework Completed',
        'Vehicle Defect Rectified'
    );

-- 05 | Kurs BI 13 Oktober 2026 ----------------------------------------------------
CREATE
OR REPLACE VIEW fx_ref AS
SELECT
    currency,
    CAST(reference_idr_per_1_unit AS DECIMAL(20, 6)) AS idr_per_unit
FROM
    read_csv (
        '05_FINANCIAL/exchange_rate.csv',
        header = true,
        all_varchar = true
    )
WHERE
    reference_date = '2026-10-13'
    AND currency = 'EUR';

SELECT
    *
FROM
    fx_ref;

-- 06 | ASUMSI SKENARIO (satu sumber kebenaran; cermin di 05_FINANCIAL/scenario_assumptions.md)
-- Setiap angka bertanda ASSUMPTION = asumsi kelompok, BUKAN hasil dataset. Ubah & dokumentasikan.
CREATE
OR REPLACE TABLE scenario_assumptions AS
SELECT
    *
FROM
    (
        VALUES
            (
                'horizon_months',
                24.0,
                'bulan',
                'DATA',
                'Oktober 2024 - September 2026; As-Is = No-Action pada volume 205 order'
            ),
            (
                'wacc_annual',
                0.08,
                'rasio',
                'ASSUMPTION',
                'Biaya modal untuk nilai-waktu uang & carrying WIP'
            ),
            (
                'q07_reduction_rate',
                0.20,
                'rasio',
                'SOAL Q07',
                'Penurunan avoidable rework 20% (diberikan soal)'
            ),
            (
                'q07_share_paint_rework',
                0.70,
                'rasio',
                'ASSUMPTION',
                'Porsi avoidable Paint Rework (variasi proses paint dapat dikendalikan)'
            ),
            (
                'q07_share_defect_rectify',
                0.50,
                'rasio',
                'ASSUMPTION',
                'Porsi avoidable Vehicle Defect Rectified (sebagian defect genuine/desain/pemasok)'
            ),
            (
                'q07_share_retest',
                0.50,
                'rasio',
                'ASSUMPTION',
                'Road Test ulang mengikuti defect: ikut turun proporsional'
            ),
            (
                'q07_full_impl_cost',
                15000,
                'EUR',
                'ASSUMPTION',
                'Program SPC/inline paint checkpoint: desain prosedur, sensor, pelatihan'
            ),
            (
                'q07_full_extra_inspection_min',
                8.0,
                'menit/kendaraan',
                'ASSUMPTION',
                'Inspeksi tambahan inline pada 196 kendaraan yang melewati paint'
            ),
            (
                'q07_lean_impl_cost',
                2500,
                'EUR',
                'ASSUMPTION',
                'Standard work + checklist + defect Pareto review (pelatihan 40 jam @ ~EUR 60 + materi)'
            ),
            (
                'q07_lean_opex_total',
                1000,
                'EUR',
                'ASSUMPTION',
                'Review mingguan 24 bulan'
            ),
            (
                'q08_resched_impl_cost',
                3000,
                'EUR',
                'ASSUMPTION',
                'SOP release takt 60 menit + papan release; 40 jam planner+engineer'
            ),
            (
                'q08_resched_opex_total',
                1000,
                'EUR',
                'ASSUMPTION',
                'Monitoring planner 24 bulan'
            ),
            (
                'q08_ot_staff_slots',
                4.0,
                'slot',
                'ASSUMPTION',
                '+2 Paint Tech, +1 Press Operator, +1 Assembly Tech selama pekan lonjakan'
            ),
            (
                'q08_ot_hours_per_slot',
                50.0,
                'jam',
                'ASSUMPTION',
                '5 hari x 10 jam lembur per kejadian lonjakan'
            ),
            (
                'q08_ot_premium',
                1.5,
                'x tarif',
                'ASSUMPTION',
                'Premi lembur 1,5x tarif dasar employee_master'
            ),
            (
                'q08_ot_events_in_horizon',
                1.0,
                'kejadian',
                'DATA',
                'Hanya 1 lonjakan terobservasi (28 Apr 2025)'
            ),
            (
                'q08_capex_paint_booth',
                1500000,
                'EUR',
                'ASSUMPTION',
                'Paint booth +1 (indikatif; ganti dengan kuotasi vendor)'
            ),
            (
                'q08_capex_press_line',
                2500000,
                'EUR',
                'ASSUMPTION',
                'Press line +1 (indikatif)'
            ),
            (
                'q08_capex_chassis_line',
                1800000,
                'EUR',
                'ASSUMPTION',
                'Chassis line +1 (indikatif)'
            ),
            (
                'q08_asset_life_years',
                10.0,
                'tahun',
                'ASSUMPTION',
                'Depresiasi garis lurus; beban 24 bulan = capex x 2/10'
            ),
            (
                'q09_target_shortage_rate_high',
                0.12,
                'rasio',
                'ASSUMPTION',
                'Tingkat shortage High complexity diturunkan ke level Low/Medium (11-12%)'
            ),
            (
                'q09_lean_impl_cost',
                3000,
                'EUR',
                'ASSUMPTION',
                'Pre-check ketersediaan BOM saat validasi + alert pemasok (tanpa stok pengaman)'
            ),
            (
                'q09_lean_opex_total',
                1000,
                'EUR',
                'ASSUMPTION',
                'Pemeliharaan alert 24 bulan'
            ),
            (
                'q09_safety_stock_value',
                60000,
                'EUR',
                'ASSUMPTION',
                'Nilai stok pengaman komponen kritis High complexity (risiko stranded inventory)'
            ),
            (
                'q09_holding_rate_annual',
                0.12,
                'rasio',
                'ASSUMPTION',
                'Biaya penyimpanan tahunan stok pengaman'
            ),
            (
                'q09_impl_cost_buffer',
                8000,
                'EUR',
                'ASSUMPTION',
                'Program pemasok + stok pengaman: kontrak call-off, sistem'
            ),
            (
                'r1_intercept_effectiveness',
                0.40,
                'rasio',
                'ASSUMPTION',
                'Porsi cacat unrecoverable yang tertangkap pada checkpoint pasca-harness (tidak ada sinyal data - hipotesis)'
            ),
            (
                'r1_checkpoint_min',
                15.0,
                'menit/kendaraan',
                'ASSUMPTION',
                'Uji fungsional tambahan pasca Electrical Harness'
            ),
            (
                'r1_checkpoint_impl_cost',
                12000,
                'EUR',
                'ASSUMPTION',
                'Fixture uji + prosedur + pelatihan'
            ),
            (
                'r1_relaunch_impl_cost',
                5000,
                'EUR',
                'ASSUMPTION',
                'Aturan ERP: otomatis membuat replacement order saat Production Scrapped'
            ),
            (
                'r1_relaunch_retention',
                0.70,
                'rasio',
                'ASSUMPTION',
                'Porsi pelanggan MTO yang bersedia menunggu kendaraan pengganti'
            ),
            (
                'r2_wip_value_share',
                0.50,
                'rasio',
                'ASSUMPTION',
                'Nilai WIP rata-rata saat menunggu = 50% biaya kumulatif case'
            )
    ) t (param, value, unit, source_type, note);

SELECT
    *
FROM
    scenario_assumptions;
