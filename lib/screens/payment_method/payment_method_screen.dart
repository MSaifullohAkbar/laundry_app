import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/payment_method.dart';
import '../../providers/payment_method_provider.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments;
      case 'transfer':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.account_balance_wallet;
      case 'qris':
        return Icons.qr_code_2;
      default:
        return Icons.payment;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'cash':
        return AppColors.secondary;
      case 'transfer':
        return AppColors.primary;
      case 'ewallet':
        return AppColors.tertiary;
      case 'qris':
        return const Color(0xFF6750A4);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color _bgForType(String type) {
    switch (type) {
      case 'cash':
        return AppColors.secondaryContainer;
      case 'transfer':
        return AppColors.primaryFixed;
      case 'ewallet':
        return AppColors.tertiaryFixed;
      case 'qris':
        return const Color(0xFFE8DEF8);
      default:
        return AppColors.surfaceContainerHigh;
    }
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
          Consumer<PaymentMethodProvider>(
            builder: (ctx, provider, _) {
              final methods = provider.methods;
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          'Metode Bayar',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kelola metode pembayaran yang tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary stats
                        _buildSummaryRow(provider),
                        const SizedBox(height: 20),

                        // List
                        ...methods.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMethodCard(context, m, provider),
                            )),

                        if (methods.isEmpty)
                          _buildEmptyState(),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),

          // Fixed bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: GestureDetector(
                onTap: () => context.go('/payment-methods/add'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: AppShadows.primaryButton,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Tambah Metode Bayar',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(PaymentMethodProvider provider) {
    final total = provider.methods.length;
    final active = provider.activeMethods.length;
    final inactive = total - active;

    return Row(
      children: [
        _buildStatChip('Total', total.toString(), AppColors.primaryFixed,
            AppColors.primary),
        const SizedBox(width: 10),
        _buildStatChip('Aktif', active.toString(), AppColors.secondaryFixed,
            AppColors.secondary),
        const SizedBox(width: 10),
        _buildStatChip('Nonaktif', inactive.toString(),
            AppColors.errorContainer, AppColors.error),
      ],
    );
  }

  Widget _buildStatChip(
      String label, String count, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
      BuildContext context, PaymentMethod method, PaymentMethodProvider provider) {
    final color = _colorForType(method.type);
    final bgColor = _bgForType(method.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconForType(method.type),
                      color: color, size: 26),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: method.isActive
                                  ? AppColors.secondaryFixed
                                  : AppColors.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              method.isActive ? 'Aktif' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: method.isActive
                                    ? AppColors.secondary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PaymentMethod.typeLabel(method.type),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (method.accountNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${method.accountNumber} • ${method.accountName ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    // Toggle switch
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: method.isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (_) => provider.toggleActive(method.id),
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () => _confirmDelete(context, method, provider),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.onSurfaceVariant, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada metode bayar',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan metode pembayaran untuk transaksi',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, PaymentMethod method, PaymentMethodProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Metode Bayar'),
        content: Text('Yakin ingin menghapus "${method.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMethod(method.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${method.name}" berhasil dihapus'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
