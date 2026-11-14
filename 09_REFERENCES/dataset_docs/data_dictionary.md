# Student Data Dictionary — Vehicle Production Events

Raw CSV: UTF-8, comma delimiter, one header row. Load all raw columns as text initially.
**Timestamps:** UTC, canonical `YYYY-MM-DD HH:MM:SS`. Allowed raw variants: `YYYY/MM/DD HH:MM:SS`, `DD/MM/YYYY HH:MM`.
**Always day-first** when a numeric date starts with the day; month-first dates are not used.
**Money:** EUR decimal point, 2 digits after decimal, no symbol or group separator in clean data.
**Boolean:** canonical true/false; raw representations may use Yes/No, Y/N, 1/0, TRUE/FALSE.
**Optional blanks:** exception_type without exception and facility_id when no machine is needed are valid.

| Column | Intended type | Description |
|---|---|---|
| raw_row_id | VARCHAR | Unique raw extract row ID assigned after source duplicates were interleaved; audit join key. |
| event_id | VARCHAR | Unique identifier of one activity execution. Repeated normalized event_id across raw rows means a repeated source record. |
| case_id | VARCHAR | Unique case identifier for a single vehicle production order. |
| activity | VARCHAR | Business operation; use the authoritative activity catalog. |
| activity_start_time | TIMESTAMP | Real execution start of the task. |
| activity_end_time | TIMESTAMP | Real task completion time. |
| timestamp | TIMESTAMP | Event timestamp, equal to activity_end_time after normalization. |
| activity_ready_time | TIMESTAMP | Time prerequisites completed and the activity first became eligible for queueing. |
| department_id | VARCHAR | Department master identifier. |
| department | VARCHAR | Canonical performing department name. |
| employee_id | VARCHAR | Unique simulated employee duty-slot ID, see employee master. |
| employee_role | VARCHAR | Skill/role required by activity. |
| resource_id | VARCHAR | Tool/workstation tied to an employee duty slot. |
| resource_type | VARCHAR | Employee workstation/toolkit classification. |
| organizational_unit | VARCHAR | Parent organizational division. |
| facility_id | VARCHAR | Exclusive factory machine/bay identifier; intentionally blank for tasks not requiring one. |
| activity_duration_minutes | DECIMAL(18,2) | Elapsed processing minutes, measured between start and end. |
| waiting_time_minutes | DECIMAL(18,2) | Elapsed queued minutes, from ready to start. |
| case_elapsed_time_minutes | DECIMAL(18,2) | Elapsed minutes from original production-order arrival to this task completion. |
| activity_sla_minutes | INTEGER | Task ready-to-completion target in elapsed minutes. |
| sla_violation | BOOLEAN | True when waiting plus execution duration exceeds activity SLA. |
| rework_flag | BOOLEAN | True for legitimate repeated business activity; repeated work has its own event_id. |
| activity_status | VARCHAR | Completion status for the recorded execution. |
| labor_cost | DECIMAL(18,2) | EUR direct labor consumption for one activity. |
| material_cost | DECIMAL(18,2) | EUR components consumed for one activity. |
| equipment_cost | DECIMAL(18,2) | EUR machine/workstation use charge. |
| overhead_cost | DECIMAL(18,2) | EUR allocated factory overhead. |
| activity_total_cost | DECIMAL(18,2) | Sum of labor + materials + equipment + overhead. |
| revenue_allocated | DECIMAL(18,2) | EUR revenue recognition, positive only at vehicle delivery, except valid negative adjustments. |
| profit_contribution | DECIMAL(18,2) | Revenue allocated minus activity cost. |
| currency | VARCHAR | ISO 4217 code, EUR. |
| case_type | VARCHAR | Initial production order case type. |
| case_priority | VARCHAR | Scheduling priority used at the time of arrival. |
| case_complexity | VARCHAR | Complexity category driving task durations and material cost. |
| location | VARCHAR | Synthetic plant name. |
| production_order_id | VARCHAR | Unique manufacturing order identifier. |
| vehicle_id | VARCHAR | Synthetic vehicle identification key, not an actual VIN. |
| model_name | VARCHAR | Vehicle model, see vehicle_model_master. |
| trim_grade | VARCHAR | Build grade, see trim_grade_master. Unknown is a valid grade category. |
| exception_flag | BOOLEAN | True for real operational exception, not automatically a data-quality error. |
| exception_type | VARCHAR | Optional exception label. Empty is valid when no exception occurred. |
