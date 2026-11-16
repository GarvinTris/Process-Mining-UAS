Q04 -- Paint and Road-Test Rework
Pertanyaan: Analisis rework pada Painting, Quality Inspection, Road
Test, atau area relevan. Bedakan genuine rework dari duplicate source
record; hitung Recorded Rework Cost dan kaitkan dengan potential quality
loss atau failed first pass.

Bukti (Evidence)
Dataset yang dianalisis berisi 5.888 baris raw event. Setelah
pemeriksaan dan pembersihan duplicate source records, clean event log
berisi 5.750 event pada 205 production cases. Pemeriksaan duplicate
dilakukan berdasarkan event_id pada raw data; duplicate source rows
tidak dihitung sebagai rework.

| Rework activity | Events | Recorded cost (EUR) |

| --- | --- | --- |

| Paint Rework Completed | 26 | €24,942.71 |

| Vehicle Defect Rectified | 22 | €25,005.14 |

| Repeated Dynamic Road Test | 22 | €4,369.26 |

| Total | 70 | €54,317.11 |

Ketiga kelompok aktivitas tersebut mencakup 70 genuine rework-related
events pada 44 unique cases. Rework incidence adalah 44/205 atau sekitar
21,46% dari seluruh cases. Sebanyak 23 event memiliki rework_flag =
TRUE, sementara aktivitas Paint Rework Completed dan Vehicle Defect
Rectified juga teridentifikasi melalui nama aktivitas walaupun flag-nya
tidak selalu TRUE.

Business Interpretation
Rework terkonsentrasi pada painting, defect rectification, dan
pengulangan Dynamic Road Test. Hal ini menunjukkan adanya pekerjaan
korektif setelah proses utama atau pemeriksaan kualitas. Paint Rework
Completed dan Vehicle Defect Rectified memiliki recorded cost terbesar,
sehingga area painting dan defect resolution layak menjadi prioritas
investigasi. Pengulangan aktivitas Road Test juga menunjukkan kendaraan
tertentu memerlukan pengujian ulang sebelum dapat melanjutkan proses.
Financial Implications
Recorded Rework Cost mencapai €54,317.11. Nilai ini merupakan biaya
aktivitas yang tercatat pada event rework-related, bukan estimasi
seluruh kerugian kualitas. Potensi biaya tambahan seperti scrap,
warranty, rework material, overtime, dan kehilangan kapasitas belum
tentu seluruhnya tercermin dalam angka tersebut. Biaya Paint Rework
Completed sebesar €24,942.71 dan Vehicle Defect Rectified sebesar
€25,005.14 menyumbang bagian terbesar dari recorded rework cost.

No-Action Consequences

- Rework berulang dapat terus menyerap jam kerja, material, dan
  kapasitas fasilitas yang seharusnya digunakan untuk unit baru.
- Jika akar masalah painting atau defect tidak diperbaiki, potensi
  defect berulang dapat meningkatkan biaya per kendaraan.
- Pengulangan road test dapat memperpanjang lead time dan menunda
  kendaraan memasuki tahap delivery.

  Recommended Action

- Lakukan root-cause analysis pada Paint Rework Completed dan Vehicle
  Defect Rectified berdasarkan model kendaraan, trim, fasilitas, dan
  urutan aktivitas.
- Pisahkan defect berdasarkan kategori, lokasi proses, dan penyebab
  agar tindakan korektif tidak hanya berfokus pada pengulangan
  inspeksi.
- Pantau rework rate per case, recorded rework cost per vehicle, dan
  first-pass yield setelah tersedia status pass/fail inspeksi yang
  eksplisit.
- Perbaiki konsistensi pengisian rework_flag agar event rework dapat
  diidentifikasi tanpa hanya mengandalkan nama aktivitas.
  Batasan: data tidak menyediakan field first-pass pass/fail yang cukup
  untuk menghitung First Pass Yield (FPY) aktual. Rework incidence
  digunakan sebagai indikator potensi quality loss, bukan bukti langsung
  bahwa seluruh case gagal pada first pass.
