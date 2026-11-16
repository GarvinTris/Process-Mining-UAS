## Q03 – Manufacturing Bottleneck and Performance Analysis

### 1. Evidence and Descriptive Findings

Berdasarkan hasil analisis SQL, aktivitas produksi dengan masalah performa paling menonjol adalah **Color Coat Applied** pada workstation Painting. Aktivitas ini memiliki rata-rata Waiting Time tertinggi sebesar **211,82 menit**, rata-rata Processing Time sebesar **62,72 menit**, dan jumlah SLA Violation tertinggi sebanyak **51 kejadian** atau **26,02%** dari total eksekusinya. Total Activity Cost pada aktivitas ini adalah **EUR 144.381,69**.

Aktivitas lain yang juga menunjukkan masalah performa adalah **Primer Application Completed** pada Painting, dengan rata-rata Waiting Time **179,34 menit** dan 44 SLA Violation atau 22,45%. Sementara itu, **Body Panels Stamped** pada Stamping memiliki rata-rata Waiting Time **161,78 menit** dan 49 SLA Violation atau 25%.

Pada workstation Assembly, aktivitas **Chassis Assembly Completed** memiliki rata-rata Waiting Time **114,37 menit**, rata-rata Processing Time **78,12 menit**, serta 38 SLA Violation atau 19,39%. Sebaliknya, aktivitas pada Welding, yaitu **Body Welding Completed**, memiliki rata-rata Waiting Time hanya **4,16 menit** dan tidak menunjukkan SLA Violation pada hasil analisis.

Dari sisi Processing Time, beberapa aktivitas Assembly membutuhkan waktu pengerjaan yang relatif tinggi. Contohnya, Interior Assembly Completed memiliki rata-rata Processing Time **100,80 menit**, sedangkan Powertrain Installed membutuhkan **80,19 menit**. Hal ini menunjukkan bahwa waktu pengerjaan yang panjang tidak selalu disertai Waiting Time atau SLA Violation yang tinggi.

### 2. Diagnostic Reasoning

Hasil analisis menunjukkan bahwa masalah utama tidak tersebar secara merata pada seluruh workstation. Permasalahan paling terlihat terdapat pada Painting, khususnya aktivitas Color Coat Applied dan Primer Application Completed. Tingginya Waiting Time menunjukkan bahwa kendaraan atau pekerjaan produksi harus menunggu cukup lama sebelum aktivitas tersebut dapat diproses.

Pada Stamping, Body Panels Stamped juga memiliki Waiting Time dan SLA Violation yang tinggi. Kondisi ini mengindikasikan adanya potensi hambatan pada proses awal pembentukan body kendaraan.

Sementara itu, Assembly memiliki variasi performa. Chassis Assembly Completed menunjukkan waktu tunggu dan SLA Violation yang cukup tinggi, tetapi aktivitas lain seperti Interior Assembly Completed dan Powertrain Installed lebih menonjol dari sisi Processing Time. Artinya, perusahaan perlu membedakan antara masalah antrean pekerjaan dan lamanya proses pengerjaan.

Welding tidak menunjukkan masalah Waiting Time maupun SLA Violation yang signifikan berdasarkan data yang dianalisis. Oleh karena itu, perbaikan sebaiknya lebih diprioritaskan pada aktivitas Painting, Stamping, dan Chassis Assembly.

### 3. Completion Rate and Delivery Performance

Berdasarkan analisis terhadap 205 production orders, terdapat **182 order yang telah mencapai aktivitas Vehicle Delivered**, sedangkan 23 order belum mencapai aktivitas tersebut.

Dengan demikian, Delivery Completion Rate yang diperoleh adalah **88,78%**, sedangkan 11,22% order belum tercatat mencapai tahap pengiriman kendaraan. Rata-rata waktu dari Production Order Received hingga Vehicle Delivered adalah **1.715,34 menit**, atau sekitar **28,59 jam**.

Hasil ini menunjukkan bahwa sebagian besar order telah mencapai tahap pengiriman. Namun, masih terdapat sejumlah order yang belum mencapai aktivitas Vehicle Delivered sehingga perlu dilakukan pemeriksaan lebih lanjut terhadap status masing-masing order.

Perlu diperhatikan bahwa angka 88,78% merupakan persentase order yang mencapai aktivitas Vehicle Delivered dalam data, bukan On-Time Delivery Rate. Data tanggal target atau janji pengiriman diperlukan untuk menentukan apakah kendaraan benar-benar dikirim tepat waktu.

### 4. Business and Financial Implications

Waiting Time yang tinggi pada Painting dan Stamping berpotensi memperpanjang waktu penyelesaian produksi karena pekerjaan harus menunggu sebelum dapat diproses pada workstation berikutnya. Jika kondisi ini terus berlangsung, perusahaan berisiko mengalami penumpukan antrean, penggunaan kapasitas produksi yang kurang optimal, serta keterlambatan penyelesaian order.

Dari sisi finansial, aktivitas produksi memiliki biaya yang perlu diperhatikan. Sebagai contoh, Body Panels Stamped memiliki total Activity Cost sebesar EUR 276.664,60, sedangkan Chassis Assembly Completed memiliki total Activity Cost sebesar EUR 465.540,51. Powertrain Installed juga memiliki Activity Cost sebesar EUR 1.825.916,26.

Nilai tersebut menunjukkan besarnya biaya aktivitas yang tercatat dalam proses produksi. Namun, biaya aktivitas yang tinggi tidak otomatis berarti pemborosan karena perlu dibandingkan dengan volume pekerjaan, kompleksitas aktivitas, dan kontribusi yang dihasilkan.

Apabila masalah Waiting Time dan SLA Violation tidak ditangani, perusahaan berpotensi menghadapi peningkatan waktu produksi, risiko keterlambatan pengiriman, serta biaya operasional tambahan.

### 5. As-Is, No-Action, and To-Be

**As-Is:** Proses produksi menunjukkan adanya perbedaan performa antar-workstation. Painting dan Stamping memiliki Waiting Time serta SLA Violation yang relatif tinggi, sedangkan Welding menunjukkan performa Waiting Time yang lebih baik. Delivery Completion Rate tercatat sebesar 88,78%.

**No-Action:** Jika tidak dilakukan perbaikan, antrean pada aktivitas Painting dan Stamping berpotensi terus terjadi. Hal ini dapat memperpanjang waktu penyelesaian kendaraan, meningkatkan risiko pelanggaran SLA, dan memengaruhi ketepatan pengiriman kepada pelanggan.

**To-Be:** Perusahaan perlu mengurangi antrean pada aktivitas Painting dan Stamping, memperbaiki koordinasi antar-workstation, serta mengevaluasi kapasitas dan penjadwalan pada Chassis Assembly. Monitoring Waiting Time, Processing Time, SLA Violation, dan Delivery Completion Rate juga perlu dilakukan secara berkala.

### 6. Recommendations and Follow-Up Actions

Berdasarkan hasil analisis, rekomendasi yang dapat diberikan adalah:

1. **Prioritaskan perbaikan pada Painting.** Evaluasi antrean dan kapasitas kerja pada Color Coat Applied dan Primer Application Completed karena kedua aktivitas tersebut memiliki Waiting Time tinggi dan SLA Violation yang signifikan.
2. **Evaluasi proses Stamping.** Periksa penyebab tingginya Waiting Time dan SLA Violation pada Body Panels Stamped, termasuk kesiapan mesin, material, dan penjadwalan pekerjaan.
3. **Perbaiki koordinasi Assembly.** Evaluasi Chassis Assembly Completed untuk mengurangi waktu tunggu sebelum proses berikutnya.
4. **Pertahankan performa Welding.** Gunakan hasil performa Body Welding Completed sebagai bahan pembanding untuk mengidentifikasi praktik kerja yang dapat diterapkan pada workstation lain.
5. **Monitor penyelesaian order.** Lakukan pemeriksaan terhadap 23 order yang belum mencapai Vehicle Delivered untuk mengetahui apakah order masih dalam proses, dibatalkan, atau mengalami kendala lainnya.

Keberhasilan perbaikan dapat dievaluasi dengan membandingkan rata-rata Waiting Time, jumlah SLA Violation, rata-rata Throughput Time, dan Delivery Completion Rate sebelum dan sesudah tindakan dilakukan.

### 7. Conclusion

Hasil analisis Q03 menunjukkan bahwa bottleneck paling menonjol terdapat pada workstation Painting, khususnya Color Coat Applied, diikuti oleh aktivitas pada Stamping dan Chassis Assembly. Aktivitas tersebut memiliki Waiting Time dan SLA Violation yang relatif tinggi sehingga berpotensi menghambat kelancaran proses produksi.

Selain itu, Delivery Completion Rate tercatat sebesar 88,78% dari total 205 production orders, dengan rata-rata waktu dari penerimaan order hingga pengiriman sekitar 28,59 jam. Oleh karena itu, perusahaan perlu memprioritaskan pengurangan antrean pada Painting dan Stamping, meningkatkan koordinasi antar-workstation, serta memonitor status order yang belum mencapai tahap pengiriman.

Dengan perbaikan tersebut, perusahaan diharapkan dapat meningkatkan efisiensi proses produksi, mengurangi risiko pelanggaran SLA, dan memperbaiki performa pengiriman kendaraan.