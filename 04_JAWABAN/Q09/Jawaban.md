# Q09 — Material Flow Optimization

**Pertanyaan:** Modelkan *Material Planning / Parts Kitting improvement* untuk mengurangi *shortage waiting* atau *rush delivery*. Hitung *financial impact* yang dapat dipertanggungjawabkan dan jelaskan syarat realisasi tambahan kendaraan selesai.

---

## 01 Evidence & Data Source
- **Sumber Data:** `01_DATA/cleaned/celonis_event_log_clean.csv` (205 cases) dan `05_FINANCIAL/exchange_rate.csv` (1 EUR = Rp 20.052,255 per 13 Oktober 2026).
- **Baseline Shortage (`Supplier Shortage Resolved`):**
  - Total kasus terdampak: **38 unique cases** dari 205 cases (18,54%), dengan total **Recorded Shortage-Resolution Cost = €3.280,22** (Rp 65.775.808), atau rata-rata **€86,32 per kasus shortage**.
  - Segmentasi berdasarkan `case_complexity`:

| Case Complexity | Status Shortage | Cases | Delivered | Shortage Rate | Avg Cost / Case (EUR) | Median Lead Time (Jam) |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| **High** | Without Shortage | 38 | 32 | — | €29.247,54 | 27,78 |
| **High** | **With Shortage** | **21** | **19** | **35,59%** (21/59) | **€33.201,17** | **28,98** |
| Medium | Without Shortage | 87 | 78 | — | €24.657,05 | 17,27 |
| Medium | With Shortage | 11 | 10 | 11,22% (11/98) | €24.828,26 | 17,33 |
| Low | Without Shortage | 42 | 37 | — | €20.652,72 | 14,21 |
| Low | With Shortage | 6 | 6 | 12,50% (6/48) | €21.428,73 | 14,00 |

---

## 02 Descriptive Finding
Kasus dengan kompleksitas **High** memiliki *shortage rate* **35,59%** (21 dari 59 kasus)—lebih dari tiga kali lipat dibandingkan kompleksitas Medium (11,22%) dan Low (12,50%). Jika *shortage rate* pada segmen High diturunkan ke level normal **12,00%** (target ~7 kasus dari 59), maka **14 kasus shortage dapat dihindari**. Secara langsung, biaya resolusi shortage yang dapat dihemat (*avoidable shortage-resolution cost*) adalah `14 × €86,32` = **€1.208,50** (Rp 24.233.150).

---

## 03 Diagnostic Reasoning
Selisih total biaya per kasus antara kelompok shortage dan non-shortage pada segmen High (€3.953,63) bersifat **asosiatif/observasional** karena kompleksitas komponen dan varian kendaraan turut memengaruhi biaya dasar—bukan seluruhnya biaya yang otomatis hilang jika shortage dicegah. Oleh karena itu, secara akuntabel (*financial integrity*), *direct cost savings* hanya boleh dihitung dari biaya resolusi shortage yang tercatat (€1.208,50), bukan dari seluruh selisih rata-rata biaya kasus. Penyebab utama tingginya shortage pada varian High adalah ketidakakuratan sinkronisasi BOM (*Bill of Materials*) sebelum *Parts Kitting* dan keterlambatan visibilitas pemasok.

---

## 04 Business & Financial Implication
Membandingkan dua opsi perbaikan aliran material selama 24 bulan:
1. **Opsi Q09-A (Lean Material Planning — BOM Pre-check & Supplier Alert tanpa Safety Stock):**
   - Biaya Implementasi: €3.000,00; OpEx pemeliharaan alert 24 bulan: €1.000,00 (Total Biaya = **€4.000,00**).
   - Direct Cost Savings: **€1.208,50**.
   - **Net Financial Benefit = −€2.791,50** (−Rp 55.975.870), namun **tidak menambah *stranded inventory***.
2. **Opsi Q09-B (Safety Stock Buffer — €60.000 stok komponen kritis High complexity):**
   - Biaya Implementasi (kontrak *call-off* & sistem): €8.000,00; *Holding Cost* 12%/tahun selama 24 bulan: `€60.000 × 12% × 2` = €14.400,00 (Total Biaya = **€22.400,00**).
   - Direct Cost Savings: **€1.208,50**.
   - **Net Financial Benefit = −€21.191,50** (−Rp 424.937.362), sekaligus menciptakan **risiko tinggi *stranded inventory* / keusangan komponen** sebesar €60.000.

---

## 05 As-Is vs No-Action vs To-Be

| Skenario | Avoided Shortage Cases | Direct Savings (EUR) | Impl. & Holding/OpEx (EUR) | Net Financial Benefit (EUR) | Net Benefit (IDR) | Risiko Stranded Inventory |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| As-Is / No-Action | 0 | €0,00 | €0,00 | €0,00 | Rp 0 | Rendah (eksisting) |
| **To-Be Q09-A: Lean Material Planning** | **14** | **€1.208,50** | **€4.000,00** | **−€2.791,50** | **−Rp 55.975.870** | **Nol (tanpa buffer)** |
| To-Be Q09-B: Safety Stock Buffer | 14 | €1.208,50 | €22.400,00 | −€21.191,50 | −Rp 424.937.362 | Tinggi (€60.000 modal tertahan) |

**Syarat Realisasi Tambahan Kendaraan Selesai:** Pengurangan waktu tunggu *shortage* (selisih median 1,20 jam pada High complexity atau 7,71 jam agregat) **tidak otomatis menambah kendaraan selesai maupun revenue**. Tambahan unit selesai dan kontribusi (~€10.628,55/unit) hanya dapat terealisasi apabila: (1) terdapat **unfulfilled market demand**, (2) **bottleneck hilir (*Paint Booth* & *Press Line*) memiliki kapasitas kosong** (misalnya setelah *release smoothing* Q08 berjalan), dan (3) **tidak ada komponen lain yang tertahan** di *Parts Kitting*.

---

## 06 Recommendation, Risk, Assumptions
- **Rekomendasi:** Tolak penambahan *Safety Stock Buffer* (Q09-B) karena merugikan secara finansial (−€21.191,50) dan melanggar *Business Challenge* terkait *stranded inventory*. Terapkan **Q09-A (BOM Pre-check & Supplier Alert)** hanya sebagai bagian terintegrasi dari sistem penjadwalan ERP (bersama Q08) dengan anggaran ringan, bukan sebagai proyek ROI mandiri.
- **Asumsi:** Target *shortage rate* High complexity = 12%; rata-rata biaya resolusi = €86,32/kasus; *holding cost* = 12%/tahun; nilai *safety stock* = €60.000; volume 205 order / 24 bulan.
- **Risiko & Batasan:** Event log tidak mencatat ID pemasok maupun *Purchase Order lead time*, sehingga efektivitas *supplier alert* bergantung pada kepatuhan pemasok eksternal.

---

## 07 Evidence File Paths / SQL References
- **SQL Query:** `02_SQL/queries_by_question/Q9.sql` dan `02_SQL/04_financial_analysis.sql`
- **Celonis Evidence Folder:** `03_CELONIS_EVIDENCE/Q09/`
- **Financial Files:** `05_FINANCIAL/exchange_rate.csv`, `05_FINANCIAL/scenario_assumptions.md`
