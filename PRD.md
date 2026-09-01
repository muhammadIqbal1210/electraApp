Product Requirements Document (PRD)

ElectraTech Mobile: Platform Smart Agriculture, IoT & Blockchain Supply Chain Berbasis AI

|

| Atribut | Detail |
| Versi Dokumen | 1.0.0 |
| Status | Disetujui / Siap untuk Pengganti (Development Ready) |
| Target Platform | Mobile: Android & iOS (Flutter)  Admin Web: Next.js |
| Core Tech Stack | Backend: Node.js (Express.js)  Database: PostgreSQL  Blockchain: Hyperledger Fabric  IoT Broker: EMQX / Eclipse Mosquitto (MQTT)  AI Engine: Gemini API / OpenAI API |

1. Ringkasan Eksekutif (Executive Summary)

ElectraTech adalah ekosistem digital pertanian terpadu yang mengintegrasikan Internet of Things (IoT), Kecerdasan Buatan (AI Agent), Manajemen Rantai Pasok (Supply Chain Management), serta Buku Besar Terdistribusi (Blockchain Ledger).

Platform ini dirancang untuk menjawab tantangan efisiensi budidaya pertanian dan transparansi rantai distribusi dari hilir ke hulu (farm-to-table).

Nilai Utama (Key Value Propositions)

Transparansi & Imutabilitas Data: Seluruh riwayat budidaya dan perpindahan produk dicatat secara terdesentralisasi menggunakan Hyperledger Fabric untuk menjamin keaslian produk.

Presisi Budidaya Berbasis Data: Pengambilan data sensor IoT secara real-time memberikan parameter tanah dan lingkungan yang presisi bagi petani.

Asisten AI Terkontekstual: AI Agent memproses data sensor tanah, riwayat batch, dan log blockchain untuk memberikan rekomendasi spesifik serta diagnosa penyakit tanaman secara presisi.

2. Pernyataan Masalah & Tujuan Strategis

2.1 Pernyataan Masalah (Problem Statement)

| Sektor | Masalah Utama Lapangan | Dampak Operational & Bisnis |
| Budidaya | Pemantauan kondisi lahan masih dilakukan secara manual dan terputus-putus. | Risiko gagal panen tinggi karena keterlambatan penanganan perubahan parameter lahan. |
| Rantai Pasok | Pendokumentasian perpindahan barang terfragmentasi dan rentan manipulasi. | Asal-usul produk (traceability) sulit dibuktikan secara independen. |
| Konsumen | Ketiadaan mekanisme verifikasi atas klaim kualitas atau keaslian produk. | Tingkat kepercayaan konsumen terhadap klaim keaslian/kualitas produk rendah. |
| Pengambilan Keputusan | Petani mengambil tindakan budidaya berdasarkan asumsi intuitif semata. | Pemborosan pupuk/air serta hasil produksi panen tidak optimal. |

2.2 Tujuan Strategis (Strategic Goals)

Tujuan Bisnis: Meningkatkan nilai jual produk mitra tani melalui sertifikasi digital traceability, efisiensi operasional rantai pasok, dan komersialisasi platform AI-as-a-Service pertanian.

Tujuan Pengguna: Memberikan visibilitas penuh kondisi lahan bagi petani, kemudahan pencatatan distribusi bagi distributor, serta transparansi verifikasi keaslian produk bagi pembeli akhir.

3. Peran Pengguna & Matriks Hak Akses

                      ┌─────────────────────────────────────────┐
                      │              ElectraTech                │
                      └────────────────────┬────────────────────┘
                                           │
         ┌──────────────────┬──────────────┴───────┬──────────────────┐
         │                  │                      │                  │
         ▼                  ▼                      ▼                  ▼
┌─────────────────┐┌─────────────────┐  ┌─────────────────┐┌─────────────────┐
│     Petani      ││   Distributor   │  │ Buyer/Konsumen  ││      Admin      │
│ (Mobile App)    ││ (Mobile App)    │  │ (Mobile App)    ││ (Web Dashboard) │
└─────────────────┘└─────────────────┘  └─────────────────┘└─────────────────┘



| Fitur / Modul | Petani | Distributor | Buyer / Konsumen | Admin Web |
| Monitoring Sensor IoT | Baca / Tulis | - | - | Lihat |
| Manajemen Batch | Baca / Tulis | Lihat | Lihat | Baca / Tulis |
| Update Status Distribusi | Update Status | Update Status | - | Baca / Anulir |
| Verifikasi Kode QR | Buat Kode | Pemindaian | Pemindaian | Kelola |
| AI Smart Assistant & Diagnosis | Akses Penuh | - | Info Produk AI | Lihat Log |
| Manajemen Pengguna & Perangkat | - | - | - | Akses Penuh |
| Audit Blockchain Ledger Direct | - | - | - | Akses Penuh |

4. Persyaratan Fungsional (Functional Requirements)

4.1 Modul Autentikasi & Otorisasi

AUTH-01 (Masuk Akun): Pengguna dapat masuk menggunakan alamat email dan kata sandi yang valid.

AUTH-02 (Pendaftaran): Registrasi pengguna baru wajib menyertakan Nama Lengkap, Email, Kata Sandi, dan Peran Pengguna (Role).

AUTH-03 (Manajemen Token): Keamanan sistem menggunakan standar JSON Web Token (JWT) dengan skema Access Token dan Refresh Token.

4.2 Modul Dashboard Utama

DASH-01 (Visualisasi Metrik): Menampilkan ringkasan total Batch aktif, status sensor Online/Offline, dan aktivitas transaksi terbaru.

DASH-02 (Ringkasan AI Insight): Kartu informasi ringkas hasil analisis AI otomatis berdasarkan anomali sensor 24 jam terakhir.

4.3 Smart Farming (Monitoring IoT)

IOT-01 (Telemetri Real-time): Menampilkan parameter sensor: Suhu Udara (°C), Kelembaban Udara (%), Kelembaban Tanah (%), pH Tanah, Curah Hujan (mm), dan Intensitas Cahaya (Lux).

IOT-02 (Grafik Historis): Visualisasi grafik deret waktu (time-series) dengan filter waktu: 24 Jam, 7 Hari, dan 30 Hari.

IOT-03 (Notifikasi Anomali): Mengirimkan peringatan (push notification) ketika nilai sensor melebihi ambang batas (threshold) yang ditentukan.

4.4 Manajemen Batch Tanam

BATCH-01 (Pembuatan Batch): Petani dapat menginisiasi batch tanam baru dengan mengisi: Nama Tanaman, Varietas, Tanggal Tanam, Luas Lahan (m²), dan Koordinat GPS.

BATCH-02 (Detail Batch): Menampilkan riwayat aktivitas budidaya, perangkat sensor terhubung, estimasi tanggal panen, dan jejak transaksi blockchain.

4.5 Pelacakan Rantai Pasok (Supply Chain Tracking)

SCM-01 (Tahapan Status Distribusi): Pelacakan alur produk secara linier melalui status:

Penanaman $\rightarrow$ 2. Pemeliharaan $\rightarrow$ 3. Panen $\rightarrow$ 4. Gudang $\rightarrow$ 5. Distribusi $\rightarrow$ 6. Diterima Pembeli.

SCM-02 (Bukti Transaksi): Setiap pembaruan status wajib merekam koordinat GPS, foto bukti transaksi, dan stempel waktu (timestamp).

4.6 Engine Verifikasi Kode QR

QR-01 (Format QR Otomatis): Generasi otomatis identifier QR unik per batch, contoh format: BATCH-KTG-2026-001.

QR-02 (Verifikasi Pemindaian): Pemindaian QR oleh konsumen akan membuka halaman publik berisi: profil petani, lokasi asal lahan, riwayat suhu pengiriman, dan validasi validitas rantai pasok.

4.7 Integrasi Blockchain Ledger

BC-01 (Pencatatan Imutabel): Transaksi yang dicatat tanpa bisa diubah (immutable) meliputi: pendaftaran batch, aktivitas panen, perubahan penguasaan barang, dan verifikasi akhir.

BC-02 (Skema Payload Blockchain):

{
  "batchId": "KTG001",
  "actorId": "USR-FARMER-042",
  "event": "PANEN",
  "location": { "lat": -6.91749, "long": 107.6191 },
  "metadata": { "yieldWeightKg": 1250, "qualityGrade": "A" },
  "timestamp": "2026-08-20T08:30:00Z",
  "txHash": "0x8f2a...c4e1"
}



4.8 Fitur AI Agent

AI-01 (Asisten Chat Kontekstual): AI interaktif yang menjawab pertanyaan petani dengan menyuntikkan data sensor aktual dan riwayat batch sebagai konteks utama (Retrieval-Augmented Generation).

AI-02 (Analisis & Prediksi Hasil): Evaluasi otomatis untuk memprediksi estimasi tanggal panen dan tingkat risiko potensi gagal panen.

AI-03 (Diagnosis Penyakit Tanaman): Pemrosesan citra foto daun/tanaman menggunakan model computer vision untuk mengidentifikasi jenis penyakit, tingkat risiko (%), serta rekomendasi penangannya.

AI-04 (Penceritaan Traceability Produk): Merangkum data transaksi mentah blockchain menjadi narasi ringkas tentang perjalanan produk dari lahan hingga tangan konsumen.

5. Persyaratan Non-Fungsional (Non-Functional Requirements)

| Parameter | Spesifikasi Teknis |
| Keamanan (Security) | Autentikasi berbasis JWT dengan sliding expiration. Transmisi data terenkripsi HTTPS/TLS 1.3 dan MQTTS (Port 8883). Penerapan Role-Based Access Control (RBAC) pada API Gateway. |
| Performa (Performance) | Latensi respon REST API < 800ms (P95). Waktu pemrosesan diagnosis AI < 3.5 detik. Delay pembaruan data sensor real-time via WebSocket/MQTT < 500ms. |
| Ketersediaan (Availability) | Target SLA ketersediaan backend sebesar 99.5% uptime. |
| Skalabilitas (Scalability) | Mampu menangani hingga 10.000+ Batch Aktif dan throughput ingestion 100.000+ Log IoT per hari tanpa degradasi performa sistem. |

6. Arsitektur Sistem & Alur Data

6.1 Diagram Arsitektur Data & Blockchain

                         ┌───────────────────────────┐
                         │   Flutter Mobile App      │
                         └─────────────┬─────────────┘
                                       │ HTTPS / WSS
                                       ▼
                         ┌───────────────────────────┐
                         │    Node.js (Express)      │
                         │       API Gateway         │
                         └──────┬──────┬──────┬──────┘
                                │      │      │
          ┌─────────────────────┘      │      └─────────────────────┐
          │ MQTTS                      │ SQL                        │ gRPC (Fabric SDK)
          ▼                            ▼                            ▼
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  Broker MQTT     │         │ PostgreSQL Main  │         │   Hyperledger    │
│ (EMQX/Mosquitto) │         │    Database      │         │   Fabric Peer    │
└─────────┬────────┘         └──────────────────┘         └──────────────────┘
          ▲
          │ Stream Data
┌─────────┴────────┐
│ Perangkat IoT    │
└──────────────────┘



6.2 Diagram Pipeline Engine AI

┌──────────────────┐
│ Input Pengguna   │
│ (Teks / Foto)    │
└─────────┬────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────┐
│ API Gateway Backend                                      │
│ ├── Ambil Konteks: Data Telemetri Sensor (PostgreSQL)    │
│ └── Ambil Konteks: Jejak Rantai Pasok (Hyperledger)      │
└─────────┬────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────┐
│ Prompt Synthesizer                                       │
│ (Gabungkan System Prompt + Data Konteks + Query User)    │
└─────────┬────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────┐
│ Pipeline API Gemini / OpenAI                             │
└─────────┬────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────┐
│ Respons Terstruktur│
│ (Tampil di App)  │
└──────────────────┘



7. Matriks Spesifikasi API Endpoint
Ambil dari data backend dan frontend yang sudah ada 

8. Navigasi & Struktur UX Aplikasi Mobile

Aplikasi Flutter Mobile menggunakan skema Bottom Navigation Bar 5-Tab:

┌─────────────────────────────────────────────────────────────────────────┐
│                           ELECTRATECH MOBILE                            │
├──────────┬──────────────┬────────────────┬─────────────────┬────────────┤
│   HOME   │  SMART FARM  │    TRACKING    │    AI AGENT     │  PROFILE   │
├──────────┼──────────────┼────────────────┼─────────────────┼────────────┤
│ Dashboard│ Telemetri    │ Daftar Batch   │ Chat Assistant  │ Info Akun  │
│ AI Cards │ Sensor       │ Status Supply  │ Scan Penyakit   │ Pengaturan │
│ Ringkasan│ Grafik Trend │ Generasi QR    │ Rekomendasi Tani│ Keamanan   │
└──────────┴──────────────┴────────────────┴─────────────────┴────────────┘



9. Panduan Arsitektur & Desain Flutter

9.1 Struktur Folder (Clean Architecture Pattern)

lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/       # Konstanta warna, string, dan aset aplikasi
│   ├── network/         # DIO HTTP Client & API Interceptors
│   ├── services/        # Layanan MQTT, Push Notif, & Storage
│   ├── theme/           # Palet warna & Tipografi
│   └── utils/           # Format tanggal, validator, & helper functions
├── data/
│   ├── datasources/     # Remote & Local Data Sources
│   ├── models/          # Model Serialisasi Data JSON
│   └── repositories/    # Implementasi Repositori Data
├── features/
│   ├── ai_agent/        # Fitur Chat, Diagnosis Foto, & Insight AI
│   ├── auth/            # Halaman & Logika Masuk / Daftar Akun
│   ├── dashboard/       # Tampilan Dashboard Utama
│   ├── iot/             # Tampilan Telemetri Sensor & Grafik
│   ├── profile/         # Pengaturan Profil Akun & Keamanan
│   ├── supply_chain/    # Pelacakan Distribusi & Integrasi Peta
│   └── verification/    # Pemindai Kode QR & Detail Produk Publik
├── routes/              # Konfigurasi Rute (GoRouter / AutoRoute)
└── shared/
    ├── components/      # Komponen UI Reusable (Tombol, Input Field, Card)
    └── widgets/         # Widget Kustom (Loading, Error State, Shimmer)



9.2 Spesifikasi Tema Visual (UI Theme)

Primary Color: #22C55E (Agri Emerald Green — melambangkan kesuburan pertanian)
Secondary Color: #4F46E5 (Tech Indigo — melambangkan kecerdasan AI & Blockchain)
Background Light: #FFFFFF / #F8FAFC
Background Dark: #0B132B
Neutral Surface: #F1F5F9
Alert Status: #EF4444 (Indikator batas kritis sensor)
Font family: Inter, poppins
Ketebalan : Bold untuk Judul, Medium untuk Subjudul, Regular untuk Isi, Light untuk Keterangan


10. Roadmap Pengembangan Sistem

                    ELECTRATECH DEVELOPMENT ROADMAP
                     
  Fase 1: MVP Core (Fondasi Utama)
  ├─ Sistem Autentikasi & Peran Pengguna
  ├─ Dashboard Telemetri Sensor Real-Time (IoT)
  ├─ Sistem Manajemen Batch Tanam
  └─ Penerbitan Kode QR & Tracking Sederhana
  
  Fase 2: Kapabilitas AI Agent
  ├─ Integrasi Engine RAG (Konteks Database + IoT + AI)
  ├─ Chatbot Asisten Pertanian Interaktif
  └─ Engine Insight & Rekomendasi Otomatis
  
  Fase 3: Ekosistem Blockchain
  ├─ Integrasi Jaringan Hyperledger Fabric
  ├─ Pencatatan Transaksi Rantai Pasok Imutabel
  └─ Explorer Verifikasi Publik Berbasis Blockchain
  
  Fase 4: Analitis Tingkat Lanjut & Decision Support System
  ├─ Model AI Computer Vision Diagnosa Penyakit Tanaman
  ├─ Model Prediksi Hasil Panen Berbasis Deret Waktu
  └─ Smart Agriculture Decision Support System (DSS) Terpadu



Jadwal Rincian Deliverables

| Fase | Fokus Pengembangan | Key Deliverables |
| Fase 1 | Core Foundation & MVP | Autentikasi JWT, Koneksi MQTT Broker, Telemetri IoT, Manajemen Batch, & Verifikasi QR dasar. |
| Fase 2 | Integrasi Sistem AI | AI Chatbot Kontekstual, Pemasangan Data Telemetri ke LLM, & Sistem Rekomendasi Otomatis. |
| Fase 3 | Infrastruktur Blockchain | Setup Peer Hyperledger Fabric, Smart Contract (Chaincode) SCM, & Public Ledger Explorer. |
| Fase 4 | Advanced Intelligence | Computer Vision Penyakit Tanaman, Algoritma Prediksi Panen, & Decision Support System (DSS). |