import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/payment_method.dart';
import '../../providers/payment_method_provider.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _nameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  String _selectedType = 'cash';

  final List<Map<String, dynamic>> _types = [
    {'value': 'cash', 'label': 'Tunai', 'icon': Icons.payments},
    {'value': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'ewallet', 'label': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'value': 'qris', 'label': 'QRIS', 'icon': Icons.qr_code_2},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama metode bayar tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final method = PaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      accountNumber: _accountNumberCtrl.text.trim().isEmpty
          ? null
          : _accountNumberCtrl.text.trim(),
      accountName: _accountNameCtrl.text.trim().isEmpty
          ? null
          : _accountNameCtrl.text.trim(),
    );

    context.read<PaymentMethodProvider>().addMethod(method);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${method.name}" berhasil ditambahkan'),
        backgroundColor: AppColors.secondary,
      ),
    );

    context.go('/payment-methods');
  }

  @override
  Widget build(BuildContext context) {
    final needsAccount = _selectedType != 'cash';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => context.go('/payment-methods'),
        ),
        title: const Text(
          'LaundryKu Kasir',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero header
            Container(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                            'Pembayaran',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tambah Metode Bayar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Tambahkan metode pembayaran baru',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form card
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
                    // Type selector
                    const Text(
                      'Jenis Metode',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _types.map((t) {
                        final isSelected = _selectedType == t['value'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = t['value']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryFixed
                                  : AppColors.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  t['icon'] as IconData,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  t['label'] as String,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.onSurface,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Name field
                    _label('Nama Metode Bayar'),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.label_outline,
                            color: AppColors.primary),
                        hintText: 'Contoh: BCA, GoPay, Tunai',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account fields (shown for non-cash types)
                    if (needsAccount) ...[
                      _label('Nomor Rekening / Akun'),
                      TextField(
                        controller: _accountNumberCtrl,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.numbers,
                              color: AppColors.primary),
                          hintText: 'Contoh: 123-456-7890',
                        ),
                      ),
                      const SizedBox(height: 16),

                      _label('Nama Pemilik Akun'),
                      TextField(
                        controller: _accountNameCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.primary),
                          hintText: 'Contoh: LaundryKu',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 12),

                    // Save button
                    GestureDetector(
                      onTap: _save,
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
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Simpan Metode Bayar',
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
          ],
        ),
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
