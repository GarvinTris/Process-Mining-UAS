# Q07 — Quality Improvement Scenario

**Pertanyaan:** Jika Avoidable Rework menurun 20%, proyeksikan direct cost savings serta perubahan Profit Contribution setelah memperhitungkan inspection/program cost. Jangan menghapus mandatory quality gates.

---

## 01 Evidence & Data Source
- **Sumber Data:** `01_DATA/cleaned/celonis_event_log_clean.csv` (5.750 events, 205 production cases), `01_DATA/employee_master.csv`, dan `05_FINANCIAL/exchange_rate.csv` (Kurs Referensi BI 13 Oktober 2026: **1 EUR = Rp 20.052,255**).
- **Baseline Perusahaan (As-Is, 24 bulan):**
  - Total Revenue: **€6.811.566,96** (Rp 136.587.277.631)
  - Total Operational Cost: **€5.222.892,04** (Rp 104.730.763.024)
  - Profit Contribution (As-Is): **€1.588.674,92** (Rp 31.856.514.608)
- **Baseline Rework (70 events pada 44 unique cases; 196 kasus melewati proses Paint):**

| Aktivitas Rework | Events | Cases | Recorded Cost (EUR) | Avoidable Share (Asumsi) | Avoidable Base (EUR) | Direct Savings 20% (EUR) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Paint Rework Completed | 26 | 26 | €24.942,71 | 70% | €17.459,90 | €3.491,98 |
| Vehicle Defect Rectified | 22 | 22 | €25.005,14 | 50% | €12.502,57 | €2.500,51 |
| Dynamic Road Test (rework_flag = TRUE) | 22 | 22 | €4.369,26 | 50% | €2.184,63 | €436,93 |
| **Total** | **70** | **44** | **€54.317,11** | **59,18% (efektif)** | **€32.147,10** | **€6.429,42** |

---

## 02 Descriptive Finding
Dari total Recorded Rework Cost sebesar **€54.317,11** (Rp 1.089.180.115), tidak seluruhnya dapat dikategorikan sebagai biaya yang bisa dihindari (*avoidable*). Dengan memisahkan porsi *avoidable* pada variasi proses pengecatan (70%), perbaikan cacat kendaraan (50%), dan pengulangan road test (50%), basis Avoidable Rework tercatat sebesar **€32.147,10**. Penurunan Avoidable Rework sebesar **20%** menghasilkan **Direct Cost Savings sebesar €6.429,42** (Rp 128.924.369) selama horizon 24 bulan tanpa menghapus satu pun *mandatory quality gate* (`Quality Inspection`, `Dynamic Road Test`, `ADAS Calibration`).

---

## 03 Diagnostic Reasoning
Rework pada area *Painting* (`Paint Rework Completed`, €24.942,71) dan *Defect Rectification* (`Vehicle Defect Rectified`, €25.005,14) menyumbang 91,96% dari total biaya rework. Sebagian rework pada perbaikan cacat dan *road test* tetap bersifat *legitimate mandatory rework* (cacat desain, ketidaksesuaian komponen pemasok, atau verifikasi keselamatan) yang tidak boleh ditekan dengan memangkas gerbang kualitas. Oleh karena itu, intervensi harus menargetkan akar variasi proses di stasiun pengecatan dan standarisasi kerja sebelum inspeksi akhir.

---

## 04 Business & Financial Implication
Berdasarkan cleaned dataset, As-Is Contribution sebesar **€1.588.674,92** (Rp 31.856.514.608). Penurunan Avoidable Rework 20% hanya menghasilkan penghematan langsung **€6.429,42**, sehingga kelayakan finansial sangat bergantung pada desain biaya program perbaikan:
1. **Opsi Q07-A (Full SPC / Inline Paint Checkpoint):** Membutuhkan biaya implementasi €15.000,00 plus biaya inspeksi tambahan 8 menit/kendaraan untuk 196 kendaraan (@ €53,448/jam tarif rata-rata Quality Inspector) sebesar €1.396,77 (total biaya €16.396,77). Hasilnya **Net Financial Benefit negatif sebesar −€9.967,35** (−Rp 199.867.843).
2. **Opsi Q07-B (Lean Standard Work & Defect Pareto Review):** Menggunakan *standard work*, *checklist* operator, dan tinjauan Pareto mingguan dengan biaya implementasi €2.500,00 serta *additional operating cost* €1.000,00 (total biaya €3.500,00). Program ini menghasilkan **Net Financial Benefit positif sebesar +€2.929,42** (+Rp 58.741.477).

---

## 05 As-Is vs No-Action vs To-Be

| Skenario | Direct Savings (EUR) | Program & Inspection Cost (EUR) | Net Financial Benefit (EUR) | Net Benefit (IDR) | To-Be Contribution (EUR) | To-Be Contribution (IDR) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| As-Is (Observed, 24 bln) | €0,00 | €0,00 | €0,00 | Rp 0 | €1.588.674,92 | Rp 31.856.514.608 |
| No-Action (Volume sebanding) | €0,00 | €0,00 | €0,00 | Rp 0 | €1.588.674,92 | Rp 31.856.514.608 |
| To-Be Q07-A: Full SPC / Inline Checkpoint | €6.429,42 | €16.396,77 | −€9.967,35 | −Rp 199.867.843 | €1.578.707,57 | Rp 31.656.646.765 |
| **To-Be Q07-B: Lean Standard Work (Rekomendasi)** | **€6.429,42** | **€3.500,00** | **+€2.929,42** | **+Rp 58.741.477** | **€1.591.604,34** | **Rp 31.915.256.085** |

Jika tidak ada tindakan (**No-Action**), biaya rework sebesar €54.317,11 per 24 bulan diperkirakan terus berlanjut pada volume sebanding dan menggerus kapasitas stasiun Paint serta Road Test.

---

## 06 Recommendation, Risk, Assumptions
- **Rekomendasi:** Jalankan **To-Be Q07-B (Lean Standard Work & Defect Pareto Review)** sebagai intervensi kualitas yang hemat biaya tanpa menghapus *mandatory quality gates* (`Quality Inspection`, `Dynamic Road Test`, `ADAS Calibration`), dan tolak investasi *inline sensor* skala penuh (Q07-A) untuk volume saat ini karena payback tidak tercapai dalam 24 bulan.
- **Asumsi:** `avoidable_share` = 70% (*Paint Rework*), 50% (*Defect Rectified*), 50% (*Repeated Road Test*); tarif rata-rata *Quality Inspector* = €53,45/jam; biaya implementasi Lean = €2.500 + OpEx €1.000; volume konstan 205 order / 24 bulan.
- **Risiko & Batasan:** Data tidak memiliki kode akar cacat (*defect root-cause code*) dan status *First-Pass Yield* eksplisit, sehingga proporsi *avoidable* merupakan asumsi konservatif; penghematan hanya terealisasi jika disiplin *checklist* dijaga tanpa mengorbankan kecepatan inspeksi.

---

## 07 Evidence File Paths / SQL References
- **SQL Query:** `02_SQL/queries_by_question/Q7.sql` dan `02_SQL/04_financial_analysis.sql`
- **Celonis Evidence Folder:** `03_CELONIS_EVIDENCE/Q07/`
- **Financial Model & FX:** `05_FINANCIAL/financial_baseline.csv`, `05_FINANCIAL/exchange_rate.csv`, `05_FINANCIAL/scenario_assumptions.md`