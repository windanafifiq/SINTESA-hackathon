import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lab_report_model.dart';

class LabReportGeneratorService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  // NOTE: In production, DO NOT hardcode API keys.
  // Use flutter_dotenv or a backend proxy for security.
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const String _model = 'claude-sonnet-4-20250514';

  /// Generates a structured lab report in Bahasa Indonesia
  /// based on the student's input data.
  static Future<String> generateReport(LabReportModel report) async {
    final prompt = '''
Kamu adalah asisten guru kimia. Buatkan laporan hasil praktikum kimia yang formal dan terstruktur dalam Bahasa Indonesia berdasarkan data berikut:

**Kelompok Larutan Asam:** ${report.asam}
**Kelompok Larutan Basa:** ${report.basa}
**Kelompok Larutan Netral:** ${report.netral}
**Kesimpulan Siswa:** ${report.kesimpulan}

Praktikum ini tentang: ${AppStrings.practikumTitle} - ${AppStrings.practikumSubtitle}

Buat laporan yang mencakup:
1. Tujuan Percobaan
2. Dasar Teori (singkat, 2-3 kalimat)
3. Hasil Pengamatan (elaborasi dari pengelompokan data siswa di atas)
4. Analisis dan Pembahasan (kaitkan dengan perubahan warna indikator kunyit)
5. Kesimpulan

Tulis dengan bahasa yang formal namun mudah dipahami siswa SMA. Maksimal 300 kata.
''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] as List<dynamic>;
        final textBlocks =
            content.where((b) => b['type'] == 'text').toList();
        if (textBlocks.isNotEmpty) {
          return textBlocks.first['text'] as String;
        }
        throw Exception('No text content in response');
      } else {
        final err = jsonDecode(response.body);
        throw Exception(
            'API Error ${response.statusCode}: ${err['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Return a fallback report if API fails
      return _fallbackReport(report);
    }
  }

  static String _fallbackReport(LabReportModel report) {
    return '''**LAPORAN HASIL PRAKTIKUM**

**1. Tujuan Percobaan**
Mengetahui sifat asam dan basa suatu larutan menggunakan indikator alami ekstrak kunyit.

**2. Dasar Teori**
Indikator alami seperti ekstrak kunyit mengandung senyawa kurkumin yang dapat berubah warna ketika bereaksi dengan larutan asam maupun basa. Larutan asam atau netral cenderung mempertahankan warna kuning kunyit, sedangkan larutan basa akan mengubahnya menjadi warna merah kecokelatan.

**3. Hasil Pengamatan**
Berdasarkan uji coba yang dilakukan, diperoleh hasil pengelompokan larutan sebagai berikut:
- **Larutan Asam:** ${report.asam}
- **Larutan Basa:** ${report.basa}
- **Larutan Netral:** ${report.netral}

**4. Analisis dan Pembahasan**
Berdasarkan pengamatan yang telah dilakukan, diperoleh hasil yang sesuai dengan teori asam-basa. Perubahan warna yang teramati menunjukkan reaksi kimia antara indikator kunyit dengan sifat pH masing-masing sampel larutan uji.

**5. Kesimpulan**
${report.kesimpulan}

Praktikum ini berhasil membuktikan bahwa ekstrak kunyit dapat digunakan sebagai indikator alami untuk membedakan larutan asam dan basa secara sederhana.''';
  }
}

// Helper for AppStrings (avoids circular import if needed)
class AppStrings {
  static const String practikumTitle = 'Praktikum Asam-Basa';
  static const String practikumSubtitle =
      'Pengenalan larutan asam dan basa menggunakan indikator alami (Ekstrak Kunyit)';
}