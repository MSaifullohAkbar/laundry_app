import 'package:flutter/material.dart';
import '../../utils/format_helpers.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/payment_method_provider.dart';
import '../../providers/bluetooth_printer_provider.dart';
import '../../providers/store_settings_provider.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

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
        body: const Center(
          child: Text('Transaksi tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Detail Transaksi',
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => _printReceipt(context, tx),
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
                _buildCustomerAndServiceCard(tx),
                const SizedBox(height: 16),
                _buildTransactionInfoCard(tx),
                const SizedBox(height: 16),
                _buildCostBreakdownCard(context, tx),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(context, tx, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndServiceCard(dynamic tx) {
    return Container(
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
              const Icon(
                Icons.phone,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                tx.customer.phone,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
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
          ...tx.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.card),
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
                          AppColors.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.service.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.service.unit}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    FormatHelper.formatRupiah(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoCard(dynamic tx) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _infoRow('No. Nota', tx.invoiceNumber),
          _infoRow('Tanggal Masuk', FormatHelper.formatDate(tx.createdAt)),
          if (tx.estimatedDone != null)
            _infoRowHighlight(
              'Estimasi Selesai',
              FormatHelper.formatDate(tx.estimatedDone!),
            ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownCard(BuildContext context, dynamic tx) {
    final paymentProvider = context.watch<PaymentMethodProvider>();
    final paymentMethodName = _getPaymentMethodName(tx, paymentProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _costRow('Subtotal', tx.subtotal),
          if (tx.discount > 0) _discountRow('Diskon', tx.discount),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                FormatHelper.formatRupiah(tx.total),
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
                  tx.isPaid ? Icons.check_circle : Icons.pending_actions,
                  color: tx.isPaid ? AppColors.secondary : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tx.isPaid
                        ? paymentMethodName == null
                            ? 'Sudah Lunas'
                            : 'Sudah Lunas • $paymentMethodName'
                        : 'Belum Lunas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tx.isPaid ? AppColors.secondary : AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    dynamic tx,
    TransactionProvider provider,
  ) {
    String? nextStatus;
    String nextLabel = '';
    IconData nextIcon = Icons.play_circle_outline;

    switch (tx.status) {
      case 'antrian':
        nextStatus = 'proses';
        nextLabel = 'Proses Order';
        nextIcon = Icons.play_circle_outline;
        break;
      case 'proses':
        nextStatus = 'selesai';
        nextLabel = 'Selesai';
        nextIcon = Icons.check_circle_outline;
        break;
    }

    final showStatusButton = nextStatus != null && tx.status != 'batal';
    final showRecordPaymentButton = !tx.isPaid && tx.status != 'batal';

    return BottomActionBar(
      leftInfo: showStatusButton
          ? OutlinedButton.icon(
              icon: Icon(nextIcon),
              label: Text(nextLabel),
              onPressed: () async {
                try {
                  await provider.updateStatus(tx.id, nextStatus!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status order diubah ke $nextStatus'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengubah status: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            )
          : null,
      rightAction: showRecordPaymentButton
          ? GradientButton(
              label: 'Catat Bayar',
              icon: Icons.account_balance_wallet,
              onPressed: () => _showPaymentDialog(context, tx.id, provider),
            )
          : GradientButton(
              label: tx.isPaid ? 'Sudah Lunas' : 'Kembali',
              icon: tx.isPaid ? Icons.check : Icons.arrow_back,
              isDisabled: tx.isPaid,
              onPressed: tx.isPaid ? null : () => context.pop(),
            ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    String txId,
    TransactionProvider txProvider,
  ) {
    final paymentProvider = context.read<PaymentMethodProvider>();
    final methods = paymentProvider.activeMethods;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catat Metode Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih metode pembayaran yang sudah diterima di luar aplikasi. Aplikasi hanya mencatat pembayaran, bukan memproses transaksi digital.',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              if (methods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada metode pembayaran aktif',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...methods.map(
                  (m) => ListTile(
                    leading: Icon(
                      m.type == 'cash'
                          ? Icons.payments
                          : m.type == 'transfer'
                              ? Icons.account_balance
                              : m.type == 'ewallet'
                                  ? Icons.phone_android
                                  : Icons.qr_code,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      m.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: m.accountNumber != null
                        ? Text(m.accountNumber!)
                        : const Text('Pembayaran dicatat manual'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await txProvider.markAsPaid(txId, m.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Pembayaran dicatat: ${m.name}',
                              ),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mencatat pembayaran: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  String? _getPaymentMethodName(dynamic tx, PaymentMethodProvider paymentProvider) {
    if (!tx.isPaid || tx.paymentMethodId == null) return null;

    try {
      final method = paymentProvider.methods.firstWhere(
        (m) => m.id == tx.paymentMethodId,
      );
      return method.name;
    } catch (_) {
      return 'Metode pembayaran tercatat';
    }
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
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
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
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            FormatHelper.formatRupiah(amount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.onTertiaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '- ${FormatHelper.formatRupiah(amount)}',
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

  Future<void> _printReceipt(BuildContext context, dynamic tx) async {
    final printerProvider = context.read<BluetoothPrinterProvider>();
    final storeProvider = context.read<StoreSettingsProvider>();
    final paymentProvider = context.read<PaymentMethodProvider>();

    if (storeProvider.settings.address.isEmpty &&
        storeProvider.settings.notes.isEmpty) {
      await storeProvider.fetchSettings();
    }

    final paymentMethodName = _getPaymentMethodName(tx, paymentProvider);

    if (printerProvider.isConnected) {
      final success = await printerProvider.printTransaction(
        tx,
        storeProvider.settings,
        paymentMethodName: paymentMethodName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Struk sedang dicetak!' : 'Gagal mencetak struk!',
            ),
            backgroundColor: success ? AppColors.secondary : AppColors.error,
          ),
        );
      }
    } else {
      if (context.mounted) {
        _showPrinterSelectionSheet(
          context,
          tx,
          storeProvider.settings,
          paymentMethodName,
        );
      }
    }
  }

  void _showPrinterSelectionSheet(
    BuildContext context,
    dynamic tx,
    dynamic storeSettings,
    String? paymentMethodName,
  ) {
    context.read<BluetoothPrinterProvider>().scanDevices();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<BluetoothPrinterProvider>(
          builder: (context, printerProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Printer Bluetooth',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      if (printerProvider.isScanning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                          ),
                          onPressed: () => printerProvider.scanDevices(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Printer belum terhubung. Silakan hubungkan ke salah satu perangkat di bawah ini untuk langsung mencetak struk.',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (printerProvider.devices.isEmpty &&
                      !printerProvider.isScanning)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bluetooth_disabled,
                              color: Colors.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak ada printer Bluetooth ditemukan.',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              'Pastikan printer aktif dan sudah dipasangkan (paired) di HP.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => printerProvider.scanDevices(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Pindai Ulang',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (printerProvider.devices.isEmpty &&
                      printerProvider.isScanning)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: printerProvider.devices.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final device = printerProvider.devices[index];
                          final isConnecting = printerProvider.isConnecting &&
                              printerProvider.connectedMacAddress ==
                                  device.macAdress;

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.print,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                device.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                device.macAdress,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: isConnecting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: () async {
                                        final success =
                                            await printerProvider.connect(
                                          device.macAdress,
                                          device.name,
                                        );

                                        if (success) {
                                          await printerProvider.printTransaction(
                                            tx,
                                            storeSettings,
                                            paymentMethodName:
                                                paymentMethodName,
                                          );

                                          if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(ctx)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Printer terhubung & struk sedang dicetak!',
                                                ),
                                                backgroundColor:
                                                    AppColors.secondary,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(ctx)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Koneksi printer gagal!',
                                                ),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Hubungkan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
