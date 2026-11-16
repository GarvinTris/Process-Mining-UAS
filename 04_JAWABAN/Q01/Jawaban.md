# Q01 – Manufacturing Process Variants Analysis

## 1. Evidence and Data Source

Analisis Q01 dilakukan menggunakan cleaned event log `celonis_event_log_clean.csv`. Analisis bertujuan mengidentifikasi tiga variasi proses produksi kendaraan yang paling sering terjadi serta membandingkan kinerja masing-masing variasi berdasarkan Throughput Time, Activity Cost, Revenue, dan Profit Contribution.

Hasil SQL menunjukkan tiga Process Variants dengan jumlah kendaraan terbanyak, yaitu Variant 1 sebanyak 34 kendaraan, Variant 2 sebanyak 32 kendaraan, dan Variant 3 sebanyak 29 kendaraan.

## 2. Descriptive Finding

Berdasarkan hasil analisis, diperoleh rata-rata kinerja dari masing-masing Process Variant sebagai berikut:

- **Variant 1:** Digunakan oleh 34 kendaraan dengan rata-rata Throughput Time sebesar 1.019,12 menit, Activity Cost sebesar €24.276,54, Revenue sebesar €36.503,15, dan Profit Contribution sebesar €12.226,60.
- **Variant 2:** Digunakan oleh 32 kendaraan dengan rata-rata Throughput Time sebesar 2.696,44 menit, Activity Cost sebesar €24.265,41, Revenue sebesar €36.300,09, dan Profit Contribution sebesar €12.034,68.
- **Variant 3:** Digunakan oleh 29 kendaraan dengan rata-rata Throughput Time sebesar 1.110,72 menit, Activity Cost sebesar €25.962,48, Revenue sebesar €38.768,14, dan Profit Contribution sebesar €12.805,66.

Dari ketiga variasi tersebut, Variant 1 memiliki Throughput Time paling rendah, sedangkan Variant 2 memiliki Throughput Time paling tinggi. Variant 3 memiliki Activity Cost, Revenue, dan Profit Contribution paling tinggi.

## 3. Diagnostic Reasoning

Perbedaan kinerja tersebut berkaitan dengan perbedaan urutan aktivitas dalam proses produksi.

Pada Variant 1, aktivitas Materials Availability Checked dilakukan sebelum BOM and Routing Released. Sementara itu, pada Variant 2 dan Variant 3, BOM and Routing Released dilakukan terlebih dahulu sebelum Materials Availability Checked.

Perbedaan lainnya terdapat pada urutan Body Panels Stamped dan Chassis Assembly Completed. Pada Variant 1 dan Variant 3, Body Panels Stamped dilakukan sebelum Chassis Assembly Completed. Namun, pada Variant 2, Chassis Assembly Completed terjadi lebih dahulu.

Variant 2 perlu mendapatkan perhatian karena memiliki Throughput Time sebesar 2.696,44 menit, atau 1.677,32 menit lebih lama dibandingkan Variant 1. Meskipun Activity Cost kedua variasi hampir sama, Variant 2 menghasilkan Profit Contribution rata-rata yang lebih rendah.

Hal ini menunjukkan adanya potensi ketidakefisienan waktu pada Variant 2. Namun, penyebab pastinya masih perlu diperiksa melalui analisis aktivitas, waiting time, dan kondisi operasional pada setiap tahap produksi.

## 4. Business and Financial Implication

Perbedaan Process Variant dapat memengaruhi efisiensi waktu produksi, penggunaan biaya operasional, serta kontribusi finansial perusahaan.

Variant 1 menunjukkan kinerja waktu yang paling baik karena memiliki Throughput Time terendah. Kondisi ini berpotensi membantu perusahaan menyelesaikan pesanan kendaraan lebih cepat.

Variant 2 memiliki waktu produksi paling lama dan Profit Contribution rata-rata paling rendah, yaitu €12.034,68. Jika pola tersebut terus terjadi, perusahaan berpotensi menghadapi keterlambatan penyelesaian pesanan dan penggunaan kapasitas produksi yang kurang optimal.

Sementara itu, Variant 3 memiliki Activity Cost tertinggi sebesar €25.962,48, tetapi juga menghasilkan Revenue dan Profit Contribution tertinggi. Oleh karena itu, biaya yang lebih tinggi tidak selalu menunjukkan kinerja yang lebih buruk karena perlu dibandingkan dengan Revenue yang dihasilkan.

## 5. As-Is, No-Action Scenario, and To-Be

**As-Is Scenario**

Perusahaan saat ini memiliki beberapa variasi urutan aktivitas produksi. Variant 1 merupakan variasi yang paling sering terjadi dan memiliki waktu produksi paling singkat. Sebaliknya, Variant 2 membutuhkan waktu produksi paling lama, sedangkan Variant 3 memiliki biaya aktivitas paling tinggi.

**No-Action Scenario**

Jika perusahaan tidak melakukan evaluasi terhadap variasi proses tersebut, perbedaan waktu produksi dapat terus terjadi. Khususnya pada Variant 2, waktu penyelesaian produksi yang lebih lama berpotensi mengurangi fleksibilitas kapasitas produksi dan meningkatkan risiko keterlambatan pengiriman.

Selain itu, perusahaan dapat kehilangan kesempatan untuk mengidentifikasi aktivitas yang menyebabkan perbedaan kinerja antarvariasi.

**To-Be Scenario**

Perusahaan diharapkan memiliki proses produksi yang lebih konsisten dengan mengevaluasi urutan aktivitas dan mengidentifikasi penyebab tingginya Throughput Time pada Variant 2. Evaluasi juga perlu dilakukan terhadap komponen biaya pada Variant 3 agar penggunaan biaya tetap sebanding dengan nilai Revenue yang dihasilkan.

## 6. Recommendation, Risk, and Assumptions

Berdasarkan hasil analisis, rekomendasi yang dapat diberikan adalah:

1. Menggunakan Variant 1 sebagai referensi awal untuk mengevaluasi proses produksi karena memiliki frekuensi tertinggi dan Throughput Time terendah.
2. Melakukan pemeriksaan lebih lanjut terhadap Variant 2 untuk mengetahui penyebab Throughput Time yang jauh lebih tinggi dibandingkan variasi lainnya.
3. Mengevaluasi Activity Cost pada Variant 3 dengan memperhatikan kontribusi Revenue dan Profit Contribution yang dihasilkan.
4. Meninjau kembali urutan aktivitas produksi agar pelaksanaannya lebih konsisten dan sesuai dengan kebutuhan operasional.

Risiko yang perlu diperhatikan adalah bahwa Throughput Time yang lebih rendah tidak otomatis menjamin kualitas produksi lebih baik atau pengiriman selalu tepat waktu. Selain itu, perbedaan biaya dan Profit Contribution belum membuktikan bahwa perubahan urutan aktivitas merupakan penyebab langsung perbedaan kinerja.

Analisis ini membandingkan tiga Process Variants aktual yang paling sering terjadi. Perbandingan formal terhadap Standard Routing masih memerlukan referensi urutan proses standar resmi perusahaan.

## 7. Evidence File Paths and SQL References

- Data source: `01_DATA/cleaned/celonis_event_log_clean.csv`
- SQL analysis: Q01 – Manufacturing Process Variants
- Output evidence: Hasil tabel tiga Process Variants teratas yang menampilkan jumlah kendaraan, Throughput Time, Activity Cost, Revenue, dan Profit Contribution.
- Additional evidence: Process Map dari Celonis untuk memperlihatkan urutan aktivitas produksi aktual.

Hasil validasi menunjukkan bahwa `avg_contribution_validation_difference_eur` pada ketiga variasi bernilai 0. Hal ini menunjukkan bahwa perhitungan Profit Contribution sesuai dengan nilai yang tercatat dalam dataset.