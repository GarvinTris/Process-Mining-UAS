# 24SI1 Group 02 — Process Mining: Rheinwerk Automotive Assembly (Production Order-to-Vehicle Delivery)

**Case notion:** 1 vehicle production order · **Data:** raw event log sintetis (5.888 baris) → cleaned 5.750 event / 205 case · **Periode order:** Okt 2024 – Sep 2026 · **Mata uang:** EUR, konversi IDR = Rp 20.052,255/EUR (BI, 13 Okt 2026).

## Hasil utama (semua dapat ditelusuri)
| | |
|---|---|
| Baseline | Revenue €6.811.567 · Cost €5.222.892 · **Contribution €1.588.675 (Rp 31,86 M)** |
| Data quality | 138 duplikat sumber dibuang; 56 baris diperbaiki; 1 timestamp direkonstruksi; 36/36 validasi PASS; format tanggal sebenarnya month-first |
| Temuan #1 | **100% waiting (2.851 jam) & SLA violation (277) berasal dari lonjakan 65 order pada 28 Apr 2025**; bottleneck = Paint Booth (44,8%), Press Line, Chassis Line |
| Temuan #2 | Scrap 14 order = **€344.556** (6,6% biaya, 83% material); rework hanya €54.317 (1,04%) |
| Temuan #3 | 4 case Delivered tanpa Final Quality Gate → pelanggaran kendali nyata |
| Rekomendasi | **R1** Scrap containment (+€101.975 ≈ Rp 2,04 M; ±97% dari relaunch) · **R2** Paket lean: release smoothing takt 60 mnt + lean rework (≈ impas, SLA 316→0) |

## Cara menjalankan ulang (dari ROOT folder ini)
```bash
pip install duckdb pandas matplotlib graphviz        # + Graphviz 'dot' terpasang
python 02_SQL/run_all.py                              # 00_import → cleaning → validation → export → financial → Q01–Q10 + evidence CSV
python 02_SQL/python_support/run_capacity_simulation.py   # (opsional) ulang simulasi kapasitas Q06/Q08
python 02_SQL/python_support/make_evidence.py             # (opsional) ulang gambar evidence
```
Atau di DuckDB CLI/VS Code, jalankan `02_SQL/00_import.sql`, `02_cleaning.sql`, `03_validation.sql`, `05_celonis_export.sql`, `04_financial_analysis.sql`, lalu `queries_by_question/Q01.sql … Q10.sql`.
(`01_profiling.sql` bersifat read-only; boleh dijalankan kapan saja setelah import.)

## Peta folder
`01_DATA` raw / cleaned / validation · `02_SQL` skrip + `queries_by_question/` + `python_support/` · `03_CELONIS_EVIDENCE` process map, variants, performance, Q01–Q10 · `04_JAWABAN/Qnn/jawaban.md` · `05_FINANCIAL` kurs, baseline, skenario, asumsi · `06_PRESENTATION` slide (PDF+PPTX) · `07_EXECUTIVE_SUMMARY` · `08_CONTRIBUTIONS` · `09_REFERENCES`.

## ⚠️ Yang HARUS diselesaikan kelompok sebelum submit
1. **Screenshot Celonis asli** → ikuti `03_CELONIS_EVIDENCE/README_CELONIS_STEPS.md` (gambar yang ada = replikasi DuckDB/Graphviz).
2. **Screenshot halaman BI** (kurs 13 Okt 2026) → `05_FINANCIAL/bank_indonesia_evidence/`.
3. **Isi `08_CONTRIBUTIONS/member_contributions.csv`** (nama, NIM, kontribusi nyata) — sengaja dikosongkan; tidak boleh dikarang.
4. Review asumsi ASSUMPTION (capex, efektivitas, retensi) dan konfirmasi ke dosen: **format tanggal data = month-first, bukan day-first** seperti di data dictionary.
5. Latih presentasi 15 menit (struktur 15 slide + appendix di `06_PRESENTATION/`).
