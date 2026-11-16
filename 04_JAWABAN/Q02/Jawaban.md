# Q02 – Production Outcomes and Scrap Cost

**1. Evidence (Hasil Analisis)**

Berdasarkan hasil analisis SQL terhadap 205 Production Orders, ditemukan tiga kategori hasil produksi, yaitu Completed, Scrapped, dan Cancelled.

Hasil analisis menunjukkan:

- **Completed:** Terdapat 182 Production Orders (88,78%) yang berhasil diselesaikan. Total Consumed Cost sebesar EUR 4.877.170,24, Revenue sebesar EUR 6.811.566,96, dan Profit Contribution sebesar EUR 1.934.396,72. Rata-rata biaya per order adalah EUR 26.797,64.
- **Scrapped:** Terdapat 14 Production Orders (6,83%) yang mengalami kegagalan produksi atau Scrap. Total Consumed Cost mencapai EUR 344.556,10, tanpa menghasilkan Revenue. Kondisi ini menyebabkan Profit Contribution negatif sebesar EUR 344.556,10. Rata-rata biaya per order adalah EUR 24.611,15.
- **Cancelled:** Terdapat 9 Production Orders (4,39%) yang dibatalkan. Total Consumed Cost sebesar EUR 1.165,70, tanpa menghasilkan Revenue, sehingga Profit Contribution negatif sebesar EUR 1.165,70. Rata-rata biaya per order adalah EUR 129,52.

Secara keseluruhan, terdapat 23 Production Orders yang tidak menghasilkan Vehicle Sales, terdiri dari 14 Scrapped Orders dan 9 Cancelled Orders.

Total Consumed Cost dari kedua kategori tersebut mencapai EUR 345.721,80 tanpa menghasilkan Revenue.

**2. Business Interpretation**

Hasil analisis menunjukkan bahwa sebagian besar Production Orders berhasil diselesaikan, yaitu sebanyak 182 orders atau 88,78% dari keseluruhan produksi.

Namun, terdapat 14 orders yang mengalami Scrap dan 9 orders yang mengalami Cancellation. Dari kedua kategori tersebut, Scrapped Orders menjadi masalah utama karena memiliki biaya produksi yang jauh lebih besar dibandingkan Cancelled Orders.

Scrapped Orders menunjukkan bahwa perusahaan telah menggunakan sumber daya produksi seperti material, tenaga kerja, dan peralatan, tetapi kendaraan tidak berhasil diselesaikan untuk menghasilkan penjualan.

Sementara itu, Cancelled Orders memiliki total biaya yang relatif kecil. Hal ini menunjukkan bahwa sebagian besar biaya pada order yang tidak menghasilkan penjualan berasal dari proses produksi yang mengalami Scrap, bukan dari pembatalan pesanan.

**3. Financial Implications**

Dari sisi finansial, Completed Orders menghasilkan Revenue sebesar EUR 6.811.566,96 dengan Profit Contribution positif sebesar EUR 1.934.396,72.

Sebaliknya, Scrapped dan Cancelled Orders menghasilkan total biaya sebesar EUR 345.721,80 tanpa memberikan Revenue.

Scrapped Orders menyumbang EUR 344.556,10 atau sekitar 99,66% dari total biaya kedua kategori yang tidak menghasilkan penjualan. Hal ini menunjukkan bahwa Scrap merupakan sumber kerugian finansial yang jauh lebih besar dibandingkan Cancellation.

Kondisi tersebut dapat mengurangi keuntungan perusahaan karena biaya material, tenaga kerja, dan sumber daya lainnya sudah digunakan, tetapi tidak menghasilkan pendapatan dari penjualan kendaraan.

**4. No-Action Consequences**

Jika perusahaan tidak melakukan tindakan untuk mengurangi Scrap, biaya produksi yang tidak menghasilkan pendapatan berpotensi terus meningkat.

Perusahaan dapat mengalami pemborosan material, tenaga kerja, waktu mesin, dan kapasitas produksi. Selain itu, tingginya jumlah Scrapped Orders dapat menurunkan Profit Contribution dan menghambat pencapaian target produksi.

Jika masalah kualitas dan penyebab kegagalan produksi tidak segera diidentifikasi, perusahaan berisiko mengalami kerugian yang sama pada Production Orders berikutnya.

**5. Recommended Action**

Perusahaan disarankan untuk memprioritaskan pengurangan Scrap karena kategori ini memberikan kontribusi kerugian finansial terbesar.

Beberapa tindakan yang dapat dilakukan adalah:

- Meningkatkan Quality Inspection pada setiap tahapan produksi untuk mendeteksi kesalahan lebih awal.
- Mengidentifikasi penyebab utama kendaraan mengalami Scrap, terutama pada proses Stamping, Welding, Painting, dan Assembly.
- Meningkatkan pengawasan terhadap penggunaan material dan memastikan setiap komponen memenuhi standar kualitas.
- Melakukan evaluasi terhadap aktivitas produksi yang menyebabkan kegagalan agar kesalahan yang sama tidak terulang.
- Memantau Consumed Cost pada setiap Production Order untuk mengurangi pemborosan sumber daya.

Perusahaan juga perlu mengevaluasi proses pembatalan pesanan agar pembatalan dapat diketahui lebih awal sebelum terlalu banyak biaya produksi dikeluarkan.

**Conclusion**

Berdasarkan hasil analisis, sebanyak 182 dari 205 Production Orders berhasil diselesaikan, sedangkan 23 orders tidak menghasilkan penjualan karena mengalami Scrap atau Cancellation.

Scrapped Orders menjadi masalah paling signifikan karena menyebabkan biaya sebesar EUR 344.556,10 tanpa menghasilkan Revenue. Oleh karena itu, perusahaan perlu meningkatkan pengendalian kualitas dan melakukan evaluasi terhadap penyebab Scrap agar pemborosan biaya dapat dikurangi, efisiensi produksi meningkat, dan Profit Contribution perusahaan dapat dipertahankan.