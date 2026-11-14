# Production Order-to-Vehicle Delivery — Executable Process Description

**Case:** one manufactured passenger/commercial vehicle production order (not a batch).
**Start:** Production Order Received. **End:** Production Order Closed.
**Event:** one completed activity, with ready, start and finish timestamps.

Typical completed-vehicle path:
Production Order Received → Production Order Validated → {BOM and Routing Released ||
Materials Availability Checked [→ Supplier Shortage Resolved]} → Parts Kitted →
{Body Panels Stamped → Body Welding Completed → Body Dimensional Inspection →
Surface Preparation Completed → Primer Application Completed → Color Coat Applied →
Paint Curing Completed → Paint Defect Inspection [→ Paint Rework Completed] ||
Chassis Assembly Completed} → Powertrain Installed → Electrical Harness Installed →
{Interior Assembly Completed || Software Configuration Loaded → ADAS Calibration Completed} →
Final Torque Verification → End-of-Line Electrical Test → Dynamic Road Test
[→ Vehicle Defect Rectified → Dynamic Road Test (valid repeated activity)] →
Final Quality Gate Approved → Vehicle Wash and Detailing → Vehicle Dispatch Authorized →
Vehicle Delivered → Sales Invoice Posted → Customer Payment Applied
[→ Authorized Sales Credit] → Production Order Closed.

Other end states: Order Cancelled after validation, or Production Scrapped after test.
Some cases genuinely deviate by dispatching without the quality-gate step; investigate as a real control breach.
Each task only becomes ready when its causal predecessors have finished. Staff slots and production facilities
have capacity one; actual waiting arises from constrained labor and equipment queues, not random inserted delays.

**Revenue:** only Vehicle Delivered recognizes sale consideration; explicit Authorized Sales Credit
reduces recognized revenue. Invoicing and cash receipt are distinct events with zero revenue allocation.
Supplier delays and vehicle rework are legitimate operational behavior, not malformed log entries.
