# 🧪 SINTESA Virtual Lab

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com)

**SINTESA Virtual Lab** adalah platform simulasi laboratorium canggih dan imersif yang dirancang untuk menjembatani kesenjangan antara teori sains dan aplikasi praktis. Dibangun menggunakan Flutter, platform ini menyediakan lingkungan berkualitas tinggi bagi siswa dan peneliti untuk melakukan eksperimen secara aman dan efisien.

---

## ✨ Fitur Utama

### ⏱️ Simulasi Berisiko Tinggi (Disiplin 2 Menit)
Rasakan tekanan laboratorium dunia nyata dengan fitur unik kami: **simulasi 2 menit tanpa jeda (non-pause)**. Fitur ini melatih disiplin dan akurasi, memastikan pengguna siap menghadapi tuntutan waktu di laboratorium fisik.

### 📝 Catatan Terintegrasi "Sneak Peek"
Jangan pernah kehilangan arah saat melakukan eksperimen. Buku catatan digital terintegrasi memungkinkan pengguna mencatat observasi dan melihat protokol eksperimen secara instan tanpa mengganggu alur simulasi.

### 📊 Sistem Penilaian Canggih
Mesin evaluasi cerdas kami menggunakan **logika penilaian berbobot 50/30/20**:
- **50%**: Presisi dalam pelaksanaan eksperimen.
- **30%**: Akurasi dan kelengkapan laporan akhir.
- **20%**: Pengetahuan teoritis dan pemahaman konsep.

### 📄 Pelaporan PDF Otomatis
Hasilkan laporan laboratorium profesional secara instan. Sistem secara otomatis merangkum data eksperimen, observasi, dan hasil ke dalam format PDF yang dapat diunduh.

### ☁️ Sinkronisasi Real-time
Didukung oleh **Google Firebase**, semua progres modul, skor, dan data pengguna disinkronkan di seluruh perangkat secara real-time.

---

## 🚀 Tumpukan Teknologi (Technical Stack)

- **Frontend**: Flutter (Dukungan lintas platform)
- **Backend**: Firebase Firestore & Authentication
- **Manajemen State**: Provider / Bloc (Optimasi reaktivitas)
- **Desain**: UI/UX Premium dengan mikro-animasi halus dan tata letak responsif.

---

## 🛠️ Memulai

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Akun Firebase](https://console.firebase.google.com/)

### Instalasi

1.  **Clone repository:**
    ```bash
    git clone https://github.com/windanafifiq/SINTESA-hackathon.git
    ```

2.  **Masuk ke direktori proyek:**
    ```bash
    cd sintesa_virtual_lab
    ```

3.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```

4.  **Konfigurasi Firebase:**
    *   Letakkan file `firebase_options.dart` Anda di direktori `lib/`.
    *   *(Catatan: File ini diabaikan oleh Git untuk alasan keamanan)*

5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## 📐 Arsitektur

Proyek ini mengikuti arsitektur modular untuk skalabilitas:
- `lib/screens`: Lapisan UI dan Navigasi.
- `lib/widgets`: Komponen UI yang dapat digunakan kembali.
- `lib/services`: Logika Firebase dan pembuatan PDF.
- `lib/models`: Struktur data dan logika bisnis.
- `lib/theme`: Sistem desain terpusat.

---

## 🤝 Kontribusi

Proyek ini dikembangkan untuk **SINTESA Hackathon**. Kontribusi sangat kami hargai!

1. Fork Proyek ini
2. Buat Feature Branch Anda (`git checkout -b feature/FiturLuarBiasa`)
3. Commit Perubahan Anda (`git commit -m 'Tambah FiturLuarBiasa'`)
4. Push ke Branch tersebut (`git push origin feature/FiturLuarBiasa`)
5. Buka Pull Request

---

© 2026 Tim SINTESA Virtual Lab.
