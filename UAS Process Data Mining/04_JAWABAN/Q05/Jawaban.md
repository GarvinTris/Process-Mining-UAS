Q05 -- Parts Availability and Shortage
Pertanyaan: Uji hubungan Materials Availability / Parts Kitting dan
Supplier Shortage dengan lead time, variant, dan cost per order.
Jelaskan hipotesis Root Cause dan biaya keberlanjutan shortage.

Bukti (Evidence)
Analisis menemukan 38 unique production cases yang mengalami Supplier
Shortage Resolved (tercatat 39 event shortage-resolution). Dari event
shortage-resolution, recorded cost berjumlah €3,280.22 dengan rata-rata
durasi sekitar 53.24 menit.

| Metric | With shortage | Without shortage |

| --- | --- | --- |

| Delivered cases | 35 | 147 |

| Median production lead time | 24.88 hours | 17.17 hours |

| Average total activity cost per delivered case | €28,812.39 |
€26,317.94 |

Median lead time pada kelompok shortage lebih tinggi 7.71 jam (sekitar
45% dibanding kelompok tanpa shortage). Rata-rata total activity cost
per delivered case pada kelompok shortage lebih tinggi €2,494.45
(sekitar 9.48%). Angka rata-rata lead time sebelumnya menunjukkan pola
yang tidak sama dengan median; karena distribusi durasi dapat
dipengaruhi outlier, median digunakan untuk membandingkan waktu tipikal.

Business Interpretation
Kasus yang mengalami shortage memiliki median lead time dan average
activity cost per delivered case yang lebih tinggi. Pola ini konsisten
dengan kemungkinan bahwa material yang belum tersedia atau parts yang
belum siap menghambat kelanjutan proses produksi. Hipotesis root cause
meliputi keterlambatan pemasok, ketidakakuratan material planning,
safety stock yang tidak memadai, atau sinkronisasi antara purchasing,
warehouse, dan production scheduling yang belum optimal. Data yang
tersedia belum membuktikan penyebab spesifik maupun identitas pemasok.

Financial Implications
Recorded cost untuk penyelesaian shortage adalah €3,280.22. Selain itu,
kelompok shortage menunjukkan average total activity cost per delivered
case yang lebih tinggi €2,494.45 dibanding kelompok tanpa shortage.
Selisih tersebut adalah asosiasi biaya antar kelompok, bukan seluruhnya
biaya shortage yang dapat dihindari atau dampak kausal shortage. Sebagai
ilustrasi skenario, jika recorded shortage-resolution cost berulang dua
kali lipat, biayanya menjadi €6,560.44; jika tiga kali lipat, menjadi
€9,840.66. Skenario ini hanya simulasi aritmetika, bukan proyeksi.

No-Action Consequences

- Shortage yang berulang dapat mempertahankan antrean sebelum Parts
  Kitting atau aktivitas produksi berikutnya.
- Lead time yang lebih panjang dapat menunda penyelesaian dan
  pengiriman kendaraan.
- Perusahaan berisiko menanggung biaya tambahan untuk penanganan
  shortage, perubahan jadwal, dan penggunaan resource yang tidak
  optimal.

  Recommended Action

- Buat shortage dashboard yang menghubungkan Supplier Shortage
  Resolved, Parts Kitted, material readiness, dan production order.
- Ukur shortage frequency, shortage resolution time, lead time, serta
  cost per delivered case berdasarkan model, trim, dan production
  variant.
- Tinjau safety stock, reorder point, akurasi bill of materials, dan
  ketepatan jadwal kedatangan material.
- Lakukan supplier performance review menggunakan data purchase order
  dan promised-versus-actual delivery date apabila data tersebut
  tersedia.
  Batasan: event log tidak menyediakan rincian purchase order, supplier
  identity, atau timestamp pemesanan/pengiriman yang cukup untuk
  memastikan akar penyebab shortage. Perbandingan lead time dan cost
  menunjukkan hubungan observasional, bukan bukti kausal.
