import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';
import 'package:intl/intl.dart';

class NewTransactionScreen extends StatelessWidget {
  const NewTransactionScreen({super.key});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: GradientAppBar(
            title: 'Transaksi',
            showBack: true,
            onBack: () {
              provider.clearCart();
              context.go('/');
            },
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerCard(context, provider),
                    const SizedBox(height: 20),
                    _buildOrderSection(context, provider),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomActionBar(
                  leftInfo: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Harga',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant)),
                      Text(
                        _formatRupiah(provider.cartSubtotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  rightAction: GradientButton(
                    label: 'Checkout',
                    icon: Icons.shopping_cart_checkout,
                    isDisabled: !provider.canCheckout,
                    onPressed: provider.canCheckout
                        ? () {
                            provider.completeTransaction();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaksi berhasil dibuat!'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                            context.go('/');
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerCard(
      BuildContext context, TransactionProvider provider) {
    final customer = provider.cartCustomer;

    return GestureDetector(
      onTap: () => context.go('/transaction/pick-customer'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppShadows.cardLight,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: customer != null
                  ? AppColors.primary
                  : AppColors.surfaceContainerLow,
              child: customer != null
                  ? Text(
                      customer.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    )
                  : const Icon(Icons.person,
                      color: AppColors.onSurfaceVariant, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer != null ? customer.name : 'Pilih pelanggan...',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: customer != null
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (customer != null)
                    Text(
                      customer.phone,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text(
                'Cari',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(
      BuildContext context, TransactionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Detail Pesanan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/transaction/pick-service'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tambah Layanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.cartItems.isEmpty)
          _buildEmptyState()
        else
          _buildCartItems(provider),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.local_laundry_service,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada layanan',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan layanan laundry untuk memulai transaksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(TransactionProvider provider) {
    return Column(
      children: provider.cartItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.cardLight,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_laundry_service,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.service.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                      '${item.quantity} ${item.service.unit} × Rp ${_formatSimple(item.service.price)}',
                      style: const TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                _formatRupiah(item.subtotal),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatSimple(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
