# Q08 — Production Bottleneck Capacity

**Pertanyaan:** Bandingkan *rescheduling*, *overtime staffing*, dan *equipment investment* untuk bottleneck utama. Rancang To-Be dengan estimasi efek pada Throughput Time, Additional Cost, dan *realized production contribution* bila demand mendukung.

---

## 01 Evidence & Data Source
- **Sumber Data:** `01_DATA/cleaned/celonis_event_log_clean.csv`, `01_DATA/employee_master.csv`, `05_FINANCIAL/capacity_simulation_results.csv`, dan `05_FINANCIAL/exchange_rate.csv` (1 EUR = Rp 20.052,255 per 13 Oktober 2026).
- **Temuan Bottleneck Aktual (Clean Event Log):**
  - Total *waiting time*: **171.066 menit (2.851,1 jam)** dengan **277 SLA violations** pada replay baseline (simulasi S0: 2.967 jam wait / 316 SLA violations).
  - Stasiun dengan *waiting time* tertinggi: **Color Coat Applied** (41.517 mnt, 51 SLA), **Primer Application Completed** (35.151 mnt, 44 SLA), **Body Panels Stamped** (31.709 mnt, 49 SLA), dan **Chassis Assembly Completed** (22.416 mnt, 38 SLA).
  - **Pola Lonjakan (Surge Arrival):** Puncak kedatangan terjadi pada **28 April 2025** dengan **65 kasus aktif bersamaan** (diikuti 63 kasus pada 29 April 2025), memicu antrean massal di *Paint Booth* (1.194 jam), *Press Line* (553 jam), dan *Chassis Line* (390 jam).

---

## 02 Descriptive Finding
Perbandingan tiga skenario intervensi kapasitas berdasarkan `capacity_simulation_results.csv` dan `employee_master.csv`:

| Opsi Kapasitas | Wait Time (Jam) | Perubahan Wait | SLA Violations | Surge Flow Inside Plant | Biaya Implementasi + OpEx/Depresiasi 24 Bln (EUR) | Biaya dalam IDR |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| S0: Baseline (As-Is / No-Action) | 2.967 | — | 316 | 2,38 hari | €0,00 | Rp 0 |
| **A60: Rescheduling (Takt 60 menit)** | **257** | **−91,3%** | **0** | **0,92 hari** | **€4.000,00** (€3.000 + €1.000) | **Rp 80.209.020** |
| B2: Overtime Staffing (+2 Paint, +1 Press, +1 Assembly) | 2.950 | −0,6% | 317 | 2,37 hari | €13.953,15 (50 jam × 1,5× tarif) | Rp 279.792.119 |
| C1: Equipment (+1 Paint Booth) | 2.690 | −9,3% | 289 | 2,20 hari | €1.500.000 CapEx (€300.000 dep. 24 bln) | Rp 6.015.676.500 (dep.) |
| C3: Equipment (+1 Press, +1 Paint, +1 Chassis) | 2.101 | −29,2% | 244 | 1,96 hari | €5.800.000 CapEx (€1.160.000 dep. 24 bln) | Rp 23.260.615.800 (dep.) |

---

## 03 Diagnostic Reasoning
Mengapa *Overtime Staffing* (B2) hampir tidak berpengaruh (−0,6% wait) dan *Equipment Investment* (C1/C3) sangat tidak efisien? Karena bottleneck utama disebabkan oleh **lonjakan kedatangan (*batch surge*) pada 28 April 2025** yang langsung membanjiri stasiun dengan jumlah sel fisik terbatas (*Paint Booth*). Menambah operator lembur tidak menambah jumlah bilik cat (*booth*), sedangkan membeli bilik/mesin baru bernilai jutaan euro hanya untuk meredam satu kali lonjakan dalam 24 bulan menghasilkan utilisasi aset yang sangat rendah. Sebaliknya, **Rescheduling (pelepasan order bertahap setiap 60 menit / takt 60 menit)** menyamakan laju masuk dengan kapasitas *Paint Booth*, memangkas *waiting time* 91,3% dan menghilangkan seluruh 316 SLA violations.

---

## 04 Business & Financial Implication
Berdasarkan cleaned dataset, As-Is Contribution sebesar **€1.588.674,92** (Rp 31.856.514.608).
- **Rescheduling (A60):** Membutuhkan biaya €4.000,00 (€3.000 SOP & papan *release* + €1.000 monitoring 24 bulan). Penurunan waktu tunggu internal menghasilkan estimasi penghematan *WIP carrying cost* ~**€389,00** (asumsi 50% nilai WIP × WACC 8%), sehingga dampak finansial bersih pada volume tetap (205 order) adalah **−€3.611,00** (−Rp 72.408.693).
- **Realized Production Contribution bila demand mendukung:** Pengurangan *waiting time* dan *throughput time* **bukan otomatis *cash savings*** maupun tambahan penjualan. Tambahan kontribusi sebesar **~€10.628,55 per kendaraan tambahan** (€37.426,19 rata-rata revenue − €26.797,64 rata-rata cost per *delivered vehicle*) hanya dapat terealisasi apabila terdapat **unfulfilled customer demand** dan pasokan material (*Parts Kitting*) mendukung.
- **Overtime (B2) & Equipment (C1/C3):** Membebani biaya €13.953,15 (B2) hingga €300.000–€1.160.000 depresiasi 24 bulan (C1/C3) tanpa menyelesaikan akar masalah antrean *surge*.

---

## 05 As-Is vs No-Action vs To-Be

| Skenario | Wait Time (Jam) | SLA Violations | Additional Cost 24 Bln (EUR) | WIP Savings (EUR) | Net Financial Impact (EUR) | Net Financial Impact (IDR) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| As-Is / No-Action | 2.967 | 316 | €0,00 | €0,00 | €0,00 | Rp 0 |
| **To-Be A60: Rescheduling (Rekomendasi)** | **257** | **0** | **€4.000,00** | **€389,00** | **−€3.611,00** | **−Rp 72.408.693** |
| To-Be B2: Overtime Staffing | 2.950 | 317 | €13.953,15 | €0,00 | −€13.953,15 | −Rp 279.792.119 |
| To-Be C1: +1 Paint Booth (Dep. 24 bln) | 2.690 | 289 | €300.000,00 | €0,00 | −€300.000,00 | −Rp 6.015.676.500 |

Jika tidak ada tindakan (**No-Action**), pabrik tetap rentan terhadap *surge bottleneck* di *Paint Booth* dan *Press Line*, mempertahankan ~2.851–2.967 jam antrean dan ratusan pelanggaran SLA.

---

## 06 Recommendation, Risk, Assumptions
- **Rekomendasi:** Terapkan **To-Be A60 (Release Smoothing dengan Takt 60 Menit)** melalui penjadwalan ERP/MES. Tolak penambahan *equipment* (C1/C3) dan *overtime* reaktif (B2) selama volume masih ~205 order per 24 bulan.
- **Asumsi:** Tarif lembur 1,5× tarif dasar `employee_master.csv` (Paint Tech €49,26/jam, Press Op €43,01/jam, Assembly Tech €44,52/jam); umur ekonomis mesin 10 tahun garis lurus; WACC 8%/tahun pada 50% nilai WIP; tidak ada tambahan demand di luar 205 order pada baseline.
- **Risiko & Batasan:** *Release smoothing* memindahkan antrean dari lantai pabrik ke *order backlog* sebelum rilis; jika pelanggan menuntut *lead time* dari tanggal pemesanan tanpa toleransi antrean rilis, perlu koordinasi *delivery promise* dengan tim komersial.

---

## 07 Evidence File Paths / SQL References
- **SQL Query:** `02_SQL/queries_by_question/Q8.sql` dan `02_SQL/04_financial_analysis.sql`
- **Celonis Evidence Folder:** `03_CELONIS_EVIDENCE/Q08/`
- **Simulation & Financial Files:** `05_FINANCIAL/capacity_simulation_results.csv`, `05_FINANCIAL/exchange_rate.csv`, `05_FINANCIAL/scenario_assumptions.md`
