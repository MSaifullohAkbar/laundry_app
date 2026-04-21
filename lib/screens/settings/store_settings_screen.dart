import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _nameCtrl =
      TextEditingController(text: 'LaundryKu Cabang Utama');
  final _addressCtrl = TextEditingController(
      text: 'Jl. Merdeka No. 10, Jakarta Pusat, DKI Jakarta 10110');
  final _notesCtrl =
      TextEditingController(text: 'Terima kasih telah mempercayai kami!');
  final _footerCtrl =
      TextEditingController(text: 'Barang tidak diambil dalam 30 hari menjadi hak toko.');

  int _selectedTab = 3;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'LaundryKu Kasir',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Blur decoration
                      Positioned(
                        top: -20,
                        right: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        right: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: const Text(
                                  'Manajemen Outlet',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pengaturan Toko',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'Kelola informasi toko Anda',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Card (overlap)
                Transform.translate(
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
                        // Logo
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: AppShadows.cardFocused,
                                ),
                                child: const Icon(Icons.local_laundry_service,
                                    color: Colors.white, size: 56),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: AppShadows.cardLight,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        _label('Nama Toko'),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.store, color: AppColors.primary),
                            hintText: 'Nama toko',
                          ),
                        ),
                        const SizedBox(height: 16),

                        _label('Alamat'),
                        TextField(
                          controller: _addressCtrl,
                          minLines: 3,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 42),
                              child: Icon(Icons.location_on,
                                  color: AppColors.primary),
                            ),
                            hintText: 'Alamat lengkap toko',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _label('Catatan Struk'),
                                  TextField(
                                    controller: _notesCtrl,
                                    minLines: 2,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Catatan atas struk',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2),
                                      ),
                                      filled: true,
                                      fillColor:
                                          AppColors.surfaceContainerLow,
                                      contentPadding:
                                          const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _label('Pesan Bawah'),
                                  TextField(
                                    controller: _footerCtrl,
                                    minLines: 2,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Pesan di bawah struk',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2),
                                      ),
                                      filled: true,
                                      fillColor:
                                          AppColors.surfaceContainerLow,
                                      contentPadding:
                                          const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Pengaturan berhasil disimpan!'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              boxShadow: AppShadows.primaryButton,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) {
          setState(() => _selectedTab = i);
          if (i == 0) context.go('/');
          if (i == 2) context.go('/reports');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
