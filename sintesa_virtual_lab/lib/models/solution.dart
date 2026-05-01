import 'package:flutter/material.dart';

enum SolutionType { asam, basa, netral }

class Solution {
  final String id;
  final String name;
  final String description;
  final Color beforeColor; 
  final Color afterColor; 
  final SolutionType type;
  final String imageBefore; 
  final String imageAfter; 
  final String explanation;
  final double ph;
  final double concentration; // in Molarity
  final double volume; // in ml
  bool hasKunyit;
  bool isSelected;
  
  // Notebook entries
  String? observationColor;
  String? observationType; // asam/basa/netral
  String? observationNote;

  Solution({
    required this.id,
    required this.name,
    required this.description,
    required this.beforeColor,
    required this.afterColor,
    required this.type,
    required this.imageBefore,
    required this.imageAfter,
    required this.explanation,
    this.ph = 7.0,
    this.concentration = 0.1,
    this.volume = 50.0,
    this.hasKunyit = false,
    this.isSelected = false,
  });

  String get assetBefore => 'assets/images/$imageBefore.png';
  String get assetAfter => 'assets/images/$imageAfter.png';

  // Returns label for type
  String get typeLabel {
    switch (type) {
      case SolutionType.asam:
        return 'ASAM';
      case SolutionType.basa:
        return 'BASA';
      case SolutionType.netral:
        return 'NETRAL';
    }
  }

  Color get typeColor {
    switch (type) {
      case SolutionType.asam:
        return const Color(0xFFDB0000);
      case SolutionType.basa:
        return const Color(0xFF4E91FF);
      case SolutionType.netral:
        return const Color(0xFFA7FF6D);
    }
  }

  // The current liquid color shown in the glass (deprecated, using assets now)
  Color get currentLiquidColor => hasKunyit ? afterColor : beforeColor;

  Solution copyWith({
    bool? hasKunyit, 
    bool? isSelected,
    String? observationColor,
    String? observationType,
    String? observationNote,
  }) {
    final s = Solution(
      id: id,
      name: name,
      description: description,
      beforeColor: beforeColor,
      afterColor: afterColor,
      type: type,
      imageBefore: imageBefore,
      imageAfter: imageAfter,
      explanation: explanation,
      ph: ph,
      concentration: concentration,
      volume: volume,
      hasKunyit: hasKunyit ?? this.hasKunyit,
      isSelected: isSelected ?? this.isSelected,
    );
    s.observationColor = observationColor ?? this.observationColor;
    s.observationType = observationType ?? this.observationType;
    s.observationNote = observationNote ?? this.observationNote;
    return s;
  }
}


class SolutionData {
  static List<Solution> getAllSolutions() {
    return [
      Solution(
        id: 'air',
        name: 'Air',
        description: 'Air murni (H₂O)',
        beforeColor: const Color(0xFFB8D4E8).withOpacity(0.7),
        afterColor: const Color(0xFFE8C85A),
        type: SolutionType.netral,
        imageBefore: 'air_before',
        imageAfter: 'air_after',
        explanation: 'Air bersifat NETRAL (pH 7). Ekstrak kunyit tetap berwarna kuning cerah.',
        ph: 7.0,
      ),
      Solution(
        id: 'selokan',
        name: 'Air Selokan',
        description: 'Air selokan yang sudah disaring',
        beforeColor: const Color(0xFFA8C4A8).withOpacity(0.6),
        afterColor: const Color(0xFFB8860B).withOpacity(0.8),
        type: SolutionType.netral,
        imageBefore: 'selokan_before',
        imageAfter: 'selokan_after',
        explanation: 'Air selokan cenderung NETRAL hingga sedikit basa. Kunyit berubah menjadi kuning kehijauan.',
        ph: 7.2,
      ),
      Solution(
        id: 'garam',
        name: 'Air Garam',
        description: 'Larutan NaCl dalam air',
        beforeColor: const Color(0xFFD0E8F0).withOpacity(0.6),
        afterColor: const Color(0xFFDAA520).withOpacity(0.9),
        type: SolutionType.netral,
        imageBefore: 'garam_before',
        imageAfter: 'garam_after',
        explanation: 'Air garam bersifat NETRAL. Kunyit tetap berwarna kuning keemasan.',
        ph: 7.0,
      ),
      Solution(
        id: 'obat_maag',
        name: 'Obat Maag',
        description: 'Larutan antasida (basa)',
        beforeColor: const Color(0xFFE0E8F8).withOpacity(0.7),
        afterColor: const Color(0xFFFF4500).withOpacity(0.85),
        type: SolutionType.basa,
        imageBefore: 'obat_maag_before',
        imageAfter: 'obat_maag_after',
        explanation: 'Obat maag bersifat BASA (mengandung Mg(OH)₂ / Al(OH)₃). Kunyit berubah menjadi merah-oranye!',
        ph: 10.5,
      ),
      Solution(
        id: 'sabun',
        name: 'Air Sabun',
        description: 'Larutan sabun dalam air',
        beforeColor: const Color(0xFFE8F4F8).withOpacity(0.6),
        afterColor: const Color(0xFFDC143C).withOpacity(0.8),
        type: SolutionType.basa,
        imageBefore: 'air_sabun_before',
        imageAfter: 'air_sabun_after',
        explanation: 'Air sabun bersifat BASA. Kunyit berubah menjadi merah cerah!',
        ph: 9.0,
      ),
      Solution(
        id: 'cuka',
        name: 'Larutan Cuka',
        description: 'Asam asetat (CH₃COOH)',
        beforeColor: const Color(0xFFF0F8D0).withOpacity(0.6),
        afterColor: const Color(0xFFFFF176).withOpacity(0.9),
        type: SolutionType.asam,
        imageBefore: 'larutan_cuka_before',
        imageAfter: 'larutan_cuka_after',
        explanation: 'Cuka bersifat ASAM. Kunyit tetap berwarna kuning cerah.',
        ph: 2.4,
      ),
      Solution(
        id: 'kapur',
        name: 'Air Kapur',
        description: 'Larutan Ca(OH)₂',
        beforeColor: const Color(0xFFF5F5F5).withOpacity(0.5),
        afterColor: const Color(0xFFFF6347).withOpacity(0.9),
        type: SolutionType.basa,
        imageBefore: 'air_kapur_before',
        imageAfter: 'air_kapur_after',
        explanation: 'Air kapur bersifat BASA KUAT. Kunyit berubah menjadi merah-oranye terang!',
        ph: 12.0,
      ),
    ];
  }
}

