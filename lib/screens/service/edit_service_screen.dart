import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/service.dart';
import '../../providers/service_provider.dart';
import '../../widgets/common/bottom_action_bar.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;
  const EditServiceScreen({super.key, required this.serviceId});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'kiloan';
  String _selectedUnit = 'kg';
  String _selectedDurationUnit = 'Jam';
  bool _includeWash = true;
  bool _includeDry = false;
  bool _includeIron = false;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final prov = context.read<ServiceProvider>();
      final service = prov.services.firstWhere((s) => s.id == widget.serviceId);
      _nameCtrl.text = service.name;
      _priceCtrl.text = service.price.toInt().toString();
      if (service.durationHours != null) {
        if (service.durationHours! % 24 == 0) {
          _selectedDurationUnit = 'Hari';
          _durationCtrl.text = (service.durationHours! ~/ 24).toString();
        } else {
          _selectedDurationUnit = 'Jam';
          _durationCtrl.text = service.durationHours.toString();
        }
      }
      _descCtrl.text = service.description ?? '';
      _selectedCategory = service.category;
      _selectedUnit = service.unit;
      _includeWash = service.includeWash;
      _includeDry = service.includeDry;
      _includeIron = service.includeIron;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final durationValue = int.tryParse(_durationCtrl.text.trim());
    int? durationHours;
    if (durationValue != null) {
      durationHours =
          _selectedDurationUnit == 'Hari' ? durationValue * 24 : durationValue;
    }

    final updatedService = ServiceType(
      id: widget.serviceId,
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      unit: _selectedUnit,
      includeWash: _includeWash,
      includeDry: _includeDry,
      includeIron: _includeIron,
      durationHours: durationHours,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );

    setState(() => _isLoading = true);
    try {
      await context.read<ServiceProvider>().updateService(widget.serviceId, updatedService);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan berhasil diperbarui!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.go('/services');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => context.go('/services'),
        ),
        title: const Text(
          'LaundryKu Kasir',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Layanan',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Info Card
                  _buildCard(
                    title: 'Informasi Dasar',
                    icon: Icons.info_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Nama Layanan'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Cuci Kiloan Reguler',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nama layanan tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Kategori'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(hintText: 'Pilih Kategori'),
                          items: const [
                            DropdownMenuItem(value: 'kiloan', child: Text('Kiloan')),
                            DropdownMenuItem(value: 'satuan', child: Text('Satuan')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedCategory = v;
                              _selectedUnit = v == 'kiloan' ? 'kg' : 'pcs';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing Card
                  _buildCard(
                    title: 'Harga & Satuan',
                    icon: Icons.attach_money,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Harga'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            prefixText: 'Rp  ',
                            hintText: '0',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Harga tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Satuan'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(hintText: 'Pilih Satuan'),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg (Kilogram)')),
                            DropdownMenuItem(value: 'pcs', child: Text('pcs (Satuan)')),
                            DropdownMenuItem(value: 'item', child: Text('item')),
                          ],
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Process Card
                  _buildCard(
                    title: 'Proses',
                    icon: Icons.settings,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih proses yang termasuk:',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _processToggle(
                                'Cuci', Icons.water_drop, _includeWash,
                                () => setState(
                                    () => _includeWash = !_includeWash)),
                            const SizedBox(width: 10),
                            _processToggle('Kering', Icons.air, _includeDry,
                                () => setState(
                                    () => _includeDry = !_includeDry)),
                            const SizedBox(width: 10),
                            _processToggle('Setrika', Icons.iron, _includeIron,
                                () => setState(
                                    () => _includeIron = !_includeIron)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration Card
                  _buildCard(
                    title: 'Lama Pengerjaan',
                    icon: Icons.timer_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(hintText: 'Angka'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDurationUnit,
                            decoration: const InputDecoration(hintText: ''),
                            items: const [
                              DropdownMenuItem(value: 'Jam', child: Text('Jam')),
                              DropdownMenuItem(value: 'Hari', child: Text('Hari')),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedDurationUnit = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  _buildCard(
                    title: 'Keterangan (Opsional)',
                    icon: Icons.notes,
                    child: TextFormField(
                      controller: _descCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan detail layanan di sini...',
                      ),
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
              leftInfo: GestureDetector(
                onTap: () => context.go('/services'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
              rightAction: GradientButton(
                label: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                icon: _isLoading ? Icons.hourglass_empty : Icons.save,
                onPressed: _isLoading ? null : _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppShadows.cardLight,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _processToggle(
      String label, IconData icon, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color:
                    selected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
