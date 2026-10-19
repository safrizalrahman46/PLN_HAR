import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/api_service.dart';
import 'pilih_unit_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'kal3');
  final _passwordController = TextEditingController(text: 'password');
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  int _selectedRoleTab = 0; // 0 = SPV, 1 = Teknisi

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleTabChanged(int index) {
    setState(() {
      _selectedRoleTab = index;
      if (index == 0) {
        _usernameController.text = 'kal3';
        _passwordController.text = 'password';
      } else {
        _usernameController.text = 'ahmad';
        _passwordController.text = '123';
      }
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final user = await ApiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selamat datang, ${user.name}! (${user.role.toUpperCase()})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PilihUnitScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          // Background Gradient Hero (PLN Mobile signature wave)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.plnHeroGradient,
              ),
              child: Stack(
                children: [
                  // Decorative Glow Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Brand Header
                      _buildBrandHeader(),
                      const SizedBox(height: 24),

                      // Segmented Role Switcher (Tasktugas style)
                      _buildSegmentedTab(),
                      const SizedBox(height: 16),

                      // Login Card
                      _buildFormCard(),
                      const SizedBox(height: 24),

                      // Security / Footer Info
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.plnHeroGradient,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 34,
                  color: AppTheme.secondaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'PLN Nusa Daya',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 13, color: AppTheme.secondaryContainer),
              SizedBox(width: 5),
              Text(
                'SISTEM HAR & LOGSHEET PLTD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleTabChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedRoleTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedRoleTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 16,
                      color: _selectedRoleTab == 0 ? AppTheme.primaryDark : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Supervisor (SPV)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedRoleTab == 0 ? AppTheme.primaryDark : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _onRoleTabChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedRoleTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedRoleTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.engineering_rounded,
                      size: 16,
                      color: _selectedRoleTab == 1 ? AppTheme.primaryDark : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Teknisi Lapangan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedRoleTab == 1 ? AppTheme.primaryDark : Colors.white,
                      ),
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

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  size: 20,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRoleTab == 0 ? 'Login Supervisor' : 'Login Teknisi PLTD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Text(
                    'Akses checklist HAR & logsheet operasional',
                    style: TextStyle(fontSize: 12, color: AppTheme.outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Username Field
          const Text(
            'Username / ID Pegawai',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 20),
              hintText: 'Contoh: kal3 atau ahmad',
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          const Text(
            'Kata Sandi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.outline,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              hintText: 'Masukkan kata sandi akun',
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: 14),

          // Remember Me Row
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (val) => setState(() => _rememberMe = val ?? true),
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ingat sesi login',
                style: TextStyle(fontSize: 12, color: AppTheme.outline, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan hubungi Superadmin Regional Kalimantan 3 untuk reset password.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Lupa Sandi?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Submit CTA Button
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.plnElectricGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.glowShadow,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk ke Sistem HAR',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, size: 14, color: AppTheme.secondary),
            const SizedBox(width: 4),
            Text(
              'Regional Kalimantan 3 • Terhubung Server Pusat',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '© 2026 PT PLN Nusa Daya. All rights reserved.',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
