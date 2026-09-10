import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/bottom_action_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSetPassword() async {
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Password tidak boleh kosong');
      return;
    }

    if (newPass.length < 8) {
      _showError('Password minimal 8 karakter');
      return;
    }

    if (newPass != confirmPass) {
      _showError('Konfirmasi password tidak cocok');
      return;
    }

    try {
      await context.read<AuthProvider>().setNewPassword(newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah! Silakan login.'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    } on AuthException catch (e) {
      _showError(e.message);
    } on SocketException catch (_) {
      _showError('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) msg = msg.substring(11);
      _showError(msg);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Menghitung "kekuatan" password: 0-4
  int _passwordStrength(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$&*~%^]'))) score++;
    return score;
  }

  Color _strengthColor(int s) {
    switch (s) {
      case 0:
      case 1: return AppColors.error;
      case 2: return AppColors.tertiary;
      case 3: return const Color(0xFF1976D2);
      default: return const Color(0xFF2E7D32);
    }
  }

  String _strengthLabel(int s) {
    switch (s) {
      case 0:
      case 1: return 'Lemah';
      case 2: return 'Sedang';
      case 3: return 'Kuat';
      default: return 'Sangat Kuat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final strength = _passwordStrength(_newPasswordCtrl.text);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Buat Password Baru',
          style: TextStyle(color: AppColors.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        automaticallyImplyLeading: false, // tidak bisa back — session baru
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_open_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Judul
                const Text(
                  'Buat Password Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Password baru Anda harus berbeda\ndari password yang pernah digunakan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                    boxShadow: AppShadows.cardFocused,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field: Password Baru
                      const Text(
                        'Password Baru',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPasswordCtrl,
                        enabled: !isLoading,
                        obscureText: !_isNewPasswordVisible,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () => setState(
                              () => _isNewPasswordVisible = !_isNewPasswordVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Indikator kekuatan password
                      if (_newPasswordCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(4, (i) {
                            return Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i < strength
                                      ? _strengthColor(strength)
                                      : AppColors.outlineVariant,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              _strengthLabel(strength),
                              style: TextStyle(
                                fontSize: 11,
                                color: _strengthColor(strength),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Field: Konfirmasi Password
                      const Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        enabled: !isLoading,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSetPassword(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onPressed: () => setState(
                              () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // Validasi kecocokan password
                      if (_confirmPasswordCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _newPasswordCtrl.text == _confirmPasswordCtrl.text
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              size: 14,
                              color: _newPasswordCtrl.text == _confirmPasswordCtrl.text
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _newPasswordCtrl.text == _confirmPasswordCtrl.text
                                  ? 'Password cocok'
                                  : 'Password tidak cocok',
                              style: TextStyle(
                                fontSize: 12,
                                color: _newPasswordCtrl.text == _confirmPasswordCtrl.text
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: GradientButton(
                          label: isLoading ? 'Menyimpan...' : 'Simpan Password Baru',
                          icon: isLoading
                              ? Icons.hourglass_top
                              : Icons.check_circle_outline,
                          isDisabled: isLoading,
                          onPressed: _handleSetPassword,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info tips
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tips: Gunakan kombinasi huruf besar, angka, dan simbol agar password lebih aman.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onPrimaryContainer,
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
      ),
    );
  }
}
