import 'package:flutter/material.dart';
import '../data/api_service.dart';
import 'pilih_unit_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Mode: 0 = Login, 1 = Register
  int _activeModeTab = 0;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(text: 'kal3');
  final _passwordController = TextEditingController(text: 'password');
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(int mode) {
    setState(() {
      _activeModeTab = mode;
      if (mode == 0 && _usernameController.text.isEmpty) {
        _usernameController.text = 'kal3';
        _passwordController.text = 'password';
      }
    });
  }

  void _fillQuickRole(String username, String password) {
    setState(() {
      _activeModeTab = 0;
      _usernameController.text = username;
      _passwordController.text = password;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kredensial demo diisi: $username'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan Username/NIP dan Kata Sandi.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_activeModeTab == 1 && password != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await ApiService.login(username, password);
    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessCongratulationsModal(user.name, user.role);
    }
  }

  // Matching Reference 1 (Screen 3: Congratulations Success Modal Popup)
  void _showSuccessCongratulationsModal(String name, String role) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Circular Success Icon (Matching Reference 1 Green Badge)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x5510B981),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 18),

              // Title & Message
              const Text(
                'Selamat, Berhasil!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Autentikasi $name sebagai ${role.toUpperCase()} telah terverifikasi secara resmi di server WACB.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // Yellow Primary CTA Button (Matching Reference 1 - FittedBox prevents any overflow)
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD500), Color(0xFFFFAB00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD500).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PilihUnitScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjut ke Dashboard Unit',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF002244),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Color(0xFF002244), size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _activeModeTab == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Clean neutral canvas for web preview
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
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. Top Deep Navy Header with PLN Branding (Matching Reference 2 - Jobsly)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 34),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF001F3F),
                        Color(0xFF003865),
                        Color(0xFF005A9C),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Row: Logo & Corporate Seal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, size: 13, color: Color(0xFFFFD500)),
                                SizedBox(width: 4),
                                Text(
                                  'PLN NUSA DAYA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isLogin ? 'Belum punya akun?' : 'Sudah terdaftar?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Brand Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF008CC8), Color(0xFF00A2E8)],
                              ),
                            ),
                            child: const Icon(Icons.bolt_rounded, size: 28, color: Color(0xFFFFD500)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PLN HAR & Logsheet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sistem Keandalan Operasi & WACB Pembangkit PLTD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Curved White Form Body (Matching Reference 1 & 2)
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  transform: Matrix4.translationValues(0.0, -18.0, 0.0),
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Titles (Matching Reference 1: "Step Into the Future...")
                      Text(
                        isLogin ? 'Selamat Datang' : 'Daftar Akun Pegawai',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLogin
                            ? 'Masukkan NIP atau username kredensial Anda di bawah ini.'
                            : 'Lengkapi formulir pendaftaran akun teknisi pembangkit.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Segmented Pill Switcher (Exact Replica of Reference 1 [Login] [Register])
                      _buildPillTabSwitcher(isLogin),
                      const SizedBox(height: 22),

                      // Full Name Field (Register Only)
                      if (!isLogin) ...[
                        _buildInputField(
                          label: 'Nama Lengkap',
                          hintText: 'Contoh: Ahmad Teknisi',
                          controller: _nameController,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Username / NIP Field
                      _buildInputField(
                        label: isLogin ? 'Username / NIP Pegawai' : 'NIP / ID Akun',
                        hintText: 'Contoh: kal3 atau ahmad',
                        controller: _usernameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      _buildInputField(
                        label: 'Kata Sandi',
                        hintText: '••••••••••••',
                        controller: _passwordController,
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),

                      // Confirm Password (Register Only)
                      if (!isLogin) ...[
                        const SizedBox(height: 14),
                        _buildInputField(
                          label: 'Konfirmasi Kata Sandi',
                          hintText: '••••••••••••',
                          controller: _confirmPasswordController,
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          obscure: _obscureConfirmPassword,
                          onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Remember Me & Forgot Password Row (Login Only)
                      if (isLogin)
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                activeColor: const Color(0xFF00A2E8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Ingat saya',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Silakan hubungi Superadmin Wilayah untuk reset password.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00A2E8),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Primary CTA Button (Matching Reference 1 Yellow/Lime Pill)
                      _buildSubmitButton(isLogin),
                      const SizedBox(height: 22),

                      // Divider "─── Atau masuk cepat sebagai ───" (Reference 1 & 2)
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              isLogin ? 'Atau masuk cepat sebagai' : 'Pilihan Akun Uji Coba',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Role Access Cards (Matching Google / Apple SSO buttons in Reference 1)
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickRolePill(
                              roleTitle: 'Supervisor',
                              badge: 'SPV',
                              color: const Color(0xFF004F8A),
                              onTap: () => _fillQuickRole('kal3', 'password'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickRolePill(
                              roleTitle: 'Teknisi',
                              badge: 'HAR',
                              color: const Color(0xFF10B981),
                              onTap: () => _fillQuickRole('ahmad', '123'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickRolePill(
                              roleTitle: 'Admin',
                              badge: 'ADM',
                              color: const Color(0xFFF59E0B),
                              onTap: () => _fillQuickRole('superadmin', 'admin123'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Security Watermark Footer
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 5),
                                Text(
                                  'Sistem Terenkripsi & Terverifikasi WACB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '© 2026 PT PLN Nusa Daya (Persero)',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                            ),
                          ],
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

  // Pill Tab Switcher: [ Login ] [ Register ] (Matching Reference 1)
  Widget _buildPillTabSwitcher(bool isLogin) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light grey pill track
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Login Pill
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isLogin
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD500), Color(0xFFFFB700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isLogin
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFD500).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isLogin ? const Color(0xFF002244) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Register Pill
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: !isLogin
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD500), Color(0xFFFFB700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !isLogin
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFD500).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: !isLogin ? const Color(0xFF002244) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Soft Rounded Input Field (Matching Reference 1 & 2)
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Soft fill
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscure : false,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 19, color: const Color(0xFF00A2E8)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 19,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // Primary Action Button (Matching Reference 1 Yellow Pill)
  Widget _buildSubmitButton(bool isLogin) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD500), Color(0xFFFFB700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD500).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Color(0xFF002244), strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? 'Login ke Sistem HAR' : 'Daftar Akun Sekarang',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF002244),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFF002244), size: 18),
                ],
              ),
      ),
    );
  }

  // Quick Role Access Pill (Matching Reference 1 Google / Apple SSO Buttons)
  Widget _buildQuickRolePill({
    required String roleTitle,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              roleTitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
