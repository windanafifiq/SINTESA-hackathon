class LabReportModel {
  String asam;
  String basa;
  String netral;
  String kesimpulan;
  String? generatedReport;
  String? videoUrl;
  bool isBadgeEarned;

  LabReportModel({
    this.asam = '',
    this.basa = '',
    this.netral = '',
    this.kesimpulan = '',
    this.generatedReport,
    this.videoUrl,
    this.isBadgeEarned = false,
  });

  LabReportModel copyWith({
    String? asam,
    String? basa,
    String? netral,
    String? kesimpulan,
    String? generatedReport,
    String? videoUrl,
    bool? isBadgeEarned,
  }) {
    return LabReportModel(
      asam: asam ?? this.asam,
      basa: basa ?? this.basa,
      netral: netral ?? this.netral,
      kesimpulan: kesimpulan ?? this.kesimpulan,
      generatedReport: generatedReport ?? this.generatedReport,
      videoUrl: videoUrl ?? this.videoUrl,
      isBadgeEarned: isBadgeEarned ?? this.isBadgeEarned,
    );
  }

  Map<String, dynamic> toJson() => {
        'asam': asam,
        'basa': basa,
        'netral': netral,
        'kesimpulan': kesimpulan,
        'generatedReport': generatedReport,
        'videoUrl': videoUrl,
        'isBadgeEarned': isBadgeEarned,
      };
}