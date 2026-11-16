Q06 -- Resource Dependency and Capacity
Pertanyaan: Bandingkan resource scheduling, waiting queues, dan
overlapping parallel operations. Apakah terdapat hambatan akibat limited
production cells dibanding lama durasi aktivitas? Jelaskan implikasi
terhadap unit throughput dan operational cost.

Bukti (Evidence)
Clean event log berisi 5.750 events. Total waiting time mencapai 171,066
menit, sedangkan total activity processing duration mencapai 256,067
menit. Rasio waiting time terhadap processing time adalah sekitar
66.81%; dengan denominator waiting + processing, waiting menyumbang
sekitar 40.05%.

| Activity | Total waiting time |

| --- | --- |

| Color Coat Applied | 41,517 minutes |

| Primer Application Completed | 35,151 minutes |

| Body Panels Stamped | 31,709 minutes |

| Chassis Assembly Completed | 22,416 minutes |

| Production Order Received | 13,790 minutes |

| Resource | Executions | Average wait | Total wait |

| --- | --- | --- | --- |

| RES-022 | 97 | 401.28 min | 38,924 min |

| RES-021 | 584 | 60.97 min | 35,609 min |

| RES-015 | 33 | 515.30 min | 17,005 min |

| RES-014 | 163 | 90.21 min | 14,704 min |

| RES-003 | 46 | 164.43 min | 7,564 min |

RES-015 memiliki average waiting time tertinggi di antara resource yang
ditampilkan, yaitu 515.30 menit, sedangkan RES-022 mengakumulasi total
waiting time tertinggi sebesar 38,924 menit. RES-021 memiliki frekuensi
eksekusi tertinggi, yaitu 584, dan total waiting time 35,609 menit.

Business Interpretation
Akumulasi waiting time menunjukkan adanya potensi antrean dan
ketidakseimbangan penjadwalan. Aktivitas pengecatan memiliki total
waiting time paling besar, sehingga area Paint Booth layak ditinjau
bersama kapasitas dan pola handoff dari proses sebelumnya. Perbedaan
antara resource dengan rata-rata tunggu tinggi dan resource dengan total
tunggu tinggi menunjukkan bahwa bottleneck dapat muncul karena waktu
tunggu per pekerjaan maupun tingginya volume pekerjaan.

Overlapping parallel operations harus dibedakan antara paralelisme yang
valid dan konflik resource. Dua aktivitas pada case yang sama dapat
overlap secara sah apabila memakai resource/fasilitas berbeda. Overlap
pada resource atau facility yang sama merupakan sinyal yang perlu
diperiksa, tetapi belum otomatis membuktikan konflik fisik karena
kualitas timestamp, pencatatan event, dan aturan kapasitas juga perlu
divalidasi.
Financial Implications
Waiting time yang tinggi berpotensi meningkatkan biaya tenaga kerja,
fasilitas, dan overhead apabila resource tetap tersedia selama pekerjaan
menunggu. Penjadwalan yang tidak seimbang juga dapat menurunkan jumlah
unit yang selesai per periode (throughput), sehingga biaya tetap
tersebar pada output yang lebih sedikit. Nilai biaya tambahan akibat
waiting tidak dihitung sebagai angka pasti karena tarif resource,
facility utilization, shift calendar, downtime, dan biaya idle per jam
perlu dikaitkan secara eksplisit.

No-Action Consequences

- Antrean pada aktivitas pengecatan dan resource dengan waiting tinggi
  dapat terus memperpanjang production lead time.
- Throughput kendaraan dapat tertahan apabila pekerjaan menumpuk pada
  fasilitas atau resource yang kapasitasnya terbatas.
- Biaya operasional berpotensi meningkat melalui waktu idle, overtime,
  penggunaan fasilitas lebih lama, dan penjadwalan ulang.
- Parallel operations yang tidak dikendalikan dapat menimbulkan
  konflik jadwal atau handoff yang tidak sinkron.

  Recommended Action

- Prioritaskan pemeriksaan kapasitas, jadwal shift, downtime, dan
  utilisasi aktual pada Paint Booth serta resource RES-022 dan
  RES-015.
- Seimbangkan beban kerja antar-resource yang memiliki skill dan
  kapabilitas setara; gunakan aturan dispatching berdasarkan prioritas
  dan kesiapan material.
- Tinjau handoff antaraktivitas untuk mengurangi waktu menunggu
  sebelum painting, stamping, dan chassis assembly.
- Validasi hasil overlap dengan timeline event, resource calendar, dan
  facility capacity sebelum menyatakan adanya konflik.
- Pantau waiting-to-processing ratio, throughput kendaraan per shift,
  SLA violation, resource utilization, dan cost per completed vehicle.
  Batasan: master data capacity yang menunjukkan kapasitas nominal tidak
  cukup untuk membuktikan overload tanpa jam operasional, downtime, dan
  kalender shift. Angka overlap event-pair dari Query 4 perlu dilampirkan
  dari hasil eksekusi DuckDB aktual; dokumen ini tidak mengarang jumlah
  overlap. Oleh karena itu, limited production cells diperlakukan sebagai
  potensi kendala yang perlu diverifikasi, bukan kesimpulan kausal.
  Ringkasan Prioritas Tindak Lanjut
  | Question | Main finding | Priority action |

| --- | --- | --- |

| Q04 -- Rework | 70 rework-related events; 44 cases; €54,317.11
recorded cost | Root-cause analysis pada painting dan defect
rectification; perbaiki pencatatan rework flag. |

| Q05 -- Shortage | 38 cases; median lead time 24.88h vs 17.17h;
cost/case €28,812.39 vs €26,317.94 | Perkuat material readiness,
safety stock, parts kitting, dan supplier delivery monitoring. |

| Q06 -- Capacity | 171,066 menit waiting; 66.81% dari processing
duration; resource dan aktivitas tertentu memiliki antrean tinggi |
Audit Paint Booth/resource scheduling, validasi overlap, dan
optimalkan handoff serta kapasitas. |
