-- =========================================================================
-- STAGING & NORMALISASI
-- =========================================================================
CREATE
OR REPLACE VIEW cleaning_workspace AS
SELECT
    *
FROM
    read_csv ('01_DATA/raw/raw_event_log.csv', header = true);

CREATE
OR REPLACE TABLE clean_events AS
SELECT
    TRIM(event_id) AS event_id,
    TRIM(case_id) AS case_id,
    TRIM(activity) AS activity,
    TRIM(resource_id) AS resource_id,
    TRIM(department_id) AS department_id,
    TRIM(facility_id) AS facility_id,
    TRIM(trim_grade) AS trim_grade,
    TRIM(model_name) AS model_name,
    COALESCE(
        TRY_CAST (timestamp AS TIMESTAMP),
        CAST(NULL AS TIMESTAMP)
    ) AS parsed_timestamp,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(labor_cost AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS labor_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(material_cost AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS material_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(equipment_cost AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS equipment_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(overhead_cost AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS overhead_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(activity_total_cost AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS activity_cost,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(revenue_allocated AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS revenue,
    TRY_CAST (
        REPLACE (
            REPLACE (
                COALESCE(CAST(profit_contribution AS VARCHAR), '0'),
                'EUR',
                ''
            ),
            ' ',
            ''
        ) AS DECIMAL(18, 2)
    ) AS recorded_contribution,
    LOWER(TRIM(CAST(rework_flag AS VARCHAR))) IN ('true', '1', 'yes', 'y') AS is_rework,
    TRY_CAST (waiting_time_minutes AS DOUBLE) AS waiting_minutes,
    LOWER(TRIM(activity_status)) AS activity_status,
    LOWER(TRIM(sla_violation)) IN ('true', '1', 'yes', 'y') AS sla_violation,
    TRIM(case_type) AS case_type,
    TRIM(case_priority) AS case_priority,
    TRIM(case_complexity) AS case_complexity,
    TRIM(location) AS location,
    TRIM(vehicle_id) AS vehicle_id,
    activity_start_time,
    activity_end_time
FROM
    cleaning_workspace;

CREATE
OR REPLACE VIEW financial_events AS
SELECT
    *
FROM
    clean_events;

-- =========================================================================
-- DATA VALIDATION (Sesuai Panduan Halaman 11)
-- =========================================================================
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
    ) AS inconsistent_contribution_rows,
    COUNT(*) FILTER (
        WHERE
            TRY_CAST (activity_start_time AS TIMESTAMP) > TRY_CAST (activity_end_time AS TIMESTAMP)
    ) AS invalid_time_sequence
FROM
    financial_events;

-- =========================================================================
-- MEMBUAT TABEL FINAL BERSIH
-- =========================================================================
CREATE
OR REPLACE TABLE celonis_event_log_clean AS
SELECT
    event_id,
    case_id,
    activity AS "Activity",
    parsed_timestamp AS "Timestamp",
    resource_id AS "Resource",
    department_id AS "Department",
    facility_id AS "Facility",
    model_name AS "Vehicle Model",
    trim_grade AS "Trim Grade",
    labor_cost,
    material_cost,
    equipment_cost,
    overhead_cost,
    activity_cost AS activity_total_cost,
    revenue AS revenue_allocated,
    recorded_contribution AS profit_contribution,
    activity_status,
    sla_violation,
    is_rework AS rework_flag,
    CASE
        WHEN activity LIKE '%Inspection%'
        AND activity_status = 'bypassed' THEN 1
        ELSE 0
    END AS qc_bypass_flag,
    case_type,
    case_priority,
    case_complexity,
    location,
    vehicle_id
FROM
    financial_events
WHERE
    parsed_timestamp IS NOT NULL
    AND case_id IS NOT NULL
    AND activity IS NOT NULL;

-- =========================================================================
-- EKSPOR KE FOLDER `cleaned`
-- =========================================================================
COPY (
    SELECT
        *
    FROM
        celonis_event_log_clean
    ORDER BY
        case_id,
        Timestamp,
        event_id
) TO '01_DATA/raw/cleaned/celonis_event_log_clean.csv' (HEADER TRUE, DELIMITER ',');