import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/format_helpers.dart';
import '../models/store_settings.dart';


class BluetoothPrinterProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isScanning = false;
  List<BluetoothInfo> _devices = [];
  String? _connectedDeviceName;
  String? _connectedMacAddress;
  int _paperSizeMm = 58; // Default 58mm

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isScanning => _isScanning;
  List<BluetoothInfo> get devices => _devices;
  String? get connectedDeviceName => _connectedDeviceName;
  String? get connectedMacAddress => _connectedMacAddress;
  int get paperSizeMm => _paperSizeMm;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _paperSizeMm = prefs.getInt('printer_paper_size') ?? 58;
      _connectedMacAddress = prefs.getString('printer_mac_address');
      _connectedDeviceName = prefs.getString('printer_device_name');
      
      if (_connectedMacAddress != null) {
        final bool bluetoothActive = await PrintBluetoothThermal.bluetoothEnabled;
        if (bluetoothActive) {
          _isConnecting = true;
          notifyListeners();
          
          final bool connectResult = await PrintBluetoothThermal.connect(
            macPrinterAddress: _connectedMacAddress!,
          );
          
          _isConnected = connectResult;
          _isConnecting = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading printer settings: $e');
    }
    notifyListeners();
  }

  Future<void> setPaperSize(int size) async {
    _paperSizeMm = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('printer_paper_size', size);
    notifyListeners();
  }

  Future<bool> checkAndRequestPermissions() async {
    // Pada Android 12+, dibutuhkan BLUETOOTH_SCAN dan BLUETOOTH_CONNECT.
    // Pada versi lama, BLUETOOTH dan location bisa dibutuhkan.
    bool isGranted = await PrintBluetoothThermal.isPermissionBluetoothGranted;
    if (isGranted) return true;

    final Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses[Permission.bluetoothConnect]?.isGranted == true &&
           statuses[Permission.bluetoothScan]?.isGranted == true;
  }

  Future<void> scanDevices() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      debugPrint("Bluetooth permissions not granted.");
      return;
    }

    _isScanning = true;
    _devices = [];
    notifyListeners();

    try {
      final isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothOn) {
        debugPrint("Bluetooth is disabled.");
        _isScanning = false;
        notifyListeners();
        return;
      }

      _devices = await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      debugPrint("Error scanning bluetooth devices: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> connect(String macAddress, String deviceName) async {
    _isConnecting = true;
    notifyListeners();

    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );

      if (result) {
        _isConnected = true;
        _connectedMacAddress = macAddress;
        _connectedDeviceName = deviceName;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('printer_mac_address', macAddress);
        await prefs.setString('printer_device_name', deviceName);
      } else {
        _isConnected = false;
      }
      return result;
    } catch (e) {
      debugPrint("Error connecting to printer: $e");
      _isConnected = false;
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      _isConnected = false;
      _connectedMacAddress = null;
      _connectedDeviceName = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('printer_mac_address');
      await prefs.remove('printer_device_name');
    } catch (e) {
      debugPrint("Error disconnecting: $e");
    }
    notifyListeners();
  }

  Future<bool> printTestPage() async {
    if (!_isConnected) return false;

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _paperSizeMm == 80 ? PaperSize.mm80 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      final int charWidth = _paperSizeMm == 80 ? 48 : 32;

      List<int> bytes = [];

      bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));
      bytes += generator.text("UJI COBA CETAK");
      bytes += generator.text("LaundryKu");
      
      bytes += generator.setStyles(const PosStyles(align: PosAlign.center));
      bytes += generator.text("Printer Thermal Bluetooth");
      bytes += generator.text("Kertas: ${_paperSizeMm}mm");
      bytes += generator.text("-" * charWidth);
      bytes += generator.text("Status: KONEKSI BERHASIL!");
      bytes += generator.text(FormatHelper.formatDate(DateTime.now()));
      bytes += generator.feed(3);
      bytes += generator.cut();

      final bool success = await PrintBluetoothThermal.writeBytes(bytes);
      return success;
    } catch (e) {
      debugPrint("Error printing test page: $e");
      return false;
    }
  }

  Future<bool> printTransaction(Transaction tx, StoreSettings storeSettings, {String? paymentMethodName}) async {
    if (!_isConnected) {
      if (_connectedMacAddress != null) {
        final reconnected = await connect(_connectedMacAddress!, _connectedDeviceName ?? 'Printer');
        if (!reconnected) return false;
      } else {
        return false;
      }
    }

    try {
      final profile = await CapabilityProfile.load();
      final paperSize = _paperSizeMm == 80 ? PaperSize.mm80 : PaperSize.mm58;
      final generator = Generator(paperSize, profile);
      final int charWidth = _paperSizeMm == 80 ? 48 : 32;

      // ──────────────────────────────────────────────
      // Helper: baris label-nilai rata kiri & kanan
      // ──────────────────────────────────────────────
      String rowLR(String left, String right) {
        int space = charWidth - left.length - right.length;
        if (space < 1) space = 1;
        return left + (' ' * space) + right;
      }

      // Wrap teks panjang sesuai lebar kertas
      List<String> wrapText(String text) {
        if (text.length <= charWidth) return [text];
        final words = text.split(' ');
        final lines = <String>[];
        var line = '';
        for (final word in words) {
          if ((line.isEmpty ? word : '$line $word').length <= charWidth) {
            line = line.isEmpty ? word : '$line $word';
          } else {
            if (line.isNotEmpty) lines.add(line);
            line = word;
          }
        }
        if (line.isNotEmpty) lines.add(line);
        return lines;
      }

      final String dash = '-' * charWidth;
      final dateFormatter = DateFormat('dd/MM/yyyy - HH:mm');

      List<int> bytes = [];

      // ══════════════════════════════════════════════
      // HEADER TOKO
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));
      bytes += generator.text(storeSettings.name);

      bytes += generator.setStyles(const PosStyles(align: PosAlign.center));
      if (storeSettings.address.isNotEmpty) {
        for (final line in wrapText(storeSettings.address)) {
          bytes += generator.text(line);
        }
      }
      bytes += generator.text(dash);

      // ══════════════════════════════════════════════
      // NO NOTA  (label kiri, nilai kanan)
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(align: PosAlign.left));
      bytes += generator.text(rowLR('No Nota', tx.invoiceNumber));
      bytes += generator.text(dash);

      // ══════════════════════════════════════════════
      // NAMA PELANGGAN (besar, bold, center)
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));
      bytes += generator.text(tx.customer.name);

      // ══════════════════════════════════════════════
      // DETAIL TRANSAKSI
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(align: PosAlign.left));
      bytes += generator.text(dash);
      bytes += generator.text(
        rowLR('Tgl Masuk', dateFormatter.format(tx.createdAt)),
      );
      if (tx.estimatedDone != null) {
        bytes += generator.text(
          rowLR('Est Selesai', dateFormatter.format(tx.estimatedDone!)),
        );
      }
      bytes += generator.text(rowLR('No. HP', tx.customer.phone));
      bytes += generator.text(dash);

      // ══════════════════════════════════════════════
      // RINCIAN LAYANAN
      // ══════════════════════════════════════════════
      for (final item in tx.items) {
        // Nama layanan
        bytes += generator.setStyles(const PosStyles(align: PosAlign.left));
        bytes += generator.text(item.service.name);

        // Qty × harga → subtotal (rata kanan)
        final String qty = item.quantity % 1 == 0
            ? item.quantity.toInt().toString()
            : item.quantity.toStringAsFixed(1);
        final String unit = item.service.unit;
        final String price = FormatHelper.formatRupiah(item.service.price);
        final String subtotal = FormatHelper.formatRupiah(item.subtotal);
        final String qtyLine = '  $qty $unit x $price';
        bytes += generator.text(rowLR(qtyLine, subtotal));
      }
      bytes += generator.text(dash);

      // ══════════════════════════════════════════════
      // RINGKASAN PEMBAYARAN
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(align: PosAlign.left));

      // Subtotal (tampilkan hanya jika ada diskon)
      if (tx.discount > 0) {
        bytes += generator.text(
          rowLR('Subtotal', FormatHelper.formatRupiah(tx.subtotal)),
        );
        bytes += generator.text(
          rowLR('Diskon', '- ${FormatHelper.formatRupiah(tx.discount)}'),
        );
      }

      // Status bayar
      final String statusBayar = tx.isPaid ? 'Lunas' : 'Belum Bayar';
      bytes += generator.text(rowLR('Status', statusBayar));

      // Metode bayar
      if (tx.isPaid && paymentMethodName != null) {
        bytes += generator.text(rowLR('Metode Bayar', paymentMethodName));
      }

      // Total (bold)
      bytes += generator.setStyles(const PosStyles(bold: true));
      bytes += generator.text(rowLR('Total', FormatHelper.formatRupiah(tx.total)));
      bytes += generator.text(dash);

      // ══════════════════════════════════════════════
      // FOOTER
      // ══════════════════════════════════════════════
      bytes += generator.setStyles(const PosStyles(align: PosAlign.center));

      // Catatan toko (notes)
      if (storeSettings.notes.isNotEmpty) {
        for (final line in wrapText(storeSettings.notes)) {
          bytes += generator.text(line);
        }
      }

      // Pesan penutup
      final String footerMsg = storeSettings.footer.isNotEmpty
          ? storeSettings.footer
          : 'Terima kasih telah mempercayakan\ncucian Anda kepada kami';
      for (final line in footerMsg.split('\n')) {
        for (final wrapped in wrapText(line)) {
          bytes += generator.text(wrapped);
        }
      }

      bytes += generator.feed(3);
      bytes += generator.cut();

      final bool success = await PrintBluetoothThermal.writeBytes(bytes);
      return success;
    } catch (e) {
      debugPrint("Error printing transaction: $e");
      return false;
    }
  }
}
