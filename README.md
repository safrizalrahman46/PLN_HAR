# PT PLN NUSA DAYA - MODUL PEMELIHARAAN (HAR) & OVERHAUL MESIN PLTD
### Wilayah Regional Kalimantan 3 (Kalimantan Timur & Kalimantan Utara)

Sistem Informasi Manajemen Pemeliharaan Terpadu (**HAR - Harkat & Pemeliharaan**) dan Monitoring Gangguan AMC Pembangkit Listrik Tenaga Diesel (PLTD) terisolir PT PLN Nusa Daya.

---

## 🏗️ Arsitektur Aplikasi & Ekosistem Multi-Aplikasi

Aplikasi ini merupakan bagian dari ekosistem 3 aplikasi terintegrasi PLN Nusa Daya:

| No | Aplikasi | Teknologi | Port | Fungsi Utama |
|---|---|---|---|---|
| **1** | **[LOGSHEETWEBPLNNUSADAYA](https://github.com/safrizalrahman46/LOGSHEETWEBPLNNUSADAYA)** | Golang Fiber + Next.js 15 + PostgreSQL | `:8080` (API) / `:3000` (Web) | Portal Pusat Supervisi, WACB Gateway, Export/Import Data Excel, Presensi GPS Geofencing |
| **2** | **[PLN_HAR](https://github.com/safrizalrahman46/PLN_HAR)** | Django REST Framework + React 19 Vite | `:8000` (API) / `:5173` (Web) | Sistem Pemeliharaan Mesin (HAR P1-P6), Checklist Teknisi, Approval SPV, dan Rekap AMC 2026 |
| **3** | **[PLN_NUSA_DAYA_APPS](https://github.com/safrizalrahman46/PLN_NUSA_DAYA_APPS)** | Flutter Mobile + SQLite Hive + WACB | Mobile Android | Aplikasi Lapangan Operator untuk input logsheet matriks 48 slot interval |

---

## ⚡ Fitur Utama PLN_HAR

1. **Pilih Unit Layanan PLTD (ULD)**:
   - Dukungan dinamis seluruh Unit Layanan PLTD Region Kalimantan 3:
     - **0283**: ULD MUARA PAHU (Site Bontang / Kutai Barat)
     - **0264**: ULD BATU AMPAR (Site Bontang)
     - **0265**: ULD BIDUK-BIDUK (Site Berau)
     - **0279**: ULD LONG SEGAR (Site Bontang)
     - **0281**: ULD KELAY (Site Berau)
     - **0288**: ULD MARATUA (Site Berau)
   - Sinkronisasi instan via `localStorage` sehingga konsisten dengan Portal Web Pusat.
2. **Inventaris Mesin Pembangkit**:
   - Filter mesin sesuai unit kerja (Caterpillar 3512B, Deutz TBD 620, Mitsubishi S12R/S16R, Perkins 4008TAG).
   - Indikator status mesin: `OPERASI` (Normal Andal), `STANDBY` (Siaga Sinkron), `GANGGUAN` (Perlu HAR).
3. **Penyusunan & Checklist Tiket HAR**:
   - 4-Langkah formulir terpadu: Informasi Umum, Checklist Komponen (Pelumasan, Pendinginan, Elektrikal), Temuan & Tindakan Perbaikan, serta Dokumentasi Lapangan.
   - Jam pelaksanaan bebas (00:00 - 24:00) tanpa restriksi jam kerja.
4. **Approval Supervisor 1-Klik**:
   - Tombol persetujuan instan bagi Supervisor Control Room untuk memvalidasi tiket HAR.
5. **Integrasi Laporan Gangguan AMC KIT KALTIMRA 2026**:
   - Rekap gangguan pasca-overhaul AMC dengan indikasi teknis, dampak penurunan daya, daftar kebutuhan material, dan progres tindak lanjut.
6. **Ekspor Berita Acara & Excel (.xlsx)**:
   - Ekspor rekapitulasi langsung berformat spreadsheet resmi PLN.

---

## 📡 Daftar REST API Endpoints

Backend Django berjalan pada `http://127.0.0.1:8000`:

### Autentikasi & Akun
- `POST /api/login`: Autentikasi user dan relay token WACB DIGIKIT.

### Unit & Mesin Pembangkit
- `GET /api/units/`: Daftar seluruh unit layanan PLTD Kalimantan 3.
- `GET /api/machines/`: Inventaris mesin pembangkit (bisa difilter via `?kd_unit=0283`).

### Pemeliharaan (HAR)
- `GET /api/har/`: Daftar riwayat tiket HAR (filter `?kd_unit=0283`).
- `POST /api/har/`: Pembuatan tiket HAR baru oleh teknisi.
- `GET /api/har/{id}/`: Detail tiket HAR beserta checklist dan dokumentasi.
- `PATCH /api/har/{id}/`: Approval tiket oleh Supervisor (`status='approved'`).

### Gangguan AMC 2026
- `GET /api/amc/`: Daftar gangguan AMC KIT KALTIMRA 2026.
- `POST /api/amc/`: Tambah laporan kendala mesin pasca-overhaul.

### Relasi Logsheet WACB
- `GET /api/v1/format-logsheet-pltd`: Format entri logsheet per unit pembangkit.
- `POST /api/v1/logsheet-pltd`: Submit data pembacaan jam operasional mesin.
- `GET /api/logsheet`: Matriks status 24 jam WACB.
- `GET /api/dashboard/stats`: Statistik ringkas HAR dan mesin.

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Backend (Django REST Framework)

```powershell
cd "d:\PLN PROJECT\PLN_HAR\backend"

# Jalankan migrasi database
python manage.py migrate

# Muat data awal (seluruh unit Kalimantan 3, mesin, HAR, dan AMC)
python manage.py seed_db

# Jalankan server API pada port 8000
python manage.py runserver 0.0.0.0:8000
```
API akan aktif di: `http://127.0.0.1:8000/api/`

---

### 2. Frontend (React 19 + Vite + Tailwind CSS)

```powershell
cd "d:\PLN PROJECT\PLN_HAR\frontend"

# Instal dependensi (bila belum)
npm install

# Jalankan development server
npm run dev
```
Web app akan aktif di: `http://localhost:5173/`

Untuk membuat build produksi:
```powershell
npm run build
```

---

## 🔒 Standar Lingkungan Kerja
- Wilayah Kerja: **PT PLN Nusa Daya - WACB Regional Kalimantan 3 (KD Region 05)**
- Satuan Pengukuran: Daya (kW), Tegangan (V), Arus (A), Tekanan Oli (bar), Temperatur Air (°C)
- Waktu Operasional: Waktu Indonesia Tengah (WITA, UTC+8)
