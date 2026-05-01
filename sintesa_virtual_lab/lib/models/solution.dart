import 'package:flutter/material.dart';
// ── Solution state enum ──────────────────────────────────────────────────────

enum SolutionState {
  empty,      // belum ada apa-apa
  kunyitAdded, // kunyit sudah dituang, belum diaduk
  stirring,   // sedang diaduk (animasi)
  revealed,   // warna sudah berubah (diaduk selesai)
}

// ── Solution model ───────────────────────────────────────────────────────────

class Solution {
  final String id;
  final String name;
  final double ph;
  final SolutionState state;

  // Observation notebook fields
  final String? observationColor;
  final String? observationType;
  final String? observationNote;

  const Solution({
    required this.id,
    required this.name,
    required this.ph,
    this.state = SolutionState.empty,
    this.observationColor,
    this.observationType,
    this.observationNote,
  });

  /// True only when fully stirred and color is revealed
  bool get hasKunyit => state == SolutionState.revealed || state == SolutionState.stirring;
  bool get isRevealed => state == SolutionState.revealed;
  bool get needsStirring => state == SolutionState.kunyitAdded;

  /// Warna larutan berdasarkan pH setelah kunyit ditambahkan dan diaduk:
  /// - Asam (pH < 7): kuning / oranye (warna asli kunyit)
  /// - Netral (pH ≈ 7): kuning kecokelatan
  /// - Basa (pH > 7): merah kecokelatan / cokelat
  /// - Basa kuat (pH > 11): merah tua
  String get reactionColorName {
    if (ph < 4) return 'Kuning Cerah';
    if (ph < 7) return 'Kuning';
    if (ph < 8) return 'Kuning Kecokelatan';
    if (ph < 11) return 'Merah Kecokelatan';
    return 'Merah Tua';
  }

  /// Warna Flutter untuk visual flask
  Color get flaskColor {
    if (state != SolutionState.revealed) {
      // Sebelum diaduk: tampilkan warna bening / larutan asli
      return state == SolutionState.kunyitAdded
          ? const Color(0xFFE8C94B).withOpacity(0.4) // kunyit belum bereaksi
          : const Color(0xFFB3D9FF).withOpacity(0.5); // bening
    }
    // Setelah diaduk: warna reaksi
    if (ph < 4) return const Color(0xFFFFF176);
    if (ph < 7) return const Color(0xFFFFD54F);
    if (ph < 8) return const Color(0xFFFFB300);
    if (ph < 11) return const Color(0xFFBF360C);
    return const Color(0xFF7B1111);
  }

  String get acidBaseLabel {
    if (ph < 7) return 'Asam';
    if (ph == 7) return 'Netral';
    return 'Basa';
  }

  Solution copyWith({
    SolutionState? state,
    String? observationColor,
    String? observationType,
    String? observationNote,
  }) {
    return Solution(
      id: id,
      name: name,
      ph: ph,
      state: state ?? this.state,
      observationColor: observationColor ?? this.observationColor,
      observationType: observationType ?? this.observationType,
      observationNote: observationNote ?? this.observationNote,
    );
  }
}

// ── Static data ───────────────────────────────────────────────────────────────

// ignore: avoid_classes_with_only_static_members
class SolutionData {
  static List<Solution> getAllSolutions() => const [
        Solution(id: 'obat_maag',   name: 'Obat Maag',        ph: 8.0),
        Solution(id: 'selokan',   name: 'Selokan',        ph: 8.0),
        Solution(id: 'air_kapur',   name: 'Air Kapur',        ph: 12.0),
        Solution(id: 'cuka',  name: 'Cuka',        ph: 3.0),
        Solution(id: 'aqua',  name: 'Air Murni',   ph: 7.0),
        Solution(id: 'sabun', name: 'Air Sabun',   ph: 9.5),
        Solution(id: 'naoh',  name: 'NaOH',        ph: 13.0),
      ];
}

