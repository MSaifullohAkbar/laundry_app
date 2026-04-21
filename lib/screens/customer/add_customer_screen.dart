import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';
import '../../widgets/common/gradient_app_bar.dart';
import '../../widgets/common/bottom_action_bar.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _selectedGender = 'Laki-laki';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<CustomerProvider>();
    final now = DateTime.now();
    prov.addCustomer(Customer(
      id: 'c_${now.millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      gender: _selectedGender,
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pelanggan berhasil ditambahkan!'),
        backgroundColor: AppColors.secondary,
      ),
    );
    context.go('/customers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GradientAppBar(
        title: 'Tambah Pelanggan',
        onBack: () => context.go('/customers'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryFixed,
                          child: const Icon(Icons.person,
                              size: 52, color: AppColors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
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

                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius:
                          BorderRadius.circular(AppRadius.cardLarge),
                      boxShadow: AppShadows.cardFocused,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nama Lengkap'),
                        TextFormField(
                          controller: _nameCtrl,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan nama lengkap',
                            prefixIcon:
                                Icon(Icons.person, color: AppColors.primary),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _label('Nomor Telepon'),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '08xxxxxxxxxx',
                            prefixIcon:
                                Icon(Icons.phone, color: AppColors.primary),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Nomor telepon tidak boleh kosong'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _label('Email (Opsional)'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'email@contoh.com',
                            prefixIcon:
                                Icon(Icons.email, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _label('Jenis Kelamin'),
                        const SizedBox(height: 8),
                        _buildGenderToggle(),
                        const SizedBox(height: 16),
                        _label('Alamat'),
                        TextFormField(
                          controller: _addressCtrl,
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Masukkan alamat lengkap',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              rightAction: GradientButton(
                label: 'Simpan Pelanggan',
                icon: Icons.save,
                isFullWidth: true,
                onPressed: _save,
              ),
            ),
          ),
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

  Widget _buildGenderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: ['Laki-laki', 'Perempuan'].map((g) {
          final selected = _selectedGender == g;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: selected ? AppShadows.cardLight : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      g == 'Laki-laki' ? Icons.male : Icons.female,
                      size: 18,
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      g,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
