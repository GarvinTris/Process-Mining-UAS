# Synthetic Automotive Manufacturer — Student Context

Rheinwerk Automotive Assembly is fictional and makes four simulated product types: Urban EV,
Touring Hybrid, Executive EV and Cargo Utility. Each case identifies one unique fictitious vehicle and
production order. Operations span production planning, inbound logistics, stamping, welding, paint,
assembly, quality, rework, outbound logistics and finance.

The event log is an intentionally imperfect extract from several transactional systems. Clean master
data are authoritative for master identifiers, departments, workstation assignments, activities and
model attributes. Some apparently unusual source transactions are genuine; preserve evidence.

Production-order arrivals span October 2024 through September 2026. Cases are completed in the simulation,
even when downstream manufacturing events fall after the end of the arrival window.
All monetary figures are synthetic EUR values with two decimal places, representing materials, labor,
plant equipment and allocated overhead plus illustrative sales consideration. Results are not factory benchmarks.
**Timezone:** UTC. Canonical timestamps have no offset, and any DD/MM/YYYY format is always day-first.
**Event granularity:** a row is a completed execution of one activity; there is no separate start-event row.
