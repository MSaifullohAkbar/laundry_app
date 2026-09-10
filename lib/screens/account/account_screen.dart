import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedTab = 1;

  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load user data from Supabase auth
    final user = supabase.auth.currentUser;
    if (user != null) {
      _emailCtrl.text = user.email ?? '';
      final meta = user.userMetadata;
      if (meta != null) {
        _namaCtrl.text = meta['full_name'] ?? '';
        _teleponCtrl.text = meta['phone'] ?? '';
        _alamatCtrl.text = meta['address'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _alamatCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 8),
                    _buildProfileForm(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      elevation: 0,
      pinned: false,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.primary),
        onPressed: () {},
      ),
      title: const Text(
        'LaundryKu Kasir',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: _isSaving
                ? null
                : () async {
                    if (_isEditing) {
                      // Save to Supabase
                      setState(() => _isSaving = true);
                      try {
                        await supabase.auth.updateUser(
                          UserAttributes(
                            data: {
                              'full_name': _namaCtrl.text.trim(),
                              'phone': _teleponCtrl.text.trim(),
                              'address': _alamatCtrl.text.trim(),
                            },
                          ),
                        );
                        if (mounted) {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil disimpan!'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal menyimpan: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    size: 18,
                    color: AppColors.primary,
                  ),
            label: Text(
              _isSaving ? 'Menyimpan...' : (_isEditing ? 'Simpan' : 'Edit'),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF0085B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.currentUser;
                      return Column(
                        children: [
                          Text(
                            user?.displayName ?? _namaCtrl.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              user?.roleLabel ?? 'Kasir',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppShadows.cardFocused,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildField(
              label: 'Nama Lengkap',
              controller: _namaCtrl,
              icon: Icons.badge_outlined,
              hint: 'Masukkan nama lengkap',
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Email',
              controller: _emailCtrl,
              icon: Icons.email_outlined,
              hint: 'Masukkan email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Nomor Telepon',
              controller: _teleponCtrl,
              icon: Icons.phone_outlined,
              hint: 'Masukkan nomor telepon',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Alamat',
              controller: _alamatCtrl,
              icon: Icons.location_on_outlined,
              hint: 'Masukkan alamat lengkap',
              minLines: 3,
              maxLines: 4,
            ),
            const SizedBox(height: 28),

            // Divider
            Container(
              height: 1,
              color: AppColors.surfaceContainerLow,
            ),
            const SizedBox(height: 20),

            // Ganti Password button
            _buildActionTile(
              icon: Icons.lock_outline,
              label: 'Ganti Password',
              color: AppColors.primary,
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              icon: Icons.logout,
              label: 'Keluar',
              color: AppColors.error,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await context.read<AuthProvider>().signOut();
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Gagal keluar: $e')),
                            );
                          }
                        },
                        child: const Text('Keluar',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isLoading = false;
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ganti Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordCtrl,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureText = !obscureText),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscureText,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureText,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final oldPassword = oldPasswordCtrl.text;
                  final newPassword = passwordCtrl.text;
                  final confirmPassword = confirmCtrl.text;

                  if (oldPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan password lama terlebih dahulu')),
                    );
                    return;
                  }

                  if (newPassword.isEmpty || newPassword.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password baru minimal 6 karakter')),
                    );
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Konfirmasi password tidak cocok')),
                    );
                    return;
                  }

                  setState(() => isLoading = true);
                  try {
                    await context.read<AuthProvider>().updatePassword(oldPassword, newPassword);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password berhasil diubah')),
                      );
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (context.mounted) {
                      String errorMessage = e.toString();
                      if (errorMessage.startsWith('Exception: ')) {
                        errorMessage = errorMessage.substring(11);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengubah password: $errorMessage')),
                      );
                    }
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: !_isEditing,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _isEditing
                ? AppColors.onSurface
                : AppColors.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: minLines > 1
                  ? const EdgeInsets.only(bottom: 42)
                  : EdgeInsets.zero,
              child: Icon(icon,
                  color: _isEditing
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 20),
            ),
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: _isEditing
                ? AppColors.surfaceContainerLow
                : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (i) {
        setState(() => _selectedTab = i);
        switch (i) {
          case 0:
            context.go('/');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale), label: 'Kasir'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Akun'),
      ],
    );
  }
}
