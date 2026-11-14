# Sources & References

## Dataset dan dokumen tugas (paket student; dataset sintetis & fiktif)
| Berkas | Lokasi |
|---|---|
| Raw event log + 8 master data (tidak diedit; byte-identik dengan paket) | `01_DATA/raw/` |
| Panduan Penugasan 24SI1 Group 02 v2.0 | `09_REFERENCES/dataset_docs/24SI1_Group02_Panduan_Penugasan.pdf` |
| Business process description | `09_REFERENCES/dataset_docs/business_process_description.md` |
| Data dictionary | `09_REFERENCES/dataset_docs/data_dictionary.md` |
| Dataset background | `09_REFERENCES/dataset_docs/dataset_background.md` |
| Laboratory instructions | `09_REFERENCES/dataset_docs/laboratory_instructions.md` |

## Kurs
Bank Indonesia — Kurs Transaksi BI, data 13 Oktober 2026: https://www.bi.go.id/id/statistik/informasi-kurs/transaksi-bi/default.aspx (Jual 20.154,30; Beli 19.950,21; midpoint 20.052,255 IDR/EUR). Bukti: `05_FINANCIAL/bank_indonesia_evidence/`.

## Perangkat lunak
DuckDB (SQL, versi 2.0.0 saat pengerjaan), Python 3 (pandas, matplotlib, graphviz) untuk visual evidence dan simulasi replay, Celonis (workflow institusi).

## Catatan penggunaan
- Tidak ada answer key/instructor reference yang dipakai; semua angka dapat ditelusuri ke `02_SQL/` dan `01_DATA/cleaned/`.
- Asumsi non-data (capex, biaya program, efektivitas, retensi, WACC) ditandai ASSUMPTION di `05_FINANCIAL/scenario_assumptions.md`.
- Alat AI digunakan untuk membantu penyusunan SQL/dokumen; seluruh keputusan, asumsi, dan angka perlu direview dan dipertahankan oleh kelompok saat Q&A.
