import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/store_settings_provider.dart';
import '../../providers/bluetooth_printer_provider.dart';
import '../../models/store_settings.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();
  bool _isSaving = false;

  int _selectedTab = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StoreSettingsProvider>();
      await provider.fetchSettings();
      if (mounted) {
        final s = provider.settings;
        _nameCtrl.text = s.name;
        _addressCtrl.text = s.address;
        _notesCtrl.text = s.notes;
        _footerCtrl.text = s.footer;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await context.read<StoreSettingsProvider>().saveSettings(
            StoreSettings(
              name: _nameCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
              notes: _notesCtrl.text.trim(),
              footer: _footerCtrl.text.trim(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
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
                      Positioned(
                        top: 30,
                        right: 20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
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
                                  'Manajemen Outlet',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pengaturan Toko',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'Kelola informasi toko Anda',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Card (overlap)
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
                    child: Consumer<StoreSettingsProvider>(
                      builder: (ctx, provider, _) {
                        if (provider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 112,
                                    height: 112,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: AppShadows.cardFocused,
                                    ),
                                    child: const Icon(
                                        Icons.local_laundry_service,
                                        color: Colors.white,
                                        size: 56),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(10),
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

                            _label('Nama Toko'),
                            TextField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                prefixIcon:
                                    Icon(Icons.store, color: AppColors.primary),
                                hintText: 'Nama toko',
                              ),
                            ),
                            const SizedBox(height: 16),

                            _label('Alamat'),
                            TextField(
                              controller: _addressCtrl,
                              minLines: 3,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 42),
                                  child: Icon(Icons.location_on,
                                      color: AppColors.primary),
                                ),
                                hintText: 'Alamat lengkap toko',
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
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _label('Catatan Struk'),
                                      TextField(
                                        controller: _notesCtrl,
                                        minLines: 2,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Catatan atas struk',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor:
                                              AppColors.surfaceContainerLow,
                                          contentPadding:
                                              const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _label('Pesan Bawah'),
                                      TextField(
                                        controller: _footerCtrl,
                                        minLines: 2,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          hintText: 'Pesan di bawah struk',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 2),
                                          ),
                                          filled: true,
                                          fillColor:
                                              AppColors.surfaceContainerLow,
                                          contentPadding:
                                              const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Save button
                            GestureDetector(
                              onTap: _isSaving ? null : _saveSettings,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: _isSaving
                                      ? null
                                      : AppColors.primaryGradient,
                                  color: _isSaving
                                      ? AppColors.surfaceContainerHigh
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  boxShadow: _isSaving
                                      ? null
                                      : AppShadows.primaryButton,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isSaving)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    else
                                      const Icon(Icons.save,
                                          color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isSaving
                                          ? 'Menyimpan...'
                                          : 'Simpan Perubahan',
                                      style: TextStyle(
                                        color: _isSaving
                                            ? AppColors.onSurfaceVariant
                                            : Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                // Printer Settings Card
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                      boxShadow: AppShadows.cardLight,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Consumer<BluetoothPrinterProvider>(
                      builder: (context, printerProvider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.print_rounded, color: AppColors.primary, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'Printer Struk Bluetooth',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            // Status Koneksi
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: printerProvider.isConnected 
                                    ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                                    : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // Indicator dot
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: printerProvider.isConnected ? AppColors.secondary : Colors.grey,
                                      shape: BoxShape.circle,
                                      boxShadow: printerProvider.isConnected 
                                          ? [
                                              BoxShadow(
                                                color: AppColors.secondary.withValues(alpha: 0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          printerProvider.isConnected ? 'Terhubung' : 'Terputus',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: printerProvider.isConnected ? AppColors.secondary : AppColors.onSurfaceVariant,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (printerProvider.isConnected && printerProvider.connectedDeviceName != null)
                                          Text(
                                            '${printerProvider.connectedDeviceName} (${printerProvider.connectedMacAddress})',
                                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                          )
                                        else
                                          const Text(
                                            'Hubungkan printer thermal kasir Anda',
                                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (printerProvider.isConnected)
                                    IconButton(
                                      icon: const Icon(Icons.link_off, color: AppColors.error),
                                      tooltip: 'Putuskan',
                                      onPressed: () => printerProvider.disconnect(),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Ukuran Kertas
                            const Text(
                              'Ukuran Kertas Struk',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => printerProvider.setPaperSize(58),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: printerProvider.paperSizeMm == 58 
                                            ? AppColors.primaryContainer.withValues(alpha: 0.2)
                                            : AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: printerProvider.paperSizeMm == 58 
                                              ? AppColors.primary 
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '58 mm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: printerProvider.paperSizeMm == 58 
                                                ? AppColors.primary 
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => printerProvider.setPaperSize(80),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: printerProvider.paperSizeMm == 80 
                                            ? AppColors.primaryContainer.withValues(alpha: 0.2)
                                            : AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: printerProvider.paperSizeMm == 80 
                                              ? AppColors.primary 
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '80 mm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: printerProvider.paperSizeMm == 80 
                                                ? AppColors.primary 
                                                : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Daftar Device / Scanning
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Printer Tersedia',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                if (printerProvider.isScanning)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () => printerProvider.scanDevices(),
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Pindai ulang', style: TextStyle(fontSize: 13)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            if (printerProvider.devices.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.bluetooth_disabled_rounded, color: Colors.grey, size: 36),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tidak ada printer berpasangan ditemukan',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () => printerProvider.scanDevices(),
                                      child: const Text('Mulai Pindai'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: printerProvider.devices.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final device = printerProvider.devices[index];
                                  final bool isCurrent = printerProvider.connectedMacAddress == device.macAdress;
                                  
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isCurrent 
                                          ? AppColors.primaryContainer.withValues(alpha: 0.1) 
                                          : AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.print_rounded, color: AppColors.primary),
                                      title: Text(
                                        device.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        device.macAdress,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      trailing: printerProvider.isConnecting && isCurrent
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : isCurrent && printerProvider.isConnected
                                              ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                                              : TextButton(
                                                  onPressed: () async {
                                                    final success = await printerProvider.connect(device.macAdress, device.name);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            success 
                                                                ? 'Koneksi ke ${device.name} berhasil!' 
                                                                : 'Koneksi ke ${device.name} gagal!',
                                                          ),
                                                          backgroundColor: success ? AppColors.secondary : AppColors.error,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Hubungkan', style: TextStyle(fontWeight: FontWeight.w700)),
                                                ),
                                    ),
                                  );
                                },
                              ),
                            
                            if (printerProvider.isConnected) ...[
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () async {
                                  final success = await printerProvider.printTestPage();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success 
                                              ? 'Uji coba cetak berhasil dikirim!' 
                                              : 'Gagal mencetak halaman uji coba!',
                                        ),
                                        backgroundColor: success ? AppColors.secondary : AppColors.error,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(color: AppColors.primary),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Cetak Struk Uji Coba',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab == -1 ? 0 : _selectedTab,
        onTap: (i) {
          setState(() => _selectedTab = i);
          if (i == 0) context.go('/');
          if (i == 1) context.go('/account');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Akun'),
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
}
