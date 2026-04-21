import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;

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
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildRevenueCard(),
                    const SizedBox(height: 16),
                    _buildStoreInfoCard(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildMenuGrid(),
                  ]),
                ),
              ),
            ],
          ),
          _buildFAB(),
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
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryFixed,
            child: const Text(
              'A',
              style: TextStyle(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Consumer<TransactionProvider>(
      builder: (ctx, provider, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF0085B4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.primaryButton,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '+15%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Pendapatan',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 1.250.000',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LaundryKu Cabang Utama',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'Buka: 07.00 – 21.00',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Ubah',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<TransactionProvider>(
      builder: (ctx, provider, _) {
        return Row(
          children: [
            _statItem('Masuk', provider.inQueueCount.toString(),
                Icons.move_to_inbox, AppColors.secondaryFixed,
                AppColors.secondary),
            const SizedBox(width: 10),
            _statItem('Harus Selesai', provider.mustFinishCount.toString(),
                Icons.schedule, AppColors.tertiaryFixed, AppColors.tertiary),
            const SizedBox(width: 10),
            _statItem('Terlambat', provider.lateCount.toString(),
                Icons.warning, AppColors.errorContainer, AppColors.error),
          ],
        );
      },
    );
  }

  Widget _statItem(String label, String count, IconData icon, Color bg,
      Color iconColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: iconColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menus = [
      _MenuItem('Layanan', Icons.local_laundry_service,
          AppColors.primaryContainer, '/services'),
      _MenuItem('Riwayat', Icons.history, AppColors.secondaryContainer,
          '/reports/history'),
      _MenuItem(
          'Laporan', Icons.bar_chart, AppColors.tertiaryFixed, '/reports'),
      _MenuItem('Parfum', Icons.water_drop,
          AppColors.surfaceContainerHighest, '/parfum'),
      _MenuItem(
          'Pelanggan', Icons.groups, AppColors.primaryFixedDim, '/customers'),
      _MenuItem('Pengeluaran', Icons.payments, AppColors.errorContainer, '/'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Utama',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: menus
              .map((m) => _buildMenuTile(m))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.cardLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: AppColors.onSurface, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Positioned(
      bottom: 72,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: () => context.go('/transaction/new'),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.primaryButton,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'TRANSAKSI BARU',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
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
          case 2:
            context.go('/reports');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
      ],
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _MenuItem(this.label, this.icon, this.color, this.route);
}
