import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';

class AddServiceTypeScreen extends StatefulWidget {
  const AddServiceTypeScreen({super.key});

  @override
  State<AddServiceTypeScreen> createState() => _AddServiceTypeScreenState();
}

class _AddServiceTypeScreenState extends State<AddServiceTypeScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedUnit = 'kg';
  String _selectedDurationUnit = 'Jam';

  final List<String> _units = ['kg', 'pcs', 'item'];
  final List<String> _durationUnits = ['Jam', 'Hari'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jenis layanan berhasil ditambahkan!'),
        backgroundColor: AppColors.secondary,
      ),
    );
    context.go('/services/add');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image upload card ──────────────────────────────────
                    _buildImageCard(),
                    const SizedBox(height: 20),

                    // ── Nama Jenis ─────────────────────────────────────────
                    _fieldLabel('Nama Jenis'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: 'Contoh: Cuci Komplit, Setrika Saja',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nama jenis tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Satuan ─────────────────────────────────────────────
                    _fieldLabel('Satuan'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedUnit,
                      items: _units,
                      displayLabels: const {'kg': 'kg (Kilogram)', 'pcs': 'pcs (Satuan)', 'item': 'item'},
                      hint: 'Pilih Satuan',
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                    const SizedBox(height: 20),

                    // ── Harga ──────────────────────────────────────────────
                    _fieldLabel('Harga'),
                    const SizedBox(height: 8),
                    _buildPriceField(),
                    const SizedBox(height: 20),

                    // ── Lama Pengerjaan ────────────────────────────────────
                    _fieldLabel('Lama Pengerjaan'),
                    const SizedBox(height: 8),
                    _buildDurationRow(),
                    const SizedBox(height: 20),

                    // ── Keterangan ─────────────────────────────────────────
                    _fieldLabel('Keterangan (Opsional)'),
                    const SizedBox(height: 8),
                    _buildTextArea(),
                    const SizedBox(height: 36),

                    // ── Save button ────────────────────────────────────────
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3A5C), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => context.go('/services/add'),
              ),
              const Expanded(
                child: Text(
                  'Tambah Jenis Layanan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image upload card ────────────────────────────────────────────────────
  Widget _buildImageCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Dashed preview box
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    color: AppColors.onSurfaceVariant, size: 28),
                const SizedBox(height: 4),
                const Text(
                  'PREVIEW',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info + pick button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gambar Layanan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Format: JPG, PNG. Maks 2MB.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Image picker action (placeholder)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur pilih gambar akan segera hadir'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A5C),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Pilih Gambar',
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
          ),
        ],
      ),
    );
  }

  // ── Field label ──────────────────────────────────────────────────────────
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.onSurface,
      ),
    );
  }

  // ── Single-line text field ───────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      decoration: _inputDecoration(hint),
    );
  }

  // ── Dropdown ─────────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String hint,
    Map<String, String>? displayLabels,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: _inputDecoration(hint),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.onSurfaceVariant),
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.onSurface,
        fontFamily: 'PlusJakartaSans',
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      items: items
          .map((u) => DropdownMenuItem(
                value: u,
                child: Text(displayLabels?[u] ?? u),
              ))
          .toList(),
    );
  }

  // ── Price field ──────────────────────────────────────────────────────────
  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Harga tidak boleh kosong' : null,
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        prefixText: 'Rp  ',
        prefixStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
        hintText: '0',
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // ── Duration row (number + unit dropdown) ────────────────────────────────
  Widget _buildDurationRow() {
    return Row(
      children: [
        // Number input
        Expanded(
          child: TextFormField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
            decoration: _inputDecoration('Angka'),
          ),
        ),
        const SizedBox(width: 12),
        // Unit dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedDurationUnit,
            onChanged: (v) => setState(() => _selectedDurationUnit = v!),
            decoration: _inputDecoration(''),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.onSurfaceVariant),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurface,
              fontFamily: 'PlusJakartaSans',
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: _durationUnits
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Multiline textarea ───────────────────────────────────────────────────
  Widget _buildTextArea() {
    return TextFormField(
      controller: _descCtrl,
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 5,
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Tambahkan detail layanan di sini...',
        hintStyle: TextStyle(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ── Save button ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A5C),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3A5C).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Simpan Layanan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared InputDecoration ───────────────────────────────────────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
