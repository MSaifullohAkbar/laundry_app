import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/parfum.dart';
import '../../providers/parfum_provider.dart';



class AddParfumScreen extends StatefulWidget {
  const AddParfumScreen({super.key});

  @override
  State<AddParfumScreen> createState() => _AddParfumScreenState();
}

class _AddParfumScreenState extends State<AddParfumScreen> {
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0.0');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final prov = context.read<ParfumProvider>();
    final now = DateTime.now();

    try {
      await prov.addParfum(Parfum(
        id: 'p_${now.millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        stockLiters: double.tryParse(_stockCtrl.text.trim()) ?? 0.0,
      ));

      if (mounted) {
        Navigator.pop(context); // Pop the loader

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parfum berhasil ditambahkan!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/parfum');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop the loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan parfum: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // AppBar
          _buildAppBar(context, 'Tambah Parfum'),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero banner
                    _buildHeroBanner(
                      title: 'Tambah Parfum Baru',
                      subtitle:
                          'Lengkapi data stok parfum laundry Anda di bawah ini.',
                    ),
                    const SizedBox(height: 24),

                    // Form card
                    _buildFormCard(
                      children: [
                        _fieldLabel('Nama Parfum'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Contoh: Ocean Fresh Premium',
                          prefixIcon: Icons.label_outline,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nama parfum tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel('Stok Awal (Liter)'),
                        const SizedBox(height: 8),
                        _buildStockField(controller: _stockCtrl),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Info banner
                    _buildInfoBanner(),
                    const SizedBox(height: 32),

                    // Save button
                    _buildSaveButton(label: 'Simpan Parfum', onTap: _save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════════
// EDIT PARFUM SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class EditParfumScreen extends StatefulWidget {
  final String parfumId;
  const EditParfumScreen({super.key, required this.parfumId});

  @override
  State<EditParfumScreen> createState() => _EditParfumScreenState();
}

class _EditParfumScreenState extends State<EditParfumScreen> {
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final prov = context.read<ParfumProvider>();
      final parfum = prov.getParfumById(widget.parfumId);
      if (parfum != null) {
        _nameCtrl.text = parfum.name;
        _stockCtrl.text = parfum.stockLiters.toStringAsFixed(1);
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final prov = context.read<ParfumProvider>();
    try {
      await prov.updateParfum(
        widget.parfumId,
        name: _nameCtrl.text.trim(),
        stockLiters: double.tryParse(_stockCtrl.text.trim()) ?? 0.0,
      );

      if (mounted) {
        Navigator.pop(context); // Pop the loader

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parfum berhasil diperbarui!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/parfum');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop the loader

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui parfum: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _buildAppBar(context, 'Edit Parfum'),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(
                      title: 'Edit Data Parfum',
                      subtitle:
                          'Perbarui informasi parfum laundry Anda di bawah ini.',
                    ),
                    const SizedBox(height: 24),

                    _buildFormCard(
                      children: [
                        _fieldLabel('Nama Parfum'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Contoh: Ocean Fresh Premium',
                          prefixIcon: Icons.label_outline,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nama parfum tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel('Stok (Liter)'),
                        const SizedBox(height: 8),
                        _buildStockField(controller: _stockCtrl),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildInfoBanner(),
                    const SizedBox(height: 32),

                    _buildSaveButton(
                        label: 'Simpan Perubahan', onTap: _save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS (used by both screens)
// ═══════════════════════════════════════════════════════════════════════════════

Widget _buildAppBar(BuildContext context, String title) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
    ),
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.onSurface, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/parfum');
                }
              },
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurface,
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

Widget _buildHeroBanner({
  required String title,
  required String subtitle,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.primaryButton,
    ),
    child: Stack(
      children: [
        // Decorative circles
        Positioned(
          top: -10,
          right: -10,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -5,
          right: 20,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFormCard({required List<Widget> children}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: AppShadows.cardLight,
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

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

Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData prefixIcon,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
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
    ),
  );
}

Widget _buildStockField({required TextEditingController controller}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    ],
    style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
    decoration: InputDecoration(
      prefixIcon:
          const Icon(Icons.water_drop, color: AppColors.onSurfaceVariant, size: 20),
      suffixText: 'LITER',
      suffixStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
      hintText: '0.0',
      hintStyle: TextStyle(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
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
    ),
  );
}

Widget _buildInfoBanner() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryFixed,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Informasi stok akan digunakan untuk menghitung kebutuhan operasional harian Anda secara otomatis.',
            style: TextStyle(
              color: AppColors.onSurface.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSaveButton({
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.save, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}
