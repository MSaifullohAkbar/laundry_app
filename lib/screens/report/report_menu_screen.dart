import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';

class ReportMenuScreen extends StatelessWidget {
  const ReportMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthProvider, bool>((p) => p.currentUser?.isAdmin ?? false);

    final menus = [
      _ReportMenu(
        'Transaksi',
        Icons.receipt_long,
        AppColors.primaryContainer,
        'Laporan transaksi harian',
        '/reports/transactions',
      ),

      _ReportMenu(
        'Pelanggan',
        Icons.group,
        AppColors.secondaryContainer,
        'Statistik pelanggan',
        '/reports/customers',
      ),
      _ReportMenu(
        'Excel Export',
        Icons.table_chart,
        const Color(0xFFD7F0DC),
        'Unduh laporan Excel',
        '/reports/excel-export',
      ),
      if (isAdmin)
        _ReportMenu(
          'Kasir',
          Icons.point_of_sale,
          AppColors.secondaryFixed,
          'Laporan per kasir',
          '/reports/cashier',
        ),
      _ReportMenu(
        'Pelanggan Terbaik',
        Icons.emoji_events,
        AppColors.tertiaryFixed,
        'Analisis SAW pelanggan',
        '/reports/saw',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Menu Laporan',
        subtitle: 'Pilih jenis laporan yang ingin dilihat',
        onBack: () => context.go('/'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          physics: const BouncingScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
          children: menus.map((m) => _buildMenuCard(context, m)).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _ReportMenu menu) {
    return GestureDetector(
      onTap: () {
        if (menu.route.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur ini belum tersedia'),
              backgroundColor: AppColors.tertiary,
            ),
          );
          return;
        }
        context.go(menu.route);
      },
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: menu.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(menu.icon, color: AppColors.onSurface, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              menu.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                menu.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMenu {
  final String title;
  final IconData icon;
  final Color iconBg;
  final String description;
  final String route;

  const _ReportMenu(
      this.title, this.icon, this.iconBg, this.description, this.route);
}
