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

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await ApiService.login(
      _usernameController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PilihUnitScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Hero Container
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 310,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=1200&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppTheme.primary,
                    BlendMode.multiply,
                  ),
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo Area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                      ),
                      child: const Icon(
                        Icons.engineering,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PLN Nusa Daya',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'Sistem HAR & Logsheet PLTD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onPrimaryContainer,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 4,
                              child: Container(color: AppTheme.primary),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selamat Datang',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const Text(
                                    'Masuk untuk mengakses sistem HAR PLN Nusa Daya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Username Field
                                  const Text(
                                    'Username',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
                                      hintText: 'Masukkan ID atau username',
                                      filled: true,
                                      fillColor: AppTheme.surfaceContainerLow,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password Field
                                  const Text(
                                    'Kata Sandi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          color: AppTheme.outline,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      hintText: 'Masukkan kata sandi',
                                      filled: true,
                                      fillColor: AppTheme.surfaceContainerLow,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.outlineVariant),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Remember Me & Quick Superadmin Fill
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                            activeColor: AppTheme.primary,
                                          ),
                                          const Text(
                                            'Ingat saya',
                                            style: TextStyle(fontSize: 12, color: AppTheme.outline),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _usernameController.text = 'kal3';
                                          _passwordController.text = 'password';
                                        },
                                        child: const Text(
                                          'Akun kal3',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Masuk',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.login, size: 20),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      '© 2026 PLN Nusa Daya.\nDivisi HAR & Monitoring PLTD - Regional Kalimantan 3',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppTheme.outline),
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
