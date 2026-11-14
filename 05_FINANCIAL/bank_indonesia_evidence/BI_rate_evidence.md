# Bukti Kurs — Bank Indonesia, Kurs Transaksi BI (13 Oktober 2026)

| Item | Nilai |
|---|---|
| Halaman sumber | https://www.bi.go.id/id/statistik/informasi-kurs/transaksi-bi/default.aspx |
| Tanggal kurs | 13 Oktober 2026 |
| Mata uang | EUR (dataset 100% EUR) |
| Kurs Jual BI | Rp 20.154,30 per 1 EUR |
| Kurs Beli BI | Rp 19.950,21 per 1 EUR |
| Reference Rate (midpoint) | (20.154,30 + 19.950,21) / 2 = **Rp 20.052,255 per 1 EUR** |
| Dipakai di | `02_SQL/04_financial_analysis.sql` (view `fx_ref`), `05_FINANCIAL/exchange_rate.csv`, seluruh konversi IDR |

Angka di atas dikutip dari Panduan Penugasan 24SI1 Group 02 (hlm. 3), yang menyatakan data harian BI 13 Oktober 2026.

> **TINDAKAN KELOMPOK (belum dapat dilakukan otomatis):** buka halaman BI di atas, pilih tanggal 13 Oktober 2026, ambil *screenshot* baris EUR, dan simpan di folder ini sebagai `BI_EUR_2026-10-13.png`. Rubrik meminta bukti kurs yang dapat ditelusuri. Pastikan angka di screenshot sama dengan tabel di atas; bila berbeda, ubah `exchange_rate.csv` lalu jalankan ulang `python 02_SQL/run_all.py`.

Catatan metodologi: konversi ini adalah *analytical translation* pada satu kurs referensi, bukan rekonsiliasi akuntansi historis.
