# Scenario Assumptions & Financial Method — Rheinwerk Automotive Assembly

## 1. Konvensi
- **Profit Contribution = SUM(revenue_allocated) − SUM(activity_total_cost)** (bukan net profit). Sumber: `01_DATA/cleaned/celonis_event_log_clean.csv`.
- Revenue hanya diakui sekali pada *Vehicle Delivered*; Authorized Sales Credit mengurangi revenue; Invoice/Payment = 0 (V13–V17).
- ΔContribution = Avoidable Cost Savings + Incremental Revenue − Implementation Cost − Additional Operating Cost.
- **Horizon & volume sebanding:** As-Is = No-Action = 24 bulan (Okt 2024–Sep 2026), 205 order. To-Be dihitung pada horizon dan volume yang sama.
- Waiting time **tidak** dikonversi menjadi penghematan tunai (dataset tidak membebankan biaya pada waktu tunggu: korelasi wait–biaya 0,03). Manfaat waktu hanya dihitung sebagai nilai-waktu uang dan carrying WIP (WACC 8%).
- Kapasitas tidak otomatis menjadi revenue: *incremental revenue* = 0 kecuali ada bukti permintaan tak terlayani (tidak ada di dataset).

## 2. Kurs (analytical translation, bukan rekonsiliasi akuntansi historis)
| Item | Nilai |
|---|---|
| Sumber | Bank Indonesia — Kurs Transaksi BI, 13 Oktober 2026 |
| Kurs Jual / Beli | Rp 20.154,30 / Rp 19.950,21 per 1 EUR |
| Reference Rate | (20.154,30 + 19.950,21) / 2 = **Rp 20.052,255 per 1 EUR** |
| Konversi | IDR = EUR × 20.052,255 (satu kurs untuk As-Is, No-Action, To-Be) |
| Mata uang dataset | 100% EUR (V18) — normalisasi JPY tidak relevan |

## 3. Baseline (EUR / IDR)
| | EUR | IDR |
|---|---:|---:|
| Revenue | 6.811.566,96 | 136.587.277.631 |
| Operational cost | 5.222.892,04 | 104.730.763.024 |
| **Profit Contribution** | **1.588.674,92** | **31.856.514.608** |
| Cost per case (205) | 25.477,52 | 510.9 juta |

## 4. Tabel asumsi (sumber tunggal: tabel `scenario_assumptions` di `02_SQL/04_financial_analysis.sql`)
`DATA` = diambil dari dataset · `ASSUMPTION` = asumsi kelompok (bukan hasil dataset, bukan janji penghematan) · `SOAL` = diberikan soal.

| Parameter | Nilai | Satuan | Jenis | Catatan / justifikasi |
|---|---:|---|---|---|
| `horizon_months` | 24.00 | bulan | DATA | Oktober 2024 - September 2026; As-Is = No-Action pada volume 205 order |
| `wacc_annual` | 0.08 | rasio | ASSUMPTION | Biaya modal untuk nilai-waktu uang & carrying WIP |
| `q07_reduction_rate` | 0.20 | rasio | SOAL Q07 | Penurunan avoidable rework 20% (diberikan soal) |
| `q07_share_paint_rework` | 0.70 | rasio | ASSUMPTION | Porsi avoidable Paint Rework (variasi proses paint dapat dikendalikan) |
| `q07_share_defect_rectify` | 0.50 | rasio | ASSUMPTION | Porsi avoidable Vehicle Defect Rectified (sebagian defect genuine/desain/pemasok) |
| `q07_share_retest` | 0.50 | rasio | ASSUMPTION | Road Test ulang mengikuti defect: ikut turun proporsional |
| `q07_full_impl_cost` | 15,000.00 | EUR | ASSUMPTION | Program SPC/inline paint checkpoint: desain prosedur, sensor, pelatihan |
| `q07_full_extra_inspection_min` | 8.00 | menit/kendaraan | ASSUMPTION | Inspeksi tambahan inline pada 196 kendaraan yang melewati paint |
| `q07_lean_impl_cost` | 2,500.00 | EUR | ASSUMPTION | Standard work + checklist + defect Pareto review (pelatihan 40 jam @ ~EUR 60 + materi) |
| `q07_lean_opex_total` | 1,000.00 | EUR | ASSUMPTION | Review mingguan 24 bulan |
| `q08_resched_impl_cost` | 3,000.00 | EUR | ASSUMPTION | SOP release takt 60 menit + papan release; 40 jam planner+engineer |
| `q08_resched_opex_total` | 1,000.00 | EUR | ASSUMPTION | Monitoring planner 24 bulan |
| `q08_ot_staff_slots` | 4.00 | slot | ASSUMPTION | +2 Paint Tech, +1 Press Operator, +1 Assembly Tech selama pekan lonjakan |
| `q08_ot_hours_per_slot` | 50.00 | jam | ASSUMPTION | 5 hari x 10 jam lembur per kejadian lonjakan |
| `q08_ot_premium` | 1.50 | x tarif | ASSUMPTION | Premi lembur 1,5x tarif dasar employee_master |
| `q08_ot_events_in_horizon` | 1.00 | kejadian | DATA | Hanya 1 lonjakan terobservasi (28 Apr 2025) |
| `q08_capex_paint_booth` | 1,500,000.00 | EUR | ASSUMPTION | Paint booth +1 (indikatif; ganti dengan kuotasi vendor) |
| `q08_capex_press_line` | 2,500,000.00 | EUR | ASSUMPTION | Press line +1 (indikatif) |
| `q08_capex_chassis_line` | 1,800,000.00 | EUR | ASSUMPTION | Chassis line +1 (indikatif) |
| `q08_asset_life_years` | 10.00 | tahun | ASSUMPTION | Depresiasi garis lurus; beban 24 bulan = capex x 2/10 |
| `q09_target_shortage_rate_high` | 0.12 | rasio | ASSUMPTION | Tingkat shortage High complexity diturunkan ke level Low/Medium (11-12%) |
| `q09_lean_impl_cost` | 3,000.00 | EUR | ASSUMPTION | Pre-check ketersediaan BOM saat validasi + alert pemasok (tanpa stok pengaman) |
| `q09_lean_opex_total` | 1,000.00 | EUR | ASSUMPTION | Pemeliharaan alert 24 bulan |
| `q09_safety_stock_value` | 60,000.00 | EUR | ASSUMPTION | Nilai stok pengaman komponen kritis High complexity (risiko stranded inventory) |
| `q09_holding_rate_annual` | 0.12 | rasio | ASSUMPTION | Biaya penyimpanan tahunan stok pengaman |
| `q09_impl_cost_buffer` | 8,000.00 | EUR | ASSUMPTION | Program pemasok + stok pengaman: kontrak call-off, sistem |
| `r1_intercept_effectiveness` | 0.40 | rasio | ASSUMPTION | Porsi cacat unrecoverable yang tertangkap pada checkpoint pasca-harness (tidak ada sinyal data - hipotesis) |
| `r1_checkpoint_min` | 15.00 | menit/kendaraan | ASSUMPTION | Uji fungsional tambahan pasca Electrical Harness |
| `r1_checkpoint_impl_cost` | 12,000.00 | EUR | ASSUMPTION | Fixture uji + prosedur + pelatihan |
| `r1_relaunch_impl_cost` | 5,000.00 | EUR | ASSUMPTION | Aturan ERP: otomatis membuat replacement order saat Production Scrapped |
| `r1_relaunch_retention` | 0.70 | rasio | ASSUMPTION | Porsi pelanggan MTO yang bersedia menunggu kendaraan pengganti |
| `r2_wip_value_share` | 0.50 | rasio | ASSUMPTION | Nilai WIP rata-rata saat menunggu = 50% biaya kumulatif case |

Tarif per jam (labor & equipment) pada skenario diambil dari `employee_master.hourly_cost_eur` dan `facility_master.hourly_facility_cost_eur`, bukan angka karangan.

## 5. Risiko double-counting & cara menghindarinya
- Biaya rework Road Test ulang dihitung **sekali** (komponen Dynamic Road Test `rework_flag=true`); tidak dijumlahkan lagi dengan baris Vehicle Defect Rectified.
- Pada R1, *avoided downstream cost* (biaya Interior→EOL unit cacat yang tertangkap) dan *relaunch contribution* (kendaraan pengganti) adalah arus yang berbeda: yang pertama biaya yang tidak terjadi, yang kedua kendaraan baru dengan biaya dan revenue penuh. Relaunch **tidak** dikreditkan ke checkpoint (relaunch dapat berjalan tanpa checkpoint).
- Time-value dan WIP carrying pada Q08 dihitung dari *selisih* hasil simulasi, tidak ditambahkan ke penghematan biaya lain.

## 6. Sensitivitas ringkas
- Q07: penghematan kotor maksimum (reduction 20%, avoidable 100%) = €10.863; program impas bila total biaya ≤ €6.429.
- R1 (dasar: efektivitas checkpoint 40%, retensi 70% → net +€101.975):
  - retensi 50% → net **+€72.215**; retensi 0% (checkpoint saja) → net **−€2.185** (checkpoint tidak layak berdiri sendiri);
  - efektivitas checkpoint 0% (tidak menangkap apa pun) dengan retensi 70% → net **+€77.635**; *relaunch saja* (tanpa checkpoint) → **+€99.160**.
  - Kesimpulan: **±97% manfaat R1 bergantung pada kebijakan relaunch dan retensi pelanggan**; checkpoint pasca-harness secara finansial marginal dan hanya dibenarkan bila efektivitas intersepsi ≥ ≈ 35% (impas checkpoint: (€12.000 + €9.525) / €60.850 = 35,4%). Pilot 3 bulan disarankan sebelum skala penuh.
- Capex Q08 (Paint Booth €1,5 jt, Press €2,5 jt, Chassis €1,8 jt) bersifat indikatif; bahkan dengan capex setengahnya net tetap negatif (−€150 rb untuk C1).

## 7. Batasan
Tidak ada data: biaya waiting, expedite, penalti SLA, shift/kalender kapasitas, replacement order untuk scrap, demand backlog. Hasil simulasi replay dikalibrasi pada total wait (+4,1% vs aktual) dan dipakai untuk perbandingan relatif.
