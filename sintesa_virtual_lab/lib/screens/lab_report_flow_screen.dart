import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_colors.dart';
import '../models/lab_report_model.dart';
import '../services/lab_report_generator_service.dart' hide AppStrings;
import '../widgets/lab_reports_widgets.dart';
import '../screens/intro_screen.dart';

// ═══════════════════════════════════════════════════════════════
// STEP ENUM
// ═══════════════════════════════════════════════════════════════

enum LabStep { form, video, completion, result }

// ═══════════════════════════════════════════════════════════════
// ROOT WIDGET
// ═══════════════════════════════════════════════════════════════

class LabReportFlowScreen extends StatefulWidget {
  const LabReportFlowScreen({super.key});

  @override
  State<LabReportFlowScreen> createState() => _LabReportFlowScreenState();
}

class _LabReportFlowScreenState extends State<LabReportFlowScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────
  LabStep _currentStep = LabStep.form;
  LabReportModel _report = LabReportModel();

  // ── Form controllers ───────────────────────────────────────
  final _asamCtrl = TextEditingController();
  final _basaCtrl = TextEditingController();
  final _netralCtrl = TextEditingController();
  final _kesimpulanCtrl = TextEditingController();
  bool _isSaving = false;

  // ── Video state ────────────────────────────────────────────
  bool _videoWatched = false;

  // ── Completion state ───────────────────────────────────────
  bool _isDropdownOpen = false;
  bool _isGenerating = false;
  String? _generatedReport;
  String? _errorMessage;
  late AnimationController _badgeAnimCtrl;
  late Animation<double> _badgeScaleAnim;

  // ── Page transition ────────────────────────────────────────
  late AnimationController _pageAnimCtrl;
  late Animation<double> _pageFadeAnim;

  @override
  void initState() {
    super.initState();

    _badgeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _badgeScaleAnim = CurvedAnimation(
      parent: _badgeAnimCtrl,
      curve: Curves.elasticOut,
    );

    _pageAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _pageFadeAnim = CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: Curves.easeOut,
    );

    // Rebuild on text change so button enables/disables reactively
    _asamCtrl.addListener(_rebuild);
    _basaCtrl.addListener(_rebuild);
    _netralCtrl.addListener(_rebuild);
    _kesimpulanCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _asamCtrl.dispose();
    _basaCtrl.dispose();
    _netralCtrl.dispose();
    _kesimpulanCtrl.dispose();
    _badgeAnimCtrl.dispose();
    _pageAnimCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ─────────────────────────────────────

  Future<void> _goTo(LabStep next) async {
    await _pageAnimCtrl.reverse();
    setState(() => _currentStep = next);

    // Trigger badge animation when entering completion or result
    if (next == LabStep.completion || next == LabStep.result) {
      _badgeAnimCtrl
        ..reset()
        ..forward();
    }
    _pageAnimCtrl.forward();
  }

  void _goBack() {
    switch (_currentStep) {
      case LabStep.video:
        _goTo(LabStep.form);
      case LabStep.completion:
        _goTo(LabStep.video);
      default:
        break;
    }
  }

  // ── Form logic ─────────────────────────────────────────────

  bool get _formIsValid =>
      _asamCtrl.text.trim().isNotEmpty &&
      _basaCtrl.text.trim().isNotEmpty &&
      _netralCtrl.text.trim().isNotEmpty &&
      _kesimpulanCtrl.text.trim().isNotEmpty;

  Future<void> _onSaveAndNext() async {
    if (!_formIsValid) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    _report = LabReportModel(
      asam: _asamCtrl.text.trim(),
      basa: _basaCtrl.text.trim(),
      netral: _netralCtrl.text.trim(),
      kesimpulan: _kesimpulanCtrl.text.trim(),
    );
    setState(() => _isSaving = false);
    _goTo(LabStep.video);
  }

  // ── Completion logic ───────────────────────────────────────

  Future<void> _onDropdownToggle() async {
    setState(() => _isDropdownOpen = !_isDropdownOpen);
    if (_isDropdownOpen && _generatedReport == null) {
      await _generateReport();
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    try {
      final result = await LabReportGeneratorService.generateReport(_report);
      if (mounted) {
        setState(() {
          _generatedReport = result;
          _isGenerating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal membuat laporan. Coba lagi.';
          _isGenerating = false;
        });
      }
    }
  }

  void _onSelanjutnyaCompletion() {
    if (_generatedReport == null) return;
    _report = _report.copyWith(
      isBadgeEarned: true,
      generatedReport: _generatedReport,
    );
    _goTo(LabStep.result);
  }

  // ── Result logic ───────────────────────────────────────────

  void _copyReport() {
    Clipboard.setData(ClipboardData(text: _report.generatedReport ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan disalin ke clipboard!'),
        backgroundColor: AppColors.success700,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetFlow() {
    _asamCtrl.clear();
    _basaCtrl.clear();
    _netralCtrl.clear();
    _kesimpulanCtrl.clear();
    _report = LabReportModel();
    _videoWatched = false;
    _isDropdownOpen = false;
    _isGenerating = false;
    _generatedReport = null;
    _errorMessage = null;
    _goTo(LabStep.form);

    // Keluar ke IntroScreen dan hapus riwayat halaman ini
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const IntroScreen(),
      ),
      (route) => false,
    );
  }

  // ── AppBar helpers ─────────────────────────────────────────

  bool get _showBackButton =>
      _currentStep == LabStep.video || _currentStep == LabStep.completion;

  int get _stepIndex => LabStep.values.indexOf(_currentStep);

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _pageFadeAnim,
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: _showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.primary900),
              onPressed: _goBack,
            )
          : null,
      title: const Text(
        AppStrings.appTitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary900,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      LabStep.form       => _buildFormStep(),
      LabStep.video      => _buildVideoStep(),
      LabStep.completion => _buildCompletionStep(),
      LabStep.result     => _buildResultStep(),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 1 — FORM
  // ═══════════════════════════════════════════════════════════

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepIndicator(currentStep: _stepIndex, totalSteps: 4),
          const SizedBox(height: 20),

          // Header card
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary200.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.science_rounded,
                          color: AppColors.primary800, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Hasil Eksperimen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            AppStrings.practikumSubtitle,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.neutral600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFE5E7EB)),
                const SizedBox(height: 16),
                const Text(
                  'Silakan tuliskan hasil pengamatan dan kesimpulan dari eksperimen yang telah Anda lakukan secara ringkas. Data yang Anda masukkan akan dirangkum otomatis menjadi laporan praktikum digital.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.neutral600, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Form card
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledTextField(
                  label: 'Kelompok Larutan Asam',
                  hint: 'Sebutkan larutan yang bersifat asam beserta perubahan warnanya (Misal: Kuning)',
                  controller: _asamCtrl, 
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Kelompok Larutan Basa',
                  hint: 'Sebutkan larutan yang bersifat basa beserta perubahan warnanya (Misal: Merah Bata)',
                  controller: _basaCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Kelompok Larutan Netral',
                  hint: 'Sebutkan larutan yang bersifat netral (Tidak berubah warna tajam)',
                  controller: _netralCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Kesimpulan',
                  hint: 'Tuliskan kesimpulan uji indikator alami kunyit pada berebagai sampel larutan di atas...',
                  controller: _kesimpulanCtrl,
                  maxLines: 5,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Simpan & Lanjut',
              onPressed: _formIsValid ? _onSaveAndNext : null,
              isLoading: _isSaving,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 2 — VIDEO
  // ═══════════════════════════════════════════════════════════

  Widget _buildVideoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepIndicator(currentStep: _stepIndex, totalSteps: 4),
          const SizedBox(height: 20),

          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    'Video Praktikum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary900,
                    ),
                  ),
                ),
                Container(height: 1, color: const Color(0xFFE5E7EB)),

                // Video placeholder
                GestureDetector(
                  onTap: () => setState(() => _videoWatched = true),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Center(
                      child: _videoWatched
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.success700.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded,
                                      color: AppColors.success700, size: 40),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Video selesai ditonton',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.success700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary800.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: AppColors.primary800,
                                      size: 48),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tap untuk menonton video',
                                  style: TextStyle(
                                      fontSize: 13, color: AppColors.neutral600),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                // Info banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info200.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.info500.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.info700, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tonton video praktikum terlebih dahulu sebelum melanjutkan.',
                            style:
                                TextStyle(fontSize: 12, color: AppColors.info700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Selanjutnya',
              onPressed: () => _goTo(LabStep.completion),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 3 — COMPLETION
  // ═══════════════════════════════════════════════════════════

  Widget _buildCompletionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepIndicator(currentStep: _stepIndex, totalSteps: 4),
          const SizedBox(height: 20),

          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _SelamatHeader()),
                    const SizedBox(width: 12),
                    ScaleTransition(
                      scale: _badgeScaleAnim,
                      child: const _TrophyBadge(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFE5E7EB)),
                const SizedBox(height: 16),

                // Badge notification
                const _BadgeBanner(),
                const SizedBox(height: 16),

                // Dropdown trigger
                GestureDetector(
                  onTap: _onDropdownToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hasil Laporan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutral800,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isDropdownOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dropdown content (animated)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isDropdownOpen
                      ? _buildDropdownContent()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Selanjutnya',
              onPressed:
                  _generatedReport != null ? _onSelanjutnyaCompletion : null,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdownContent() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary900.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: _isGenerating
          ? const _LoadingWidget()
          : _errorMessage != null
              ? _ErrorWidget(message: _errorMessage!, onRetry: _generateReport)
              : _generatedReport != null
                  ? _ReportPreviewWidget(report: _generatedReport!)
                  : const SizedBox.shrink(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 4 — RESULT
  // ═══════════════════════════════════════════════════════════

  Widget _buildResultStep() {
    final reportText = _report.generatedReport ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepIndicator(currentStep: _stepIndex, totalSteps: 4),
          const SizedBox(height: 20),

          // Selamat card (same header, no dropdown)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _SelamatHeader()),
                    const SizedBox(width: 12),
                    ScaleTransition(
                      scale: _badgeScaleAnim,
                      child: const _TrophyBadge(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFE5E7EB)),
                const SizedBox(height: 16),
                const _BadgeBanner(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Generated report card
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hasil Laporan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary200.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 12, color: AppColors.primary800),
                          SizedBox(width: 4),
                          Text(
                            'AI Generated',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.practikumTitle,
                  style:
                      TextStyle(fontSize: 12, color: AppColors.neutral600),
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFE5E7EB)),
                const SizedBox(height: 16),

                // Formatted report body
                _FormattedReportText(text: reportText),

                const SizedBox(height: 20),

                // Image placeholder
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 32, color: AppColors.neutral600),
                        SizedBox(height: 6),
                        Text(
                          'Dokumentasi Praktikum',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Download button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _copyReport,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary800.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download_rounded,
                          color: AppColors.primary800, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Kembali ke Beranda',
              onPressed: _resetFlow,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED SUB-WIDGETS (private, file-scoped)
// ═══════════════════════════════════════════════════════════════

class _SelamatHeader extends StatelessWidget {
  const _SelamatHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Selamat! Anda telah berhasil menyelesaikan seluruh tahapan praktikum ini dengan baik. Berikut adalah rangkuman laporan digital beserta badge pencapaian yang berhasil Anda dapatkan.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.neutral600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  const _TrophyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.warning400,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.emoji_events_rounded,
          color: AppColors.warning900, size: 26),
    );
  }
}

class _BadgeBanner extends StatelessWidget {
  const _BadgeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success200.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success700.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.card_membership_rounded,
              color: AppColors.success700, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kamu telah memperoleh Kunyit badge dan +500XP!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.success700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 12),
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.primary800),
        ),
        SizedBox(height: 12),
        Text(
          'Sedang membuat laporan otomatis...',
          style: TextStyle(fontSize: 13, color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
      ],
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message,
            style:
                const TextStyle(color: AppColors.danger500, fontSize: 13)),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded,
              size: 16, color: AppColors.primary800),
          label: const Text('Coba Lagi',
              style:
                  TextStyle(color: AppColors.primary800, fontSize: 13)),
        ),
      ],
    );
  }
}

class _ReportPreviewWidget extends StatelessWidget {
  final String report;

  const _ReportPreviewWidget({required this.report});

  @override
  Widget build(BuildContext context) {
    final preview =
        report.length > 200 ? '${report.substring(0, 200)}...' : report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success700, size: 16),
            SizedBox(width: 6),
            Text(
              'Laporan berhasil dibuat!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          preview,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B4D4D),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tekan "Selanjutnya" untuk melihat laporan lengkap.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Formatted report text — renders **bold** markdown inline
// ─────────────────────────────────────────────────────────────
class _FormattedReportText extends StatelessWidget {
  final String text;

  const _FormattedReportText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: text.split('\n').map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);

        // Full-line heading: **Heading**
        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              line.replaceAll('**', '').trim(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary900,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildRichLine(line),
        );
      }).toList(),
    );
  }

  Widget _buildRichLine(String line) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int cursor = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: line.substring(cursor, match.start),
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF4B4D4D), height: 1.6),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary900,
          height: 1.6,
        ),
      ));
      cursor = match.end;
    }

    if (cursor < line.length) {
      spans.add(TextSpan(
        text: line.substring(cursor),
        style: const TextStyle(
            fontSize: 13, color: Color(0xFF4B4D4D), height: 1.6),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}