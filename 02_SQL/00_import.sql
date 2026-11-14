-- =============================================================================
-- 00_import.sql  |  24SI1 Group 02  |  Rheinwerk Automotive Assembly
-- Cara jalan (dari ROOT folder submission, urut nama file):
--     duckdb 02_SQL/rheinwerk.duckdb -f 02_SQL/00_import.sql
--     duckdb 02_SQL/rheinwerk.duckdb -f 02_SQL/01_profiling.sql   ... dst.
-- (atau di VS Code: satu sesi DuckDB, jalankan file berurutan)
-- Prinsip: raw CSV TIDAK diubah; semua kolom event log dimuat sebagai VARCHAR.
-- =============================================================================

CREATE OR REPLACE TABLE raw_events AS
SELECT * FROM read_csv('01_DATA/raw/raw_event_log.csv',
                       header = true, all_varchar = true);

-- Master data (authoritative) - juga dimuat sebagai VARCHAR agar tidak ada koersi diam-diam
CREATE OR REPLACE TABLE case_master          AS SELECT * FROM read_csv('01_DATA/raw/case_master.csv',          header=true, all_varchar=true);
CREATE OR REPLACE TABLE employee_master      AS SELECT * FROM read_csv('01_DATA/raw/employee_master.csv',      header=true, all_varchar=true);
CREATE OR REPLACE TABLE resource_master      AS SELECT * FROM read_csv('01_DATA/raw/resource_master.csv',      header=true, all_varchar=true);
CREATE OR REPLACE TABLE facility_master      AS SELECT * FROM read_csv('01_DATA/raw/facility_master.csv',      header=true, all_varchar=true);
CREATE OR REPLACE TABLE department_master    AS SELECT * FROM read_csv('01_DATA/raw/department_master.csv',    header=true, all_varchar=true);
CREATE OR REPLACE TABLE activity_catalog     AS SELECT * FROM read_csv('01_DATA/raw/activity_catalog.csv',     header=true, all_varchar=true);
CREATE OR REPLACE TABLE vehicle_model_master AS SELECT * FROM read_csv('01_DATA/raw/vehicle_model_master.csv', header=true, all_varchar=true);
CREATE OR REPLACE TABLE trim_grade_master    AS SELECT * FROM read_csv('01_DATA/raw/trim_grade_master.csv',    header=true, all_varchar=true);

-- Ringkasan impor
SELECT 'raw_events' AS tabel, COUNT(*) AS baris FROM raw_events
UNION ALL SELECT 'case_master',       COUNT(*) FROM case_master
UNION ALL SELECT 'employee_master',   COUNT(*) FROM employee_master
UNION ALL SELECT 'resource_master',   COUNT(*) FROM resource_master
UNION ALL SELECT 'facility_master',   COUNT(*) FROM facility_master
UNION ALL SELECT 'department_master', COUNT(*) FROM department_master
UNION ALL SELECT 'activity_catalog',  COUNT(*) FROM activity_catalog
UNION ALL SELECT 'vehicle_model_master', COUNT(*) FROM vehicle_model_master
UNION ALL SELECT 'trim_grade_master', COUNT(*) FROM trim_grade_master;

DESCRIBE raw_events;
