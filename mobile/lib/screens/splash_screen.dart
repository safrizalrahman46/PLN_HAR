import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'title': 'Keandalan Operasi Pembangkit 24 Jam',
      'subtitle': 'Transformasi digital pemeliharaan terpadu untuk monitoring unit PLTD secara real-time dan andal.',
      'badge': 'PLN NUSA DAYA WACB',
      'icon': Icons.bolt_rounded,
      'accentColor': Color(0xFF00A2E8),
      'chips': ['48-Slot WACB', 'Real-time Sinkron', 'EAF 99.2%'],
    },
    {
      'title': 'Checklist HAR & Inspeksi Terstandar',
      'subtitle': 'Pemeriksaan 4 subsistem mesin: pelumasan, sistem pendingin, udara bakar, dan elektrikal sesuai SOP K3.',
      'badge': 'PREVENTIVE HAR',
      'icon': Icons.checklist_rounded,
      'accentColor': Color(0xFF10B981),
      'chips': ['SOP K3', 'Zero Accident', 'Foto Geotag'],
    },
    {
      'title': 'Berita Acara & 1-Klik SPV Approval',
      'subtitle': 'Validasi dokumen resmi otomatis dengan ekspor PDF, Excel, dan pengesahan digital terverifikasi.',
      'badge': 'BERITA ACARA RESMI',
      'icon': Icons.verified_rounded,
      'accentColor': Color(0xFFFFD500),
      'chips': ['Export PDF', 'Excel Workbook', 'Tanda Tangan Digital'],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Deep Gradient Background with App Title & Skip button
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF002244),
                        Color(0xFF003F7A),
                        Color(0xFF005EA6),
                        Color(0xFF00A2E8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top App Bar: Brand Pill & Skip Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt, size: 14, color: Color(0xFFFFD500)),
                                    SizedBox(width: 4),
                                    Text(
                                      'PLN NUSA DAYA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _goToLogin,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Lewati',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),

                          // Center Graphic: Interactive Illustration Cards
                          _buildCenterIllustration(),

                          // Page Indicator Dots (Matching Jobsly o o o)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_onboardingPages.length, (index) {
                              final isCurrent = _currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isCurrent ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom White Sheet (Matching Jobsly & Modern Reference)
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      // Slideable Titles & Descriptions
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: _onboardingPages.length,
                          itemBuilder: (context, index) {
                            final page = _onboardingPages[index];
                            final chips = page['chips'] as List<String>;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (page['accentColor'] as Color).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    page['badge'] as String,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: page['accentColor'] as Color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  page['subtitle'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Feature Tag Chips
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: chips.map((c) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        '✓ $c',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Bottom CTA Button: "Mulai Sekarang" (Jobsly Style)
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            IconButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                padding: const EdgeInsets.all(14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF004F8A), Color(0xFF00A2E8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00A2E8).withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_currentPage < _onboardingPages.length - 1) {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    _goToLogin();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == _onboardingPages.length - 1
                                          ? 'Mulai Sekarang'
                                          : 'Lanjutkan',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  // Jobsly-style Illustration with overlapping cards and center pulse button
  Widget _buildCenterIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient Glow Circle
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),

        // Left Angled Card (Logsheet)
        Transform.translate(
          offset: const Offset(-45, -8),
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 100,
              height: 115,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(-2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 24, height: 4, decoration: BoxDecoration(color: const Color(0xFF00A2E8), borderRadius: BorderRadius.circular(2))),
                      const Icon(Icons.bolt, size: 12, color: Color(0xFFFFD500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(width: 60, height: 3, color: const Color(0xFFCBD5E1)),
                  const SizedBox(height: 4),
                  Container(width: 45, height: 3, color: const Color(0xFFCBD5E1)),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('380 kW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Angled Card (Berita Acara Checklist)
        Transform.translate(
          offset: const Offset(45, -8),
          child: Transform.rotate(
            angle: 0.12,
            child: Container(
              width: 100,
              height: 115,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 24, height: 4, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
                      const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(width: 55, height: 3, color: const Color(0xFFCBD5E1)),
                  const SizedBox(height: 4),
                  Container(width: 40, height: 3, color: const Color(0xFFCBD5E1)),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('APPROVED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center Floating Pulse Avatar (Jobsly Style with + or Bolt)
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD500), Color(0xFFFF9E00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded, size: 30, color: Color(0xFF002F55)),
          ),
        ),
      ],
    );
  }
}
