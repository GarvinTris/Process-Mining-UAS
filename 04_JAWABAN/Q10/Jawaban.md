# Q10 — Manufacturing Business Case

**Pertanyaan:** Tentukan dua rekomendasi terbaik berdasar *net financial benefit*, *defect risk*, *feasibility*, dan *implementation cost*. Sajikan As-Is, No-Action, dan To-Be dalam EUR dan IDR.

---

## 01 Evidence & Data Source
- **Sumber Data:** `01_DATA/cleaned/celonis_event_log_clean.csv`, `05_FINANCIAL/financial_baseline.csv`, `05_FINANCIAL/scenario_comparison.csv`, dan `05_FINANCIAL/exchange_rate.csv`.
- **Kurs Referensi Tunggal:** Bank Indonesia — Kurs Transaksi BI per **13 Oktober 2026** (`Kurs Jual = Rp 20.154,30`, `Kurs Beli = Rp 19.950,21`, **Midpoint = Rp 20.052,255 / 1 EUR**).
- **Baseline Produksi & Outcome (205 Production Orders, 24 Bulan):**
  - **Delivered:** 182 kasus | Revenue: €6.811.566,96 | Cost: €4.877.170,24 | Rata-rata Revenue: €37.426,19/unit | Rata-rata Cost: €26.797,64/unit.
  - **Scrapped:** 14 kasus | Revenue: €0,00 | Cost hangus (*sunk*): **€344.556,10** (rata-rata €24.611,15/kasus).
  - **Cancelled / Other:** 9 kasus | Revenue: €0,00 | Cost: €1.165,70.

---

## 02 Descriptive Finding
Berdasarkan evaluasi seluruh kandidat intervensi (Q07–Q09 serta penanggulangan *scrap*), **Rekomendasi Terbaik 1 (R1)** adalah **Scrap Containment & Auto-Relaunch** (menangkap cacat *unrecoverable* lebih awal pada *checkpoint* pasca-harness + *ERP auto-relaunch* untuk mempertahankan pelanggan *Make-to-Order*), dan **Rekomendasi Terbaik 2 (R2)** adalah **Paket Lean (Release Smoothing Takt 60 Menit + Lean Rework Standard Work)**.

| Skenario | Revenue (EUR) | Operational Cost (EUR) | Profit Contribution (EUR) | Delta vs No-Action (EUR) | Revenue (IDR) | Operational Cost (IDR) | Profit Contribution (IDR) | Delta vs No-Action (IDR) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| **As-Is (Observed, 24 bln, 205 orders)** | €6.811.566,96 | €5.222.892,04 | **€1.588.674,92** | €0,00 | Rp 136.587.277.631 | Rp 104.730.763.024 | **Rp 31.856.514.608** | Rp 0 |
| **No-Action (Volume & horizon sama)** | €6.811.566,96 | €5.222.892,04 | **€1.588.674,92** | €0,00 | Rp 136.587.277.631 | Rp 104.730.763.024 | **Rp 31.856.514.608** | Rp 0 |
| **To-Be R1: Scrap Containment & Relaunch** | €7.178.343,96 | €5.487.694,04 | **€1.690.649,92** | **+€101.975,00** | Rp 143.941.983.564 | Rp 110.040.640.252 | **Rp 33.901.343.312** | **+Rp 2.044.828.704** |
| **To-Be R2: Paket Lean (Takt 60m + Lean Rework)** | €6.811.566,96 | €5.223.573,62 | **€1.587.993,34** | **−€681,58** | Rp 136.587.277.631 | Rp 104.744.430.240 | **Rp 31.842.847.392** | **−Rp 13.667.216** |
| **To-Be R1 + R2 (Kombinasi Prioritas)** | **€7.178.343,96** | **€5.488.375,62** | **€1.689.968,34** | **+€101.293,42** | **Rp 143.941.983.564** | **Rp 110.054.307.468** | **Rp 33.887.676.096** | **+Rp 2.031.161.488** |

---

## 03 Diagnostic Reasoning
Mengapa R1 dan R2 dipilih mengungguli investasi mesin (C1/C3) dan *safety stock* (Q09-B)?
1. **R1 (Scrap Containment & Auto-Relaunch)** langsung menyerang kebocoran nilai terbesar perusahaan: 14 kendaraan *scrapped* yang membakar biaya €344.556,10 tanpa menghasilkan €1 pun revenue. Dengan menangkap 40% cacat *unrecoverable* lebih awal dan me-*relaunch* order pengganti (retensi MTO 70%), perusahaan memulihkan revenue **+€366.777,00** dengan tambahan biaya produksi & *checkpoint* **+€264.802,00**, menghasilkan **Net Financial Benefit +€101.975,00**.
2. **R2 (Paket Lean: Takt 60 Menit + Lean Rework)** memang mencatat selisih finansial bersih nyaris impas (−€681,58 atau −0,04% dari kontribusi), karena penghematan rework (€6.429,42) dan WIP (€389,00) hampir menutup biaya implementasi & OpEx (€7.500,00). Namun, R2 **menghilangkan 100% SLA violations (316 → 0)** dan memangkas *waiting time* 91,3%, sehingga menciptakan ruang kapasitas yang diperlukan agar *relaunch* unit pada R1 tidak memicu kemacetan baru.

---

## 04 Business & Financial Implication
- **Executive Decision Matrix (Skala Prioritas):**

| Kriteria | R1: Scrap Containment & Auto-Relaunch | R2: Paket Lean (Takt 60m + Lean Rework) | Opsi Ditolak: CapEx Equipment (C1/C3) & Safety Stock (Q09-B) |
| --- | --- | --- | --- |
| **Net Financial Benefit (24 bln)** | **Sangat Tinggi (+€101.975 / +Rp 2,04 M)** | **Impas (−€681,58 / −Rp 13,67 Jt)** | **Sangat Negatif (−€21rb s.d. −€1,16 Jt)** |
| **Defect & Quality Risk** | Rendah (menambah *checkpoint*, menjaga *quality gates*) | Rendah (*standard work* + Pareto review) | Sedang–Tinggi (risiko *stranded inventory* €60rb pada Q09-B) |
| **Operational Feasibility** | Sedang–Tinggi (*fixture* uji + aturan ERP) | Tinggi (perubahan SOP & jadwal rilis) | Rendah (CapEx jutaan EUR tidak ekonomis) |
| **Implementation Cost** | €17.000 (€12.000 *checkpoint* + €5.000 ERP) | €5.500 (€2.500 *rework* + €3.000 *takt*) | €8.000 – €5.800.000 |

- **Kombinasi R1 + R2** menghasilkan **To-Be Profit Contribution sebesar €1.689.968,34 (Rp 33.887.676.096)** atau kenaikan bersih **+€101.293,42 (+Rp 2.031.161.488)** dibandingkan skenario As-Is / No-Action.

---

## 05 As-Is vs No-Action vs To-Be
Berdasarkan cleaned dataset, As-Is Contribution sebesar **€1.588.674,92** (Rp 31.856.514.608). Kombinasi program **To-Be R1 + R2** berpotensi menghasilkan **Net Financial Benefit +€101.293,42 (+Rp 2.031.161.488)** setelah memperhitungkan *Implementation Cost* dan *Additional Operating Cost*. Jika tidak ada tindakan (**No-Action**), kerugian akibat 14 kasus *scrap* (€344.556,10) dan 316 *SLA violations* diperkirakan terus berlanjut pada volume sebanding.

---

## 06 Recommendation, Risk, Assumptions
- **Keputusan Manajemen:** Setujui paket kombinasi **To-Be R1 + R2** dengan prioritas implementasi bertahap: (1) jalankan **R2 (Release Smoothing Takt 60 Menit + Lean Standard Work)** pada kuartal 1 untuk menstabilkan aliran *Paint Booth*, dan (2) terapkan **R1 (Post-Harness Checkpoint + ERP Auto-Relaunch)** untuk memulihkan nilai dari kasus *scrap*.
- **Asumsi Utama:** Retensi pelanggan MTO pada *auto-relaunch* = 70%; efektivitas *checkpoint* pasca-harness = 40% (hipotesis); *avoidable rework reduction* = 20%; kurs tetap Rp 20.052,255/EUR (BI 13 Okt 2026); seluruh perhitungan adalah *analytical translation* berbasis dataset sintetis 24 bulan, bukan laporan laba rugi teraudit.
- **Risiko & Batasan:** Efektivitas *checkpoint* pasca-harness (40%) dan retensi pelanggan MTO (70%) belum terobservasi langsung di event log sehingga wajib divalidasi melalui *pilot* 3 bulan sebelum *rollout* penuh.

---

## 07 Evidence File Paths / SQL References
- **SQL Query:** `02_SQL/queries_by_question/Q10.sql` dan `02_SQL/04_financial_analysis.sql`
- **Celonis Evidence Folder:** `03_CELONIS_EVIDENCE/Q10/`
- **Financial Model & FX:** `05_FINANCIAL/scenario_comparison.csv`, `05_FINANCIAL/financial_baseline.csv`, `05_FINANCIAL/exchange_rate.csv`, `05_FINANCIAL/scenario_assumptions.md`
