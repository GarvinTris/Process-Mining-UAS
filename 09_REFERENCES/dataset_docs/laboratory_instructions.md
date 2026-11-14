# Automotive Manufacturing Event Data — DuckDB and Celonis Laboratory

## Learning objectives and setup
Use VS Code, DuckDB, SQL and Celonis to identify and repair source-level errors while preserving
valid production variation. Extract the `student/` directory, open that directory as your project
root in VS Code and execute the starter SQL files in file-name order. Do not edit `data/raw_event_log.csv`.
Master files are authoritative. Import raw fields as VARCHAR before changing types.

## Required hands-on activities
1. **Load:** execute `sql/00_import.sql`; examine schema, all columns and imported records.
2. **Profile:** execute and extend `sql/01_data_profiling.sql`; count cases, activities, roles,
   departments, repetitions, blanks, string representations, orphaned identifiers and date variants.
3. **Assess data quality:** classify issues by completeness, uniqueness, consistency, validity,
   accuracy versus clean masters and referential integrity. Record investigative SQL evidence.
4. **Handle repeated event IDs:** distinguish extraction duplicates from legitimate paint/road-test
   rework and overlapping chassis/body activity; repeated case_id+activity need not be incorrect.
5. **Investigate missingness:** join the clean masters where restoration is justified; preserve
   valid optional empties and quarantine irrecoverable core process timestamps.
6. **Standardize categorical fields:** use TRIM, UPPER/LOWER, CASE, NULLIF, COALESCE and JOIN;
   normalize machine, staff and activity identifiers without erasing factory exceptions.
7. **Convert types:** parse all documented day-first timestamps with safe parsing functions;
   convert EUR text to DECIMAL; standardize boolean representations and numeric durations.
8. **Validate time:** enforce ready<=start<end, check computed durations, factory wait times,
   true overlapping subassemblies and valid rework. Long queues are not automatically bad data.
9. **Validate finance:** verify activity_total_cost=sum(cost components); profit_contribution=
   revenue_allocated-activity_total_cost. Recognize sale income once at vehicle delivery;
   do not count the later invoice or cash receipt as additional revenue.
10. **Verify keys:** validate order, vehicle, model, build grade, employee, department, facility,
    workstation and activity mappings. Investigate quality-gate bypass as an actual control concern.
11. **Export:** implement a cleaned table `celonis_event_log_clean` and then enable the commented
    SQL in `sql/04_celonis_export.sql` to write `exports/celonis_event_log_clean.csv`.
12. **Reimport and audit:** re-read the final CSV in DuckDB; confirm consistent UTF-8 structure,
    deterministic order, valid case_id/activity/timestamp, event uniqueness and numeric finance columns.
13. **Celonis:** use your institution's version-specific data import workflow. Map case_id to Case,
    activity to Activity and timestamp to Completion Time. No unverified UI paths are assumed.
14. **Discovery:** find real process variants: full delivery, scrap, cancellation, missing approvals,
    supplier shortages and accepted genuine rework loops.
15. **Performance:** evaluate throughput, station queues, late activity completions and bottlenecks.
16. **Resources:** analyze workforce/machine contention, departmental handovers and bottleneck queues;
    event counts alone do not establish equipment utilization without shift/capacity denominators.
17. **Finance:** compare equipment, material and labor cost by production variant, rework effort,
    sales credits and simulated delivered vehicle contribution.
18. **Process improvement:** propose controlled operational and information-system interventions,
    performance measures, responsible process owners, evidence and risk tradeoffs.

## Assessed submissions
Submit executable DuckDB cleaning SQL, data-quality profiling report, reasoning for transformations,
validation outputs, final Celonis CSV, Celonis discovery and performance results, and prioritized
manufacturing process improvements with accountable owners and metrics.

All product, worker, manufacturer and accounting records are fictional teaching data.
