# Data Quality Report — Rheinwerk Automotive Assembly (24SI1 Group 02)

**Sumber:** `01_DATA/raw/raw_event_log.csv` (5.888 baris, 41 kolom, tidak diedit — byte-identik dengan paket student) + 8 master data (authoritative).
**Hasil:** `01_DATA/cleaned/celonis_event_log_clean.csv` — **5.750 baris, 205 case, 36/36 uji validasi PASS**.
**Reproduksi:** `python 02_SQL/run_all.py` (atau jalankan `02_SQL/00_import.sql` … `05_celonis_export.sql` berurutan di DuckDB).
**Audit trail:** `dq_repair_log.csv` (setiap perbaikan per baris), `dq_removed_duplicates.csv` (baris yang dibuang + baris yang dipertahankan), `validation_results.csv`.

## 1. Rekonsiliasi raw → clean

| Langkah | Baris |
|---|---:|
| Raw rows | 5.888 |
| Source duplicate dibuang (event_id sama setelah TRIM+UPPER) | −138 (136 grup: 134 pasang + 2 triplet) |
| Baris dikarantina (tak dapat dipulihkan) | 0 |
| **Clean rows** | **5.750** (= 5.888 − 138) |
| Baris clean dengan ≥1 perbaikan nilai | 56 (lihat `dq_repair_log.csv`) |

Case unik: 206 string `case_id` mentah → **205** setelah TRIM (satu `case_id` bertambahan spasi). Seluruh 205 case ada di `case_master`; tidak ada orphan.

## 2. Temuan per dimensi data quality

| # | Dimensi | Temuan (raw) | Bukti SQL | Keputusan & alasan | Baris |
|---|---|---|---|---|---:|
| 1 | **Uniqueness** | `event_id` berulang setelah normalisasi; seluruh duplikat identik pada case, activity, end time, biaya (0 konflik) | 01_profiling P04 | Dibuang, simpan `raw_row_id` terkecil. **Bukan** rework: rework sah punya `event_id` sendiri | 138 |
| 2 | **Consistency** | Casing/spasi pada `event_id` (46), `case_id` (1), `employee_id` (1), `department_id` (2), `employee_role` (2) | P09 | `UPPER(TRIM())` — ID master berhuruf besar | ±51 |
| 3 | **Consistency** | Casing `activity` tidak kanonik (mis. huruf kecil) | P02 | JOIN case-insensitive ke `activity_catalog`; 35 activity kanonik | 50 |
| 4 | **Consistency** | Nama `department` non-kanonik | P03 | Diambil dari `department_master` via `employee_master` | 5 |
| 5 | **Validity** | Nilai uang berprefiks `EUR` / `€` | P06 | Hapus simbol, `CAST DECIMAL(18,2)`. Nilai invalid **tidak** diganti 0 (0 kasus gagal cast) | 4 |
| 6 | **Validity** | Boolean tidak kanonik (`N`, `Y`, `1/0`, …) | P07 | Dipetakan ke true/false; nilai lain → NULL (0 kasus) | 4 |
| 7 | **Completeness** | `case_type` placeholder (`N/A`, `NaN`, `-`, `NULL`) | P08 | Dipulihkan dari `case_master` (authoritative) | 6 |
| 8 | **Completeness** | `resource_id` kosong | P08, P11 | Dipulihkan dari `employee_master` (1 employee = 1 workstation) | 2 |
| 9 | **Validity** | `activity_start_time` berisi `not-a-time` (ready/end juga tidak terparse) | P05 | **Direkonstruksi**, bukan dibuang: terbukti `case_elapsed_time = end − arrival case` pada 5.746/5.749 baris → end = arrival + elapsed; start = end − durasi; ready = start − waiting. Ditandai `RECONSTRUCTED_FROM_CASE_ELAPSED` | 1 |
| 10 | **Validity** | `start >= end` (start/end tertukar). Durasi & waiting tercatat hanya konsisten jika kolom ditukar | P05 | Swap start↔end; ditandai `SWAPPED_START_END` | 3 |
| 11 | **Consistency** | `timestamp ≠ activity_end_time` (day/month tertukar) | P05 | `timestamp := activity_end_time` (data dictionary) | 1 |
| 12 | **Accuracy / Format** | **Format tanggal slash = MONTH-FIRST (`M/D/YYYY H:MM`), bukan day-first seperti data_dictionary** | P05 | Lihat §3 | 5.887 |

### Yang sengaja **tidak** dianggap error (preserve evidence)
- `facility_id` kosong (1.234 baris) → valid; seluruhnya cocok dengan activity tanpa `facility_type` di `activity_catalog` (V23 = 0 pelanggaran).
- `exception_type` kosong → valid bila tanpa exception.
- **Rework sah:** Dynamic Road Test berulang di 22 case, Paint Rework Completed 26, Vehicle Defect Rectified 22 — semua dipertahankan (V33–V34).
- **Parallel execution** (Body/Paint ∥ Chassis; Interior ∥ Software+ADAS): overlap waktu antar activity berbeda adalah proses sah. Overlap pada *fasilitas/employee yang sama* = 0 (V27–V28).
- **Waiting panjang & SLA violation** (277 event): sah; seluruhnya berasal dari lonjakan order 28 Apr 2025 (lihat Q03) — bukan error.
- **Sales credit negatif** (10 event, −€15.683,04) dan **revenue = 0** pada Invoice/Payment: sah (V14, V17).
- **Quality-gate bypass:** 4 case Delivered tanpa *Final Quality Gate Approved* → **temuan kendali nyata** (flag `qc_bypass_flag`), bukan error data.
- `trim_grade = Unknown`: kategori sah di `trim_grade_master`.

## 3. Penyimpangan data dictionary — format tanggal
Dictionary menyatakan variasi slash adalah `DD/MM/YYYY HH:MM` (day-first). Data mentah membuktikan sebaliknya:
1. Dari 5.887 tanggal slash, komponen **pertama tidak pernah > 12**, sedangkan komponen **kedua > 12 pada banyak baris** (mis. `8/27/2025`).
2. Memakai `%m/%d/%Y`, selisih start–end cocok dengan `activity_duration_minutes` pada 5.884 baris; memakai `%d/%m/%Y` hanya 2.100 baris.

Karena itu parser memakai urutan: `YYYY-MM-DD HH:MM:SS` → `YYYY/MM/DD HH:MM:SS` → `M/D/YYYY H:MM` (terbukti) → `D/M/YYYY H:MM` (fallback bila ada). Semua timestamp akhir berformat kanonik `YYYY-MM-DD HH:MM:SS` UTC. **Rekomendasi:** dikonfirmasi ke dosen/pemilik dataset; bila day-first benar-benar dimaksudkan, hasil durasi tidak akan konsisten.

## 4. Validasi pasca-cleaning (`03_validation.sql`)
Seluruh 36 uji PASS. Ringkasan kelompok:

| Kelompok | Uji | Hasil |
|---|---|---|
| Uniqueness | V01–V02 duplikat event_id / raw_row_id | 0 |
| Completeness | V03–V04 NULL pada case/activity/timestamp/start/end/ready | 0 |
| Waktu | V05 ready ≤ start < end; V06 timestamp = end; V07 durasi; V08 waiting; V09 case_elapsed; V10 flag SLA | 0 pelanggaran |
| Finance | V11 total = labor+material+equipment+overhead; V12 profit = revenue − total; V13–V17 revenue hanya pada Vehicle Delivered, kredit hanya pada Authorized Sales Credit, 1 pengakuan revenue/case, Invoice/Payment = 0; V18 EUR | 0 pelanggaran |
| Referential integrity | V19–V26 case, employee, resource, facility(+tipe), role/department vs catalog, model/trim/vehicle vs case_master, activity vs catalog | 0 pelanggaran |
| Kapasitas | V27 overlap fasilitas; V28 overlap employee duty-slot (kapasitas 1) | 0 |
| Path | V29 awal = Production Order Received; V30 akhir = Production Order Closed; V31 satu outcome/case; V32 205 case | lolos |
| Preservation | V33–V35 rework & shortage dipertahankan (22 / 26 / 38); V36 = 4 bypass | sesuai |

**Re-import audit** (`05_celonis_export.sql`): 5.750 baris, 5.750 `event_id` unik, 205 case, tidak ada NULL pada field inti, `timestamp` bertipe TIMESTAMP, kolom finansial numerik, urutan deterministik (`ORDER BY case_id, timestamp, activity_start_time, event_id`).

**Baseline finansial clean (EUR):** Revenue 6.811.566,96 · Cost 5.222.892,04 · Profit Contribution 1.588.674,92 (205 case; cost/case 25.477,52).

## 5. Dampak jika data tidak dibersihkan (mengapa cleaning penting)
- Event ganda menggelembungkan jumlah "pengulangan" case+activity menjadi **156** pasang (clean: **22** rework sah) — salah mengidentifikasi rework hingga 7×.
- Format uang bersimbol membuat `TRY_CAST` gagal → total biaya/revenue salah bila diganti 0.
- Start/end tertukar menghasilkan durasi negatif dan waiting palsu.

## 6. Keterbatasan
- Rekonstruksi 1 baris (RAW-0003222) bergantung pada identitas `case_elapsed = end − arrival`; terbukti pada 5.746 baris lain, tetapi tetap merupakan imputasi terdokumentasi (flag di `dq_repair_note`).
- Cakupan data hanya apa yang tercatat: biaya waiting, expedite/rush, penalti SLA, dan biaya penggantian order scrap **tidak ada** di dataset.
