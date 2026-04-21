import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../widgets/common/bottom_action_bar.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameCtrl = TextEditingController();
  bool _includeWash = true;
  bool _includeDry = false;
  bool _includeIron = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => context.go('/services'),
        ),
        title: const Text(
          'LaundryKu Kasir',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Layanan',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Info Card
                _buildCard(
                  title: 'Informasi Dasar',
                  icon: Icons.info_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Layanan',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Cuci Kiloan Reguler',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Process Card
                _buildCard(
                  title: 'Proses',
                  icon: Icons.settings,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pilih proses yang termasuk:',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _processToggle(
                              'Cuci', Icons.water_drop, _includeWash,
                              () => setState(
                                  () => _includeWash = !_includeWash)),
                          const SizedBox(width: 10),
                          _processToggle('Kering', Icons.air, _includeDry,
                              () => setState(
                                  () => _includeDry = !_includeDry)),
                          const SizedBox(width: 10),
                          _processToggle('Setrika', Icons.iron, _includeIron,
                              () => setState(
                                  () => _includeIron = !_includeIron)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service Types Card
                _buildCard(
                  title: 'Jenis Layanan',
                  icon: Icons.category,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Atur varian layanan',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.category,
                                  color: AppColors.primary, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada jenis layanan',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tekan tombol "Tambah" untuk membuat jenis layanan pertama',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: const Text(
                                  'Buat Jenis Pertama',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              leftInfo: GestureDetector(
                onTap: () => context.go('/services'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
              rightAction: GradientButton(
                label: 'Simpan Layanan',
                icon: Icons.save,
                onPressed: () {
                  context.go('/services');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _processToggle(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color:
                    selected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
