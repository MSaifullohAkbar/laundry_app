import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final tx = provider.getById(transactionId);

    if (tx == null) {
      return Scaffold(
        appBar: GradientAppBar(
          title: 'Detail Transaksi',
          onBack: () => context.go('/'),
        ),
        body: const Center(child: Text('Transaksi tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Detail Transaksi',
        onBack: () => context.go('/reports/history'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            child: Column(
              children: [
                // Customer + Service Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                    boxShadow: AppShadows.cardFocused,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(tx.customer.phone,
                              style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          _statusBadge(tx.status),
                          _statusBadge(tx.isPaid ? 'lunas' : 'belum lunas'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      ...tx.items.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryContainer
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.local_laundry_service,
                                      color: Colors.white,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.service.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      Text(
                                          '${item.quantity} ${item.service.unit}',
                                          style: const TextStyle(
                                              color:
                                                  AppColors.onSurfaceVariant,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatRupiah(item.subtotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Info Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                    boxShadow: AppShadows.cardLight,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _infoRow('No. Nota', tx.invoiceNumber),
                      _infoRow('Tanggal Masuk', _formatDate(tx.createdAt)),
                      if (tx.estimatedDone != null)
                        _infoRowHighlight(
                            'Estimasi Selesai',
                            _formatDate(tx.estimatedDone!)),
                      _infoRow('Kasir', tx.cashierName),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cost Breakdown Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                    boxShadow: AppShadows.cardLight,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _costRow('Subtotal', tx.subtotal),
                      if (tx.deliveryFee > 0)
                        _costRow('Biaya Antar/Jemput', tx.deliveryFee),
                      if (tx.discount > 0)
                        _discountRow('Diskon', tx.discount),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 18)),
                          const Spacer(),
                          Text(
                            _formatRupiah(tx.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tx.isPaid
                              ? AppColors.secondaryContainer
                              : AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tx.isPaid
                                  ? Icons.check_circle
                                  : Icons.pending_actions,
                              color: tx.isPaid
                                  ? AppColors.secondary
                                  : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tx.isPaid ? 'Sudah Lunas' : 'Belum Lunas',
                              style: TextStyle(
                                color: tx.isPaid
                                    ? AppColors.secondary
                                    : AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
              leftInfo: OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Proses Order'),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              rightAction: GradientButton(
                label: 'Bayar',
                icon: Icons.account_balance_wallet,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'antrian':
        bg = AppColors.primaryFixed;
        fg = AppColors.primary;
        break;
      case 'proses':
        bg = AppColors.tertiaryFixed;
        fg = AppColors.tertiary;
        break;
      case 'selesai':
        bg = AppColors.secondaryContainer;
        fg = AppColors.secondary;
        break;
      case 'terlambat':
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        break;
      case 'lunas':
        bg = AppColors.secondaryContainer;
        fg = AppColors.secondary;
        break;
      case 'belum lunas':
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        break;
      default:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.substring(0, 1).toUpperCase() + status.substring(1),
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowHighlight(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 14)),
          const Spacer(),
          Text(_formatRupiah(amount),
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _discountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.onTertiaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          Text(
            '- ${_formatRupiah(amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
