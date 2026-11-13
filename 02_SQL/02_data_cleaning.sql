-- Student work area: expand with your own documented SQL repairs; no answers supplied.
CREATE
OR REPLACE VIEW cleaning_workspace AS
SELECT
    *
FROM
    raw_events;

SELECT
    COUNT(*) AS work_records
FROM
    cleaning_workspace;

-- =========================================================================
-- LANGKAH 1: STAGING & NORMALISASI
-- =========================================================================
CREATE
OR REPLACE VIEW staging_normalized AS
SELECT DISTINCT
    TRIM(event_id) AS event_id,
    TRIM(case_id) AS case_id,
    TRIM(activity) AS activity_name_raw,
    TRIM(resource_id) AS resource_id,
    TRIM(department_id) AS department_id,
    TRIM(facility_id) AS facility_id,
    TRIM(trim_grade) AS trim_grade,
    TRIM(model_name) AS model_name,
    -- Memperbaiki format strptime menggunakan %M untuk menit di DuckDB
    COALESCE(
        TRY_CAST (timestamp AS TIMESTAMP),
        TRY_CAST (
            strptime (timestamp, '%d-%m-%Y %H:%M:%S') AS TIMESTAMP
        ),
        TRY_CAST (
            strptime (timestamp, '%m/%d/%Y %H:%M') AS TIMESTAMP
        ),
        TRY_CAST (
            strptime (timestamp, '%d/%m/%Y %H:%M:%S') AS TIMESTAMP
        ),
        CAST(NULL AS TIMESTAMP)
    ) AS parsed_timestamp,
    -- Parsing kolom finansial (EUR)
    CAST(
        REPLACE (
            REPLACE (COALESCE(labor_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS labor_cost,
    CAST(
        REPLACE (
            REPLACE (COALESCE(material_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS material_cost,
    CAST(
        REPLACE (
            REPLACE (COALESCE(equipment_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS equipment_cost,
    CAST(
        REPLACE (
            REPLACE (COALESCE(overhead_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS overhead_cost,
    CAST(
        REPLACE (
            REPLACE (COALESCE(activity_total_cost, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS activity_total_cost,
    CAST(
        REPLACE (
            REPLACE (COALESCE(revenue_allocated, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS revenue,
    CAST(
        REPLACE (
            REPLACE (COALESCE(profit_contribution, '0'), 'EUR', ''),
            ' ',
            ''
        ) AS DECIMAL(10, 2)
    ) AS profit_contribution,
    LOWER(TRIM(activity_status)) AS activity_status,
    CASE
        WHEN UPPER(TRIM(sla_violation)) IN ('TRUE', '1', 'YES') THEN 1
        ELSE 0
    END AS sla_violation,
    CASE
        WHEN UPPER(TRIM(rework_flag)) IN ('TRUE', '1', 'YES') THEN 1
        ELSE 0
    END AS rework_flag,
    TRIM(case_type) AS case_type,
    TRIM(case_priority) AS case_priority,
    TRIM(case_complexity) AS case_complexity,
    TRIM(location) AS location,
    TRIM(vehicle_id) AS vehicle_id
FROM
    cleaning_workspace;

-- =========================================================================
-- LANGKAH 2: LOAD MASTER & RECOVER MAPPINGS
-- =========================================================================
CREATE
OR REPLACE VIEW enriched_event_log AS
SELECT
    s.*,
    COALESCE(ac.business_description, s.activity_name_raw) AS activity_name,
    COALESCE(rm.resource_type, s.resource_id) AS resource_name,
    COALESCE(dm.department, s.department_id) AS department_name,
    COALESCE(fm.facility_type, s.facility_id) AS facility_name,
    COALESCE(vm.description, s.model_name) AS vehicle_model_name,
    COALESCE(tg.description, s.trim_grade) AS trim_grade_name
FROM
    staging_normalized s
    LEFT JOIN activity_catalog ac ON s.activity_name_raw = ac.activity
    LEFT JOIN resource_master rm ON s.resource_id = rm.resource_id
    LEFT JOIN department_master dm ON s.department_id = dm.department_id
    LEFT JOIN facility_master fm ON s.facility_id = fm.facility_id
    LEFT JOIN vehicle_model_master vm ON s.model_name = vm.model_name
    LEFT JOIN trim_grade_master tg ON s.trim_grade = tg.trim_grade;

-- =========================================================================
-- LANGKAH 3: QUARANTINE DATA INVALID
-- =========================================================================
CREATE TABLE IF NOT EXISTS event_log_quarantine AS
SELECT
    *
FROM
    enriched_event_log
WHERE
    parsed_timestamp IS NULL
    OR case_id IS NULL
    OR activity_name_raw IS NULL;

-- =========================================================================
-- LANGKAH 4: MEMBUAT TABEL AKHIR `celonis_event_log_clean`
-- =========================================================================
CREATE
OR REPLACE TABLE celonis_event_log_clean AS
SELECT
    event_id,
    case_id,
    activity_name_raw AS "Activity",
    parsed_timestamp AS "Timestamp",
    resource_name AS "Resource",
    department_name AS "Department",
    facility_name AS "Facility",
    vehicle_model_name AS "Vehicle Model",
    trim_grade_name AS "Trim Grade",
    labor_cost,
    material_cost,
    equipment_cost,
    overhead_cost,
    activity_total_cost,
    revenue,
    profit_contribution,
    activity_status,
    sla_violation,
    rework_flag,
    CASE
        WHEN activity_name_raw LIKE '%Inspection%'
        AND activity_status = 'bypassed' THEN 1
        ELSE 0
    END AS qc_bypass_flag,
    case_type,
    case_priority,
    case_complexity,
    location,
    vehicle_id
FROM
    enriched_event_log
WHERE
    parsed_timestamp IS NOT NULL
    AND case_id IS NOT NULL
    AND activity_name_raw IS NOT NULL;