# SINTESA Virtual Lab (Mobile) - Mekanisme Aplikasi & Game

Dokumentasi ini berfokus pada penjelasan fitur utama, teknologi yang digunakan, serta struktur kode dan mekanisme game pada aplikasi mobile SINTESA Virtual Lab yang dikembangkan dengan Flutter.

---

## 1. Daftar Fitur Lengkap (Complete Features)

Aplikasi ini tidak hanya menyajikan simulasi visual, melainkan fungsionalitas yang mendekati proses laboratorium nyata:

1. **Simulasi Berisiko Tinggi (2-Minute Pressure):** Pengguna tidak bisa melakukan *pause* saat bereksperimen. Hal ini melatih kecepatan, akurasi, dan kedisiplinan di lab fisik.
2. **Mekanik Interaktif (Drag & Drop):** Peralatan lab virtual seperti gelas beker, larutan ekstrak, dan sendok pengaduk dikontrol penuh secara mandiri lewat sentuhan.
3. **Smart Lab-Notebook Terintegrasi:** Tidak perlu keluar simulasi untuk mencatat. Buku catatan terintegrasi dapat digeser (slide) kapan pun dan otomatis memvalidasi apakah pengamatan visual praktikan itu benar atau salah.
4. **Sistem Penilaian Cerdas Berbobot:** Mesin evaluasi mencatat setiap gerak-gerik:
   - Presisi Pelaksanaan & Keamanan (Safety).
   - Akurasi Laporan Akhir.
   - Poin Penyelesaian (Completion Point).
5. **Achievement & Mastery System:** Semakin tepat perhitungan pH (misalnya mampu menganalisis reaksi di atas pH 11), praktikan akan memperoleh lencana khusus (Badge) serta gelar kepangkatan (*Chief Researcher*, dll.).
6. **Pembuatan Laporan (PDF Generation):** Sistem secara otomatis merangkum semua data eksperimen, observasi, dan hasil skor ke dalam format laporan PDF profesional yang bisa langsung dicetak atau diunduh.
7. **Cloud Sync & Autentikasi:** Didukung Firebase, progres praktikum tersimpan secara presisten antar-perangkat.

---

## 2. Tech Stack & Dependencies

SINTESA Virtual Lab dikembangkan di atas tumpukan teknologi modern yang dirancang untuk platform *mobile* (Android/iOS):

### **Core Stack**
- **Framework:** Flutter (Dart)
- **State Management:** Native `ChangeNotifier` / Reactive UI
- **Backend Service:** Google Firebase

### **Dependencies Utama (`pubspec.yaml`)**
- `firebase_core` (^3.13.0): Penghubung inti aplikasi ke layanan Firebase.
- `firebase_auth` (^5.5.4): Mengelola sistem login, registrasi, dan sesi autentikasi pengguna secara aman.
- `cloud_firestore` (^5.6.6): Database NoSQL untuk menyimpan progres poin, badge, dan catatan praktikan secara *real-time*.
- `pdf` (^3.10.7): *Engine* untuk membentuk struktur laporan laboratorium dalam format ekstensi `.pdf`.
- `printing` (^5.11.1): Mendukung fungsi pratinjau (*preview*) PDF di layar *smartphone* serta mencetak langsung (via sistem *print* bawaan perangkat).
- `http` (^1.2.0): Untuk kebutuhan *request* ke eksternal API jika diperlukan di masa mendatang.

---

## 3. Mekanisme Aplikasi (Application Code Mechanism)

Aplikasi SINTESA Virtual Lab dibangun menggunakan arsitektur modular yang rapi, memastikan skalabilitas dan kemudahan pemeliharaan. Berikut adalah mekanisme utama dari sisi kode:

### a. Arsitektur & Struktur Folder
Proyek ini mengadopsi pemisahan tanggung jawab (separation of concerns):
- **`lib/screens/`**: Berisi antarmuka pengguna (UI) dan logika navigasi tiap halaman (contoh: `dashboard_screen.dart`, `game_screen.dart`).
- **`lib/models/`**: Tempat definisi struktur data inti dan *State Management* (contoh: `game_state.dart`, `solution.dart`).
- **`lib/widgets/`**: Komponen UI independen yang dapat digunakan kembali secara modular (contoh: `LabNotebook`, `FlaskWidget`, `InventoryWidget`).
- **`lib/services/`**: Menangani logika pihak ketiga seperti pembuatan laporan PDF, database, atau layanan eksternal.

```text
lib/
 ├── models/      # Data models & GameState
 ├── screens/     # UI Pages (game_screen, dashboard_screen)
 ├── widgets/     # Reusable UI (LabNotebook, FlaskWidget)
 └── services/    # Firebase & Report generator
```

### b. State Management (Pengelolaan State)
Aplikasi ini sangat bergantung pada pola `ChangeNotifier` bawaan Flutter.
- Inti dari berjalannya permainan dikendalikan oleh class **`GameState`** (`lib/models/game_state.dart`).
- UI (`GameScreen`) akan bereaksi secara reaktif (reactive) menggunakan `AnimatedBuilder` terhadap setiap perubahan *state* (seperti perubahan skor, perpindahan fase permainan, atau perubahan warna beker glass) tanpa perlu melakukan *re-render* pada keseluruhan aplikasi.

```dart
// Contoh dari lib/models/game_state.dart
class GameState extends ChangeNotifier {
  int _score = 0;
  int get score => _score;

  void goToPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners(); // Memicu update pada UI secara reaktif
  }
}
```

### c. Autentikasi & Alur Masuk (Routing)
- Terintegrasi dengan **Firebase** sebagai *backend* utama.
- Pada `main.dart`, terdapat `AuthWrapper` yang memantau aliran *state* autentikasi pengguna secara *real-time* via Firebase.
- Jika pengguna belum login (sesi kosong), aplikasi diarahkan ke layar pengenalan (`StartScreen`). Jika sesi sudah aktif, sistem memotong (bypass) halaman login dan langsung memuat `DashboardScreen`.

```dart
// Contoh dari lib/main.dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return const DashboardScreen();
    }
    return const StartScreen();
  },
);
```

---

## 4. Mekanisme Game (Game Mechanism)

Mekanisme game pada modul "Praktikum Indikator Asam-Basa" dirancang untuk mensimulasikan eksperimen nyata dengan penambahan elemen tekanan (*pressure*) dan ketelitian.

### a. Sistem Waktu Terbatas (2-Minute Pressure)
- Terdapat fungsi *timer* berjalan (non-jeda) selama **2 Menit (120 detik)** di dalam `game_screen.dart`.
- Begitu *button* mulai simulasi ditekan, *countdown* berjalan. Jika waktu habis (`_secondsRemaining <= 0`) sebelum eksperimen selesai diobservasi, sesi permainan otomatis dihentikan dan pemain dipaksa (*force redirect*) menuju layar *Lab Report* dengan risiko kehilangan poin maksimal karena batas waktu.

```dart
// Contoh dari lib/screens/game_screen.dart
void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsRemaining > 0) {
      setState(() => _secondsRemaining--);
    } else {
      _timer?.cancel();
      _onTimeUp(); // Auto-redirect dan submit dengan poin 0
    }
  });
}
```

### b. Interaksi Drag & Drop (Tuang & Aduk)
Permainan mengandalkan komponen interaktif `DragTarget` dan `Draggable`:
- **Menuangkan Ekstrak (Pouring):** Pemain harus membuka *Inventory* (panel geser) dan melakukan aksi *drag & drop* item "Larutan Kunyit" ke atas objek beker glass yang kosong. Jika valid, sistem memanggil fungsi `addKunyitToSolution()` dan memberikan poin *completion*.
- **Mengaduk (Stirring):** Gelas yang sudah dituang tidak akan langsung berubah warna. Pemain harus menyeret item "Sendok Preparat" ke gelas tersebut untuk memicu fungsi `stirSolution()`.
- Setiap interaksi berhasil memicu animasi khusus (gelas berputar/bergetar karena `AnimationController`) dan menampilkan pemberitahuan *feedback toast* sukses.

```dart
// Contoh penggunaan DragTarget di lib/screens/game_screen.dart
DragTarget<String>(
  onWillAcceptWithDetails: (details) =>
      (details.data == 'kunyit' && s.state == SolutionState.empty) ||
      (details.data == 'sendok' && s.state == SolutionState.kunyitAdded),
  onAcceptWithDetails: (details) {
    if (details.data == 'kunyit') {
      widget.gameState.addKunyitToSolution(s.id);
    } else if (details.data == 'sendok') {
      _onStirFlask(s.id);
    }
  },
  builder: (context, candidates, _) {
    return FlaskWidget(solution: s);
  },
)
```

### c. Smart Lab-Notebook (Catatan Observasi)
- Pemain difasilitasi dengan buku catatan digital terintegrasi (*Notebook Sidebar*).
- Pemain diminta melakukan observasi visual pada warna gelas yang telah diaduk, menyimpulkan sifat larutan (Asam/Basa), dan menulis reaksi kimianya.
- Observasi ini bukan hanya catatan pasif. Input divalidasi langsung oleh sistem:
  - Analisis yang **benar** akan dieksekusi oleh fungsi `updateNotebook()` yang berujung pada penambahan poin observasi bonus (`_notebookScore += 10`).
  - Analisis yang **salah** akan langsung memotong nilai presisi pemain (`_precisionScore`).

```dart
// Contoh dari lib/models/game_state.dart
void updateNotebook(String solutionId, {String? type, String? note}) {
  // Validasi sifat larutan
  if (type == solution.acidBaseLabel) {
    _notebookScore += 10;
  } else {
    // Penalti jika tebakan sifat larutan salah
    _precisionScore = (_precisionScore - 5).clamp(0, 100);
  }
  notifyListeners();
}
```

### d. Sistem Penilaian Multi-Faktor & Badge Pencapaian
Skor akhir bukan angka tunggal, melainkan gabungan komprehensif dari variabel di dalam `GameState`:
1. **Completion Point:** Didapat secara inkremental setiap kali berhasil menuang (+5 pts) dan mengaduk (+15 pts) per gelas.
   ```dart
   // Contoh pemberian poin di lib/models/game_state.dart
   _completionScore += 5; // Poin tuang kunyit
   _score += 5;
   ```
2. **Notebook Point:** Akurasi laporan di dalam Smart Lab-Notebook.
3. **Precision Score & Safety Score:** Dimulai dari basis 100%. *Safety Score* akan dipotong jika pemain melakukan interaksi membahayakan/keliru (misal: menuangkan bahan yang salah).
   ```dart
   // Contoh penalti safety di lib/models/game_state.dart
   void penalizeSafety(int penalty) {
     _safetyScore = (_safetyScore - penalty).clamp(0, 100);
     // Jika terlalu sering salah, skor utama juga dikurangi
     if (_safetyScore < 70) _score = (_score - 5).clamp(0, 9999);
     notifyListeners();
   }
   ```
4. **Mastery Level:** Di akhir sesi, pemain akan diberikan *title* gelar berdasarkan rentang skor kumulatif (misal: *Trainee*, *Lab Assistant*, *Senior Researcher*, *Chief Researcher*).
   ```dart
   // Penentuan gelar berdasarkan total skor di lib/models/game_state.dart
   String get masteryLevel {
     if (_score > 200) return 'Chief Researcher';
     if (_score > 100) return 'Senior Researcher';
     if (_score > 50) return 'Lab Assistant';
     return 'Trainee';
   }
   ```
5. **Achievement Badges (Pencapaian):** Mekanisme tersembunyi yang akan mencatat prestasi khusus. Misalnya, pemain yang berhasil menyelesaikan perhitungan reaksi basa kuat (pH > 11) akan dianugerahi badge khusus *"Strong Base Expert"*.

```dart
// Contoh pemberian badge di lib/models/game_state.dart
if (_solutions[idx].ph > 11.0) {
  _addBadge('Strong Base Expert');
}
if (allGlassesDone) {
  _addBadge('Diligent Chemist');
}
```
