# MANUAL BOOK PANDUAN PENGGUNA
## APLIKASI PEMELIHARAAN (HAR) & LOGSHEET PEMBANGKIT LISTRIK
### PT PLN NUSA DAYA — SISTEM KONTROL OPERASI WACB PLTD

---

```
========================================================================================
                  PT PLN NUSA DAYA — DIVISI PEMELIHARAAN & OPERASI
           PANDUAN OPERASIONAL RESMI APLIKASI PLN HAR & LOGSHEET MOBILE
                       Versi 2.4.0 — Edisi Pemeliharaan 2026
========================================================================================
```

---

## DAFTAR ISI

- [BAB 1: PENGENALAN APLIKASI](#bab-1-pengenalan-aplikasi)
  - [1.1 Latar Belakang & Tujuan](#11-latar-belakang--tujuan)
  - [1.2 Ruang Lingkup Sistem](#12-ruang-lingkup-sistem)
  - [1.3 Hak Akses & Peran Pengguna (User Roles)](#13-hak-akses--peran-pengguna-user-roles)
  - [1.4 Spesifikasi Perangkat Minimum](#14-spesifikasi-perangkat-minimum)
- [BAB 2: INSTALASI & MASUK KE SISTEM (LOGIN)](#bab-2-instalasi--masuk-ke-sistem-login)
  - [2.1 Instalasi Aplikasi pada Android (APK)](#21-instalasi-aplikasi-pada-android-apk)
  - [2.2 Menjalankan Versi Web (Browser)](#22-menjalankan-versi-web-browser)
  - [2.3 Alur Masuk (Login Akun)](#23-alur-masuk-login-akun)
  - [2.4 Memilih & Mengganti Unit Pembangkit (Pilih Unit PLTD)](#24-memilih--mengganti-unit-pembangkit-pilih-unit-pltd)
- [BAB 3: ANTARMUKA BERANDA (GAYA RESMI PLN MOBILE)](#bab-3-antarmuka-beranda-gaya-resmi-pln-mobile)
  - [3.1 Sky Header & Lencana Sistem](#31-sky-header--lencana-sistem)
  - [3.2 Kartu Status Operasi Melayang (Floating Cockpit Card)](#32-kartu-status-operasi-melayang-floating-cockpit-card)
  - [3.3 Baris 4 Kategori Cepat](#33-baris-4-kategori-cepat)
  - [3.4 Grid 12 Ikon Squircle Cyan (Fitur Operasi)](#34-grid-12-ikon-squircle-cyan-fitur-operasi)
  - [3.5 Bilah Navigasi Bawah & Tombol Pindai QR Melayang](#35-bilah-navigasi-bawah--tombol-pindai-qr-melayang)
- [BAB 4: PANDUAN CHECKLIST PEMELIHARAAN (HAR)](#bab-4-panduan-checklist-pemeliharaan-har)
  - [4.1 Membuat Laporan HAR Baru](#41-membuat-laporan-har-baru)
  - [4.2 Pengisian Parameter Operasi & Pengukuran Mesin](#42-pengisian-parameter-operasi--pengukuran-mesin)
  - [4.3 Pemeriksaan 4 Subsistem Komponen](#43-pemeriksaan-4-subsistem-komponen)
  - [4.4 Pencatatan Temuan Lapangan & Tindakan Perbaikan](#44-pencatatan-temuan-lapangan--tindakan-perbaikan)
  - [4.5 Unggah Dokumentasi Foto Lapangan & Geotagging](#45-unggah-dokumentasi-foto-lapangan--geotagging)
  - [4.6 Pengesahan & Tanda Tangan Digital](#46-pengesahan--tanda-tangan-digital)
- [BAB 5: DETAIL LAPORAN & PERSETUJUAN SUPERVISOR (SPV APPROVAL)](#bab-5-detail-laporan--persetujuan-supervisor-spv-approval)
  - [5.1 Alur Stepper Timeline Validasi Dokumen](#51-alur-stepper-timeline-validasi-dokumen)
  - [5.2 Kokpit Telemetri Real-Time 4 Parameter](#52-kokpit-telemetri-real-time-4-parameter)
  - [5.3 Prosedur 1-Klik Persetujuan Supervisor (Approve HAR)](#53-prosedur-1-klik-persetujuan-supervisor-approve-har)
- [BAB 6: EXPORT & IMPORT DATA MULTI-FORMAT](#bab-6-export--import-data-multi-format)
  - [6.1 Cetak Berita Acara Resmi PDF (Landscape & Satuan)](#61-cetak-berita-acara-resmi-pdf-landscape--satuan)
  - [6.2 Export Lembar Kerja Excel (.xlsx) Multi-Sheet](#62-export-lembar-kerja-excel-xlsx-multi-sheet)
  - [6.3 Export Data Tabular CSV (.csv)](#63-export-data-tabular-csv-csv)
  - [6.4 Backup Lengkap JSON (.json)](#64-backup-lengkap-json-json)
  - [6.5 Import Data Laporan dari Excel / CSV](#65-import-data-laporan-dari-excel--csv)
- [BAB 7: MANAJEMEN INVENTARIS MESIN PLTD](#bab-7-manajemen-inventaris-mesin-pltd)
  - [7.1 Katalog Mesin & Spesifikasi Teknis](#71-katalog-mesin--spesifikasi-teknis)
  - [7.2 Pemantauan Status Operasi, Standby, dan Gangguan](#72-pemantauan-status-operasi-standby-dan-gangguan)
  - [7.3 Unduh Database Inventaris Mesin ke Excel](#73-unduh-database-inventaris-mesin-ke-excel)
- [BAB 8: PANDUAN KESELAMATAN K3 & PENANGANAN GANGGUAN (TROUBLESHOOTING)](#bab-8-panduan-keselamatan-k3--penanganan-gangguan-troubleshooting)
  - [8.1 Kepatuhan SOP Zero Accident & K3 Pembangkit](#81-kepatuhan-sop-zero-accident--k3-pembangkit)
  - [8.2 Solusi Kendala Instalasi & Build Android (Java 17 / SDK)](#82-solusi-kendala-instalasi--build-android-java-17--sdk)
  - [8.3 Solusi Sinkronisasi Jaringan Offline](#83-solusi-sinkronisasi-jaringan-offline)

---

# BAB 1: PENGENALAN APLIKASI

### 1.1 Latar Belakang & Tujuan
Aplikasi **PLN HAR & Logsheet Mobile** dikembangkan khusus untuk PT PLN Nusa Daya guna mendigitalkan proses pemeliharaan harian/berkala (*Preventive & Corrective Maintenance*) dan pencatatan logsheet 48-slot (*WACB*) pada unit-unit Pembangkit Listrik Tenaga Diesel (PLTD).

Tujuan utama sistem ini meliputi:
1. **Menghilangkan Pencatatan Manual Kertas:** Mempercepat pelaporan dari lapangan langsung ke pangkalan data cloud.
2. **Standardisasi Berita Acara Pemeliharaan:** Setiap inspeksi otomatis menghasilkan berkas Berita Acara resmi berformat PDF bertanda tangan digital.
3. **Audit Kepatuhan SOP K3:** Memastikan setiap item kritis (tekanan oli, filter udara, pendingin radiator, sistem kelistrikan) diperiksa sesuai batas aman manufaktur.
4. **Interoperabilitas Data:** Kemampuan ekspor dan impor multi-format (PDF, Excel `.xlsx`, CSV, dan JSON) untuk mempermudah audit korporat.

### 1.2 Ruang Lingkup Sistem
Aplikasi ini melayani unit pembangkit di lingkungan operasional PLN Nusa Daya, termasuk namun tidak terbatas pada:
- **PLTD Batu Ampar** (Site Balikpapan / Wilayah 05)
- **ULD Muara Pahu** (Site Kutai Barat)
- **PLTD Gunung Malang, PLTD Nunukan, dan PLTD Karimunjawa**

### 1.3 Hak Akses & Peran Pengguna (User Roles)

| Peran (Role) | Tanggung Jawab Operasional | Wewenang dalam Aplikasi |
| :--- | :--- | :--- |
| **Teknisi Lapangan** *(Operator / HAR)* | Melaksanakan checklist fisik mesin, mencatat jam operasi (HM), tekanan oli, stand KWH/BBM, foto bukti pengerjaan. | Input Checklist HAR baru, input logsheet WACB, tanda tangan pelaksana, export PDF satuan. |
| **Supervisor Operasi** *(SPV)* | Memvalidasi kebenaran parameter teknis, mengevaluasi catatan anomali, memberikan persetujuan formal. | Review laporan status `submitted`, melakukan 1-klik approval Berita Acara, tanda tangan SPV digital. |
| **Super Admin** | Konfigurasi sistem wilayah, manajemen master data unit & mesin, backup database. | Akses seluruh unit wilayah kerja, import/export data massal, reset data lokal. |

### 1.4 Spesifikasi Perangkat Minimum

- **Smartphone Android:**
  - Versi OS: Android 8.0 (Oreo) ke atas (Direkomendasikan Android 11 / 12 / 13 / 14).
  - RAM: Minimal 2 GB (Direkomendasikan 4 GB).
  - Kamera: Dilengkapi kamera autofocus untuk dokumentasi bukti lapangan dan pemindai QR.
  - Konektivitas: Mendukung jaringan 4G/Wi-Fi serta mode penyimpanan offline lokal.
- **Komputer / Laptop (Web Portal):**
  - Web Browser: Google Chrome versi 110+, Microsoft Edge, atau Mozilla Firefox.
  - Resolusi Layar: Minimal 1280 x 720 piksel.

---

# BAB 2: INSTALASI & MASUK KE SISTEM (LOGIN)

### 2.1 Instalasi Aplikasi pada Android (APK)

```
[Unduh Berkas APK] ──> [Izinkan Instalasi Sumber Dikenal] ──> [Buka Berkas APK] ──> [Selesai]
```

1. **Unduh Berkas APK:** Dapatkan berkas rilis resmi `pln-har-mobile-v2.4.0.apk` dari server internal atau portal web resmi.
2. **Pengaturan Keamanan:** Jika muncul peringatan *"File mungkin berbahaya"*, pilih **Tetap Download** / **Lanjutkan**.
3. **Buka Berkas:** Ketuk notifikasi download selesai atau buka dari pengelola berkas (*File Manager*).
4. **Konfirmasi Pasang:** Tekan tombol **Instal**. Tunggu hingga proses verifikasi paket selesai, lalu ketuk **Buka**.

### 2.2 Menjalankan Versi Web (Browser)
Aplikasi mendukung eksekusi penuh pada peramban web modern:
1. Buka Google Chrome di komputer Anda.
2. Akses alamat lokal atau server portal: `http://localhost:3000/#mobile-app` atau domain portal korporat.
3. Aplikasi akan langsung memuat tampilan antarmuka responsif mobile.

### 2.3 Alur Masuk (Login Akun)

```
   +-------------------------------------------------+
   |              PT PLN NUSA DAYA                   |
   |              Portal HAR & WACB                  |
   |                                                 |
   |  Username: [ kal3                             ] |
   |  Password: [ **********                       ] |
   |                                                 |
   |             [ MASUK KE SISTEM ]                 |
   +-------------------------------------------------+
```

1. Masukkan **Username** resmi Anda (Contoh: `kal3` atau NIP pegawai).
2. Masukkan **Kata Sandi** terdaftar.
3. Tekan tombol **Masuk Ke Sistem**.
4. Sistem akan memverifikasi token sesi dan mengarahkan Anda ke layar Beranda Utama.

### 2.4 Memilih & Mengganti Unit Pembangkit (Pilih Unit PLTD)
Setiap teknisi dapat bertugas di unit pembangkit yang berbeda:
1. Pada kartu status Beranda, ketuk tombol **`... Unit`** atau tombol **Ganti Unit**.
2. Sistem akan menampilkan daftar unit kerja dalam bentuk **Grid Kartu Interaktif**:
   - Menampilkan Nama Unit (misal: *PLTD BATU AMPAR*).
   - Kode Wilayah & Area kerja (*SITE BONTANG / KAL 3*).
   - Spesifikasi Daya Mampu Terpasang (*450 kW*).
   - Jumlah Mesin Aktif (*4 Unit Mesin*).
   - Indikator Status Operasi (*ONLINE / SINKRON 24 JAM*).
3. Ketuk kartu unit yang ingin Anda kelola. Aplikasi akan otomatis memuat konfigurasi mesin dan data logsheet unit tersebut.

---

# BAB 3: ANTARMUKA BERANDA (GAYA RESMI PLN MOBILE)

Desain aplikasi mengadopsi estetika resmi **PLN Mobile** untuk memberikan pengalaman navigasi yang intuitif, bersih, dan profesional.

```
+-------------------------------------------------------------------+
|  [⚡ PLN MOBILE]   Halo, Ahmad Teknisi      ( 🔔 )   ( 🔄 )       |
|                                                                   |
|  +-------------------------------------------------------------+  |
|  |  (👛) Daya Pembangkit  |  (⚡) Kesiapan (EAF) |  (...) Unit |  |
|  |       380 / 450 kW     |       99.2% Andal    |             |  |
|  +-------------------------------------------------------------+  |
|                                                                   |
|      ( ⚡ )             ( 📋 )          ( 🔧 )         ( ⚠️ )     |
|    Pembangkit          Logsheet       HAR Harian     Lapor AMC    |
+-------------------------------------------------------------------+
|                                 —                                 |
|  [📋 HAR]     [📝 Log]    [⚠️ AMC]    [⚡ KWH]   [🏭 Mesin] [📚 Arsip] |
|  [🔄 I/O]     [📍 GPS]    [📄 PDF]    [📦 Part]  [📖 K3]    [▦ Menu]  |
|                                                                   |
|  Event:                                                           |
|  [ Banner: Siaga Kelistrikan PLTD 24 Jam Non-Stop                ] |
|                                                                   |
|  ==================== BOTTON NAVIGATION ========================  |
|     (🏠)           (🔄)        [  (⚡)  ]        (📄)        (👤)  |
|    Beranda       Aktivitas    FLOATING QR       Laporan      Akun  |
+-------------------------------------------------------------------+
```

### 3.1 Sky Header & Lencana Sistem
- **Latar Gradien Biru Langit:** Menggunakan palet elektrik PLN (`#008CC8` hingga `#00BFEF`).
- **Lencana Korporat:** Tag putih `[⚡ PLN MOBILE]` dengan petir kuning sebagai identitas resmi.
- **Tombol Notifikasi (🔔):** Memberikan sinyal pemberitahuan status verifikasi tiket dari supervisor.
- **Tombol Sinkronisasi (🔄):** Memperbarui data lokal secara instan dengan basis data cloud.

### 3.2 Kartu Status Operasi Melayang (Floating Cockpit Card)
Kartu putih melayang di bagian atas menyajikan 3 indikator esensial:
1. **Daya Pembangkit:** Menampilkan rasio beban *real-time* terhadap daya mampu unit (Contoh: `380 / 450 kW`).
2. **Kesiapan (EAF):** Persentase faktor kesiapan pembangkit (*Equivalent Availability Factor*), standar di atas 95%.
3. **Pintasan Ganti Unit:** Tombol cepat untuk beralih unit kerja tanpa harus keluar akun.

### 3.3 Baris 4 Kategori Cepat
Terletak tepat di bawah kartu melayang dengan ikon bulat berlatar putih:
- **Pembangkit (Merah):** Membuka katalog dan kondisi generator unit.
- **Logsheet (Cyan):** Membuka formulir pencatatan slot jam operasional.
- **HAR Harian (Hijau):** Membuka formulir inspeksi preventif mesin.
- **Lapor AMC (Kuning):** Saluran darurat pelaporan anomali dan gangguan mesin.

### 3.4 Grid 12 Ikon Squircle Cyan (Fitur Operasi)
Pada lembar putih melengkung di bawahnya, terdapat **12 tombol squircle cyan solid (`#00A2E8`)** dengan fungsi:

1. **Pemeriksaan HAR:** Membuka formulir input checklist inspeksi komponen mesin.
2. **Logsheet Mesin:** Membuka lembar pencatatan parameter 48-slot WACB.
3. **Lapor Gangguan (AMC):** Formulir pelaporan kerusakan atau temuan darurat.
4. **Catat Stand KWH & BBM:** Pencatatan konsumsi bahan bakar solar dan produksi KWH meter.
5. **Inventaris Mesin PLTD:** Melihat data pelat nama (*nameplate*), nomor seri, dan riwayat mesin.
6. **Riwayat Laporan HAR:** Melihat arsip seluruh tiket inspeksi yang telah disubmit.
7. **Export & Import Data:** Menu ekspor dan impor data ke format PDF, Excel, CSV, dan JSON.
8. **Presensi Mandiri GPS:** Validasi kehadiran teknisi berbasis radius geofence lokasi PLTD.
9. **Cetak Berita Acara (PDF):** Cetak cepat rekapitulasi laporan resmi bertanda tangan.
10. **Stok Part & Oli Pelumas:** Pemantauan persediaan filter solar, filter oli, dan pelumas drum.
11. **Pedoman K3 & SOP Mesin:** Pustaka dokumen keselamatan kerja dan manual pengoperasian mesin.
12. **Menu Operasi Lainnya:** Menampilkan menu alat bantu tambahan dan utilitas diagnostik.

### 3.5 Bilah Navigasi Bawah & Tombol Pindai QR Melayang
Navigasi bawah dirancang khusus dengan **Tombol Pindai QR Melayang di Bagian Tengah**:
- **Beranda:** Layar utama kokpit perintah.
- **Aktivitas:** Pemantauan status mesin dan jadwal inspeksi aktif.
- **Tombol Tengah (Floating Cyan Scanner `[ ⚡ ]`):** Tombol bulat melayang 58px berkilau gradien cyan. Jika ditekan, langsung membuka antarmuka pemindai QR untuk memindai pelat kode mesin di lapangan secara instan.
- **Laporan:** Membuka daftar rekapitulasi riwayat pemeliharaan.
- **Akun:** Profil pengguna, peran, dan pengaturan aplikasi.

---

# BAB 4: PANDUAN CHECKLIST PEMELIHARAAN (HAR)

### 4.1 Membuat Laporan HAR Baru
1. Pada Beranda, ketuk ikon squircle **Pemeriksaan HAR** atau tombol **Checklist Shift Aktif**.
2. Nomor tiket Berita Acara akan dibuat secara otomatis oleh sistem (Format: `HAR-YYYY-XXXXX`, contoh: `HAR-2026-00021`).
3. Pilih **Tanggal Pemeriksaan** dan **Slot Waktu (WITA)**.
4. Pilih **Mesin PLTD** yang akan diinspeksi (misal: *PLTD BATU AMPAR #01 (DEUTZ BF6M 1013 E)*).
5. Pilih **Prioritas Kerja** (*NORMAL*, *HIGH*, atau *CRITICAL*).

### 4.2 Pengisian Parameter Operasi & Pengukuran Mesin
Masukkan angka parameter operasional yang terbaca pada instrumen analog/digital genset:
- **Daya Mampu Mesin (kW):** Daya maksimal yang diizinkan untuk dibebani (Contoh: `450`).
- **Beban Berjalan (kW):** Daya aktif yang sedang disalurkan ke sistem jaringan (Contoh: `380`).
- **Tekanan Oli Pelumas (Bar):** Standar toleransi normal pabrikan antara **3.5 hingga 5.0 Bar**.
- **Hour Meter / Jam Kerja (HM):** Total jam akumulasi mesin beroperasi (Contoh: `1420`).
- **Stand Produksi KWH Meter & Stand Tangki BBM Solar.**

### 4.3 Pemeriksaan 4 Subsistem Komponen
Lakukan inspeksi fisik pada 4 subsistem utama mesin dan tentukan status kondisinya:

```
[Subsistem Mesin] ──> Pilih Status: [ ✓ BAIK (Normal) ] atau [ ⚠️ PERBAIKAN ] atau [ ✕ RUSAK ]
```

1. **Sistem Pelumasan:**
   - Pemeriksaan level oli pada *dipstick*.
   - Tekanan sirkulasi oli pelumas mesin.
   - Pengecekan kebocoran pada filter oli dan jalur pipa pelumasan.
2. **Sistem Udara & Gas Buang:**
   - Pemeriksaan kebersihan elemen saringan udara (*Air Filter*).
   - Indikator kevakuman saringan udara (*Air Restriction Indicator*).
   - Kondisi pipa saluran gas buang dan turbocharger.
3. **Sistem Pendingin & Radiator:**
   - Pemeriksaan level air radiator pada tangki ekspansi.
   - Pengecekan ketegangan tali kipas pendingin (*V-Belt*).
   - Pemeriksaan sirip-sirip radiator dari kotoran atau kebocoran mantel pendingin.
4. **Sistem Elektrikal & Generator:**
   - Pemeriksaan tegangan baterai starter (minimal 24 VDC).
   - Pemeriksaan tegangan terminal output generator (380V simetris 3-fasa, 50 Hz).
   - Kebersihan terminal pengkabelan dan panel kontrol genset.

### 4.4 Pencatatan Temuan Lapangan & Tindakan Perbaikan
- **Kolom Temuan Lapangan:** Tuliskan hasil observasi visual jika ditemukan anomali kecil (misal: *"Terdapat rembesan halus pada sambungan selang pendingin sebelah kiri"*). Jika semua baik, sistem otomatis mengisi toleransi normal.
- **Kolom Tindakan Dilakukan:** Tuliskan tindakan pemeliharaan yang telah dieksekusi (misal: *"Pembersihan elemen saringan udara, penambahan oli 2 Liter, pengencangan klem selang pendingin"*).

### 4.5 Unggah Dokumentasi Foto Lapangan & Geotagging
Unggah 3 dokumentasi foto wajib sebagai bukti fisik kepatuhan SOP:
1. **Foto Sebelum HAR (Kondisi Awal):** Foto mesin sebelum dilakukan tindakan.
2. **Foto Proses Pengerjaan:** Foto teknisi sedang melakukan checklist dengan APD lengkap.
3. **Foto Sesudah HAR (Kondisi Andal):** Foto mesin setelah selesai diperiksa dan siap dioperasikan.
*(Setiap foto secara otomatis tersemat stempel waktu WITA dan koordinat GPS Geotag unit pembangkit).*

### 4.6 Pengesahan & Tanda Tangan Digital
1. Di bagian akhir formulir, teknisi pelaksana membubuhkan tanda tangan digital pada kotak tanda tangan layar sentuh.
2. Tekan tombol **Simpan & Ajukan ke SPV**.
3. Status laporan akan otomatis berubah menjadi `submitted` (*Menunggu Approval SPV*).

---

# BAB 5: DETAIL LAPORAN & PERSETUJUAN SUPERVISOR (SPV APPROVAL)

### 5.1 Alur Stepper Timeline Validasi Dokumen
Setiap tiket pemeliharaan melalui alur 4 tahap resmi:

```
[1. Dibuat] ──> [2. Diajukan] ──> [3. Review SPV] ──> [4. Approved]
  (Teknisi)       (Cloud WACB)       (Evaluasi)         (Berita Acara)
```

- **Tahap 1 (Dibuat):** Teknisi menyelesaikan checklist fisik di ruang genset.
- **Tahap 2 (Diajukan):** Tiket terdaftar di sistem pusat dan ternotifikasi ke supervisor.
- **Tahap 3 (Review SPV):** Supervisor memeriksa parameter teknis dan temuan lapangan.
- **Tahap 4 (Approved):** Berita Acara disahkan secara hukum dan terkunci (*read-only*).

### 5.2 Kokpit Telemetri Real-Time 4 Parameter
Pada layar Detail HAR, disajikan kartu Bento Telemetri untuk mempermudah evaluasi cepat:
- **Beban vs Kapasitas:** Dilengkapi indikator visual persentase beban (Warna merah jika melebihi 90% kapasitas).
- **Tekanan Pelumasan:** Dilengkapi batas toleransi baku.
- **Hour Meter (HM):** Menghitung mundur sisa jam operasi menuju siklus servis berkala (P1: 50 Jam, P2: 250 Jam, P3: 500 Jam, P4: 1000 Jam, Top Overhaul: 3000 Jam).
- **Output Genset:** Menampilkan kestabilan tegangan 380V dan frekuensi 50 Hz.

### 5.3 Prosedur 1-Klik Persetujuan Supervisor (Approve HAR)
Bagi akun dengan wewenang **Supervisor / SPV Pemeliharaan**:
1. Buka tiket laporan yang berstatus **Menunggu Approval SPV**.
2. Periksa kesesuaian data checklist dan foto bukti lapangan.
3. Pada bilah aksi bawah, tekan tombol hijau: **Setujui & Approve HAR (1-Klik SPV)**.
4. Sistem akan membubuhkan stempel digital *"VERIFIED & APPROVED"* beserta tanda tangan digital supervisor.
5. Status laporan seketika berubah menjadi **Approved / Selesai**, dan dokumen Berita Acara resmi siap diunduh dalam format PDF.

---

# BAB 6: EXPORT & IMPORT DATA MULTI-FORMAT

Aplikasi dilengkapi mesin konversi dokumen lintas platform (*Export & Import Service*) yang bekerja secara mulus pada Android maupun Web Chrome.

### 6.1 Cetak Berita Acara Resmi PDF (Landscape & Satuan)
1. **Rekapitulasi Berita Acara (Landscape Multi-Halaman):**
   - Buka tab **Riwayat HAR**.
   - Tekan tombol **Export Data** (warna biru).
   - Pilih opsi **Cetak Berita Acara PDF (Landscape)**.
   - Sistem akan menghasilkan dokumen PDF resmi lengkap dengan kop surat PT PLN Nusa Daya, tabel rekapitulasi seluruh mesin, status checklist, breakdown anomali, serta kolom tanda tangan pejabat supervisor dan teknisi.
2. **Cetak Tiket Satuan (Portrait):**
   - Buka salah satu tiket pada **Detail HAR**.
   - Tekan tombol **Cetak & Unduh PDF** di sudut kanan atas atau pada bilah aksi bawah.
   - Dokumen Berita Acara individual per nomor tiket akan langsung terunduh.

### 6.2 Export Lembar Kerja Excel (.xlsx) Multi-Sheet
1. Pada menu Export, pilih opsi **Unduh Spreadsheet Excel (.xlsx)**.
2. Sistem akan menyusun berkas Excel resmi dengan 2 lembar kerja (*sheets*):
   - **Sheet 1 (Rekap HAR):** Berisi data induk tiket, tanggal, nama unit, mesin, teknisi, beban kW, tekanan oli, dan status persetujuan.
   - **Sheet 2 (Detail Checklist & Mesin):** Berisi rincian baris-demi-baris kondisi setiap komponen mesin (Level Oli, Filter Udara, Radiator, Baterai, dsb.).
3. Berkas siap dibuka di Microsoft Excel, WPS Office, atau Google Sheets.

### 6.3 Export Data Tabular CSV (.csv)
- Pilih opsi **Unduh Format CSV (.csv)** pada modal ekspor.
- Berkas data mentah berpemisah koma akan diunduh, sangat ideal untuk pengolahan data analitik, integrasi basis data SQL, atau pelaporan berkala.

### 6.4 Backup Lengkap JSON (.json)
- Pilih opsi **Cadangkan Database Lengkap (JSON)** untuk mencadangkan seluruh struktur data mentah lokal aplikasi beserta riwayat checklist dan foto, berguna untuk migrasi perangkat.

### 6.5 Import Data Laporan dari Excel / CSV

```
[Pilih File (.xlsx/.csv)] ──> [Validasi Otomatis] ──> [Modal Pratinjau Data] ──> [Simpan ke Database]
```

1. **Unduh Contoh Format:** Pada tab Riwayat, ketuk tombol **Unduh Template Import** untuk memperoleh berkas acuan `template_import_har.csv`.
2. **Pilih Berkas:** Ketuk tombol **Import File** (warna hijau).
3. **Pemilih Berkas Interaktif:** Pilih berkas `.xlsx`, `.xls`, `.csv`, atau `.json` dari penyimpanan perangkat.
4. **Validasi & Pratinjau:** Aplikasi membaca struktur kolom (*Unit, Mesin, Pelaksana, Tanggal, Beban, Kondisi*) dan menampilkan **Jendela Dialog Pratinjau Laporan**.
5. **Konfirmasi:** Tinjau ringkasan jumlah tiket yang berhasil diparsing, lalu tekan tombol **Simpan Data**.
6. Data laporan baru akan langsung muncul di daftar riwayat dan grafik dashboard.

---

# BAB 7: MANAJEMEN INVENTARIS MESIN PLTD

### 7.1 Katalog Mesin & Spesifikasi Teknis
Akses tab **Mesin** pada bilah navigasi bawah untuk melihat basis data pembangkit:
- **Identitas Mesin:** Nama resmi mesin, nomor seri (*Serial Number*), kode SILM PLN.
- **Pabrikan & Model:** Tipe mesin diesel (Contoh: *Caterpillar 3512B, Deutz TBD 620, Mitsubishi S12R, Perkins 4008*).
- **Kapasitas Daya:** Daya Terpasang (*DT*) dan Daya Mampu (*DM*) dalam satuan kW.

### 7.2 Pemantauan Status Operasi, Standby, dan Gangguan
Setiap mesin memiliki indikator warna status operasi:
- 🟢 **OPERASI:** Mesin sedang sinkron memikul beban jaringan listrik.
- 🟡 **STANDBY:** Mesin dalam kondisi siap operasi (*ready-to-start*) sewaktu-waktu dibutuhkan cadangan putar.
- 🔴 **GANGGUAN:** Mesin mengalami anomali teknis dan sedang dalam masa perbaikan.
- 🔵 **PEMELIHARAAN (HAR):** Mesin sedang dalam masa servis berkala terencana (P1 - P6).

### 7.3 Unduh Database Inventaris Mesin ke Excel
Pada layar Daftar Mesin, tekan ikon Excel di sudut kanan atas untuk mengunduh seluruh katalog mesin unit ke dalam berkas `daftar_mesin_pln.xlsx`.

---

# BAB 8: PANDUAN KESELAMATAN K3 & PENANGANAN GANGGUAN (TROUBLESHOOTING)

### 8.1 Kepatuhan SOP Zero Accident & K3 Pembangkit
Setiap teknisi pemeliharaan wajib mematuhi kaidah keselamatan kerja:
1. **Penggunaan APD Wajib:** Helm pengaman (*Safety Helmet*), sepatu tahan minyak (*Safety Shoes*), kacamata pelindung, dan penyumbat telinga (*Earplug/Earmuff*) di ruang mesin yang bising.
2. **Prosedur Lock-Out Tag-Out (LOTO):** Pasang rambu peringatan dan kunci sakelar pemutus sebelum melakukan inspeksi mekanikal pada komponen yang berputar.
3. **Pemeriksaan Suhu & Tekanan:** Jangan membuka tutup radiator saat suhu air pendingin masih di atas 80°C.

### 8.2 Solusi Kendala Instalasi & Build Android (Java 17 / SDK)
Jika saat menjalankan atau mengompilasi APK Android muncul pesan kesalahan:
```
Dependency requires at least JVM runtime version 11. This build uses a Java 8 JVM.
(Error: 25.0.3 / Gradle build failed)
```
**Langkah Penyelesaian:**
1. Pastikan komputer Anda terpasang **JDK 17**.
2. Periksa berkas `android/gradle.properties`, pastikan baris berikut terpasang:
   ```properties
   org.gradle.java.home=C:\\Program Files\\Java\\jdk-17
   ```
3. Bersihkan cache build lama dengan perintah:
   ```bash
   cd android && .\gradlew clean && cd ..
   ```
4. Jalankan kembali perintah instalasi ke perangkat:
   ```bash
   flutter run -d [ID_PERANGKAT]
   ```

### 8.3 Solusi Sinkronisasi Jaringan Offline
- **Kondisi Sinyal Lemah di Lapangan:** Aplikasi dirancang dengan penyimpanan lokal (*SharedPreferences Cache*). Seluruh data checklist, jam operasi, dan foto tetap tersimpan aman di memori telepon meskipun koneksi internet terputus.
- **Sinkronisasi Otomatis:** Begitu smartphone kembali mendapatkan sinyal 4G atau Wi-Fi kantor unit, buka aplikasi dan tekan tombol **Sinkronisasi (🔄)** pada bilah atas Beranda.

---

```
========================================================================================
                          DOKUMEN OPERASIONAL RESMI
                         PT PLN NUSA DAYA (PERSERO)
           Divisi Operasi & Pemeliharaan Pembangkit Tenaga Listrik
               Hak Cipta Dilindungi Undang-Undang Republik Indonesia
========================================================================================
```
