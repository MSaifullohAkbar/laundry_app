import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/bottom_action_bar.dart';

class ParfumScreen extends StatefulWidget {
  const ParfumScreen({super.key});

  @override
  State<ParfumScreen> createState() => _ParfumScreenState();
}

class _ParfumScreenState extends State<ParfumScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedTab = 3;

  @override
  void dispose() {
    _searchCtrl.dispose();
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
          Consumer<ParfumProvider>(
            builder: (ctx, prov, _) {
              final parfums = prov.filteredParfums;
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          'Kelola Parfum',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            boxShadow: AppShadows.cardLight,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.search,
                                  color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: prov.setSearchQuery,
                                  decoration: const InputDecoration(
                                    hintText: 'Cari parfum...',
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    filled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: parfums.length,
                          itemBuilder: (ctx, i) {
                            final p = parfums[i];
                            return _buildParfumCard(p);
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              rightAction: GradientButton(
                label: 'Tambah Parfum Baru',
                icon: Icons.add,
                isFullWidth: true,
                onPressed: () {},
              ),
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

  Widget _buildParfumCard(dynamic p) {
    final isOut = p.isOutOfStock;
    final isLow = p.isLowStock;

    return AnimatedOpacity(
      opacity: isOut ? 0.75 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.cardLight,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isOut
                      ? const Icon(Icons.block,
                          color: AppColors.onSurfaceVariant, size: 26)
                      : const Icon(Icons.water_drop,
                          color: AppColors.primary, size: 26),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppColors.secondary,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              p.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOut
                        ? AppColors.onSurfaceVariant
                        : isLow
                            ? AppColors.error
                            : AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOut
                      ? 'Stok Habis'
                      : '${p.stockLiters.toStringAsFixed(1)} L',
                  style: TextStyle(
                    fontSize: 13,
                    color: isOut
                        ? AppColors.onSurfaceVariant
                        : isLow
                            ? AppColors.error
                            : AppColors.onSurface,
                    fontWeight: isLow || isOut
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                if (isLow)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Hampir Habis',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
