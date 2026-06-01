import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart';
import '../models/game_state.dart';

class TheoryAndToolsScreen extends StatefulWidget {
  const TheoryAndToolsScreen({super.key});

  @override
  State<TheoryAndToolsScreen> createState() => _TheoryAndToolsScreenState();
}

class _TheoryAndToolsScreenState extends State<TheoryAndToolsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _tools = [
    {'name': 'Gelas Plastik', 'qty': '8 buah', 'color': AppColors.info, 'image': 'assets/images/gelas_plastik.jpg', 'func': 'Wadah untuk setiap larutan yang akan diuji dengan ekstrak kunyit.'},
    {'name': 'Ekstrak Kunyit', 'qty': '1 ons', 'color': AppColors.warningOrange, 'image': 'assets/images/kunyit.jpg', 'func': 'Bahan alami yang digunakan sebagai indikator untuk menguji sifat asam/basa.'},
    {'name': 'Air Murni', 'qty': '50 mL', 'color': AppColors.infoLight, 'image': 'assets/images/air_murni.jpg', 'func': 'Larutan netral sebagai kontrol pembanding dalam percobaan.'},
    {'name': 'Air Selokan', 'qty': '50 mL', 'color': AppColors.neutral700, 'image': 'assets/images/air_selokan.jpg', 'func': 'Sampel air lingkungan untuk diuji sifat keasamannya.'},
    {'name': 'Air Garam', 'qty': '50 mL', 'color': AppColors.primaryLighter, 'image': 'assets/images/air_garam.jpg', 'func': 'Larutan garam dapur untuk menguji sifat netral atau asinnya.'},
    {'name': 'Obat Maag', 'qty': '1 tablet', 'color': AppColors.success, 'image': 'assets/images/obat_maag.jpg', 'func': 'Bahan basa yang digunakan untuk menguji reaksi indikator pada basa.'},
    {'name': 'Air Sabun', 'qty': '50 mL', 'color': AppColors.secondaryLight, 'image': 'assets/images/air_sabun.jpg', 'func': 'Larutan sabun bersifat basa, digunakan sebagai sampel larutan basa.'},
    {'name': 'Larutan Cuka', 'qty': '50 mL', 'color': AppColors.dangerLight, 'image': 'assets/images/cuka.jpg', 'func': 'Larutan asam asetat yang digunakan sebagai sampel larutan asam.'},
    {'name': 'Air Kapur', 'qty': '50 mL', 'color': AppColors.neutral800, 'image': 'assets/images/air_kapur.jpg', 'func': 'Larutan basa kuat dari kalsium hidroksida untuk menguji reaksi basa.'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildTheoryTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTheorySubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.neutral900),
      ),
    );
  }

  Widget _buildTheoryParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: AppColors.neutral800, height: 1.6),
      textAlign: TextAlign.justify,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isShort = MediaQuery.of(context).size.height < 500;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (isShort ? 8 : 14),
              left: isShort ? 14 : 24,
              right: isShort ? 14 : 24,
              bottom: isShort ? 10 : 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF0B357B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3300246B),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavButton(
                  label: '← Kembali',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 120), // spacer agar "Kembali" kiri atas
              ],
            ),
          ),

          // Konten Scrollable
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isShort ? 14 : 24,
                  isShort ? 14 : 24,
                  isShort ? 14 : 24,
                  isShort ? MediaQuery.of(context).padding.bottom + 14 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Landasan Teori
                    _SectionHeader(title: 'Landasan Teori', icon: Icons.menu_book_rounded),
                    SizedBox(height: isShort ? 14 : 20),

                    // Teks Teori
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isShort ? 16 : 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTheoryTitle('A. Tujuan Pembelajaran'),
                          _buildTheoryParagraph('Setelah kegiatan pembelajaran ini diharapkan dapat memprediksi pH larutan asam atau basa berdasarkan indikator asam basa.'),
                          const SizedBox(height: 16),
                          _buildTheoryTitle('B. Uraian Materi'),
                          _buildTheoryParagraph('Indikator asam basa adalah senyawa khusus yang ditambahkan pada larutan dengan tujuan mengetahui kisaran pH dari larutan tersebut. Indikator asam basa akan memberikan warna tertentu apabila direaksikan with larutan asam atau basa. Beberapa indikator terbuat dari bahan alami, akan tetapi ada juga beberapa indikator yang dibuat secara sintesis di laboratorium.'),
                          const SizedBox(height: 12),
                          _buildTheorySubtitle('1. Indikator Alami'),
                          _buildTheoryParagraph('Tanaman yang dapat dijadikan sebagai indikator adalah tanaman yang mempunyai warna terang contohnya: kol ungu, kulit manggis, bunga sepatu, bunga bougenvil, pacar air dan kunyit. Dapat atau tidaknya suatu tanaman dijadikan sebagai indikator alami adalah terjadinya perubahan warna apabila ekstraknya diteteskan pada larutan asam atau basa.'),
                          const SizedBox(height: 12),
                          _buildTheorySubtitle('2. Indikator Sintesis'),
                          _buildTheoryParagraph('Indikator hasil buatan laboratorium meliputi:\n• Kertas lakmus (memberikan perubahan warna pada asam/basa)\n• Indikator universal (memberikan warna berbeda untuk setiap nilai pH antara 1 sampai 14)\n• Larutan indikator (menunjukkan adanya perubahan warna rentang nilai pH tertentu)\n• pH meter (pengukur pH dengan cepat dan akurat melalui layar digital)'),
                          const SizedBox(height: 16),
                          _buildTheoryTitle('C. Rangkuman'),
                          _buildTheoryParagraph('1. Indikator asam basa memberikan warna berbeda ketika dikenai suatu asam atau basa.\n2. Indikator dibedakan menjadi alami dan sintesis.\n3. Indikator alami dibuat dari tanaman berwarna cerah (bunga/sayur).\n4. Indikator sintesis meliputi lakmus, larutan indikator, indikator universal, dan pH meter.'),
                          const SizedBox(height: 16),
                          _buildTheoryTitle('D. Penugasan Mandiri'),
                          _buildTheoryParagraph('Tujuan: Pengenalan larutan asam dan basa menggunakan indikator alami (Ekstrak Kunyit).\n\nProsedur:\n1) Buat ekstrak kunyit dengan cara menggerus kunyit, beri air sekitar setengah gelas, kemudian saring, letakkan dalam gelas plastik.\n2) Isi 7 gelas plastik masing-masing dengan air, air selokan, air garam, larutan obat maag, air sabun, larutan cuka dan air kapur.\n3) Pada masing-masing larutan tambahkan satu sendok ekstrak kunyit.\n4) Amati perubahan warna yang terjadi untuk mengelompokkan zat yang bersifat netral, asam, dan basa!'),
                        ],
                      ),
                    ),

                    SizedBox(height: isShort ? 24 : 40),

                    // Judul Alat & Bahan
                    _SectionHeader(title: 'Alat & Bahan', icon: Icons.construction_rounded),
                    SizedBox(height: isShort ? 14 : 20),

                    // Grid Alat & Bahan
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int cols = isPortrait
                            ? 2
                            : (constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 700 ? 3 : 2));
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: isShort ? 10 : 16,
                            mainAxisSpacing: isShort ? 10 : 16,
                            childAspectRatio: isPortrait ? 0.68 : 0.75, // Disesuaikan agar card lebih tinggi
                          ),
                          itemCount: _tools.length,
                          itemBuilder: (context, index) {
                            final tool = _tools[index];
                            return _ToolCard(
                              name: tool['name'] as String,
                              quantity: tool['qty'] as String,
                              accentColor: tool['color'] as Color,
                              function: tool['func'] as String,
                              image: tool['image'] as String?,
                            );
                          },
                        );
                      },
                    ),

                    SizedBox(height: isShort ? 24 : 40),

                    // Tombol Mulai Praktikum
                    Center(
                      child: _StartButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryDark],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, color: AppColors.white, size: 20)),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatefulWidget {
  final String name;
  final String quantity;
  final Color accentColor;
  final String function;
  final String? image;

  const _ToolCard({
    required this.name,
    required this.quantity,
    required this.accentColor,
    required this.function,
    this.image,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -5.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(_isHovered ? 0.2 : 0.07),
              blurRadius: _isHovered ? 24 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Area Ikon/Gambar
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor.withOpacity(0.12),
                        widget.accentColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: widget.image != null
                      ? Image.asset(
                          widget.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 36,
                              color: widget.accentColor.withOpacity(0.4),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 36,
                            color: widget.accentColor.withOpacity(0.4),
                          ),
                        ),
                ),
              ),
              // Garis aksen
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withOpacity(0.7),
                      widget.accentColor.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.straighten_rounded, size: 12, color: AppColors.neutral700),
                          const SizedBox(width: 4),
                          Text(
                            widget.quantity,
                            style: const TextStyle(fontSize: 11, color: AppColors.neutral700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.function,
                          style: const TextStyle(fontSize: 10, color: AppColors.neutral700, height: 1.3),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _isHovered
                ? [AppColors.secondary, AppColors.secondaryDark]
                : [AppColors.primary, const Color(0xFF0B357B)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isHovered ? AppColors.secondary : AppColors.primary).withOpacity(0.4),
              blurRadius: _isHovered ? 28 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final gameState = GameState();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(gameState: gameState),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Mulai Praktikum',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.white.withOpacity(0.25)
                : AppColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
