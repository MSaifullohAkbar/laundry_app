import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ExportService {
  /// Exports a list of transactions to an .xlsx file.
  /// Returns true if successful, false if cancelled or failed.
  static Future<bool> exportTransactionsToExcel({
    required BuildContext context,
    required List<Transaction> transactions,
    required String periodLabel,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Transaksi'];
      excel.setDefaultSheet('Laporan Transaksi');

      // ── Title rows ────────────────────────────────────────────────────────
      sheet.merge(
          CellIndex.indexByString('A1'), CellIndex.indexByString('G1'));
      final titleCell = sheet.cell(CellIndex.indexByString('A1'));
      titleCell.value =
          TextCellValue('LAPORAN TRANSAKSI - LaundryKu Kasir');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Center,
      );

      sheet.merge(
          CellIndex.indexByString('A2'), CellIndex.indexByString('G2'));
      final periodCell = sheet.cell(CellIndex.indexByString('A2'));
      periodCell.value = TextCellValue('Periode: $periodLabel');
      periodCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        italic: true,
      );

      sheet.merge(
          CellIndex.indexByString('A3'), CellIndex.indexByString('G3'));
      final generatedCell = sheet.cell(CellIndex.indexByString('A3'));
      generatedCell.value = TextCellValue(
        'Dibuat pada: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
      );
      generatedCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        fontColorHex: ExcelColor.fromHexString('#666666'),
      );

      // ── Column headers (row 5, index 4) ──────────────────────────────────
      const headers = [
        'No',
        'No. Invoice',
        'Tanggal',
        'Pelanggan',
        'Status',
        'Pembayaran',
        'Total (Rp)',
      ];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#006590'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
      }

      // ── Data rows ────────────────────────────────────────────────────────
      double grandTotal = 0;
      int completedCount = 0;

      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        final rowIndex = 5 + i;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = IntCellValue(i + 1);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(tx.invoiceNumber);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(
          DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tx.createdAt),
        );
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(tx.customer.name);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = TextCellValue(_statusLabel(tx.status));
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value =
            TextCellValue(tx.isPaid ? 'LUNAS' : 'BELUM LUNAS');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = DoubleCellValue(tx.total);

        // Zebra stripe background for odd rows
        if (i.isOdd) {
          for (int c = 0; c < 7; c++) {
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIndex)).cellStyle = CellStyle(
              backgroundColorHex: ExcelColor.fromHexString('#F6FAFF'),
            );
          }
        }

        if (tx.status == 'selesai') {
          grandTotal += tx.total;
          completedCount++;
        }
      }

      // ── Summary row ───────────────────────────────────────────────────────
      final summaryRowIdx = 5 + transactions.length + 1;
      sheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: summaryRowIdx),
        CellIndex.indexByColumnRow(
            columnIndex: 5, rowIndex: summaryRowIdx),
      );
      final summaryCell0 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIdx));
      summaryCell0.value = TextCellValue(
        'TOTAL OMZET (Transaksi Selesai: $completedCount)',
      );
      summaryCell0.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#E8F4FD'),
      );
      final summaryCell6 = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: summaryRowIdx));
      summaryCell6.value = DoubleCellValue(grandTotal);
      summaryCell6.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#E8F4FD'),
      );

      // ── Column widths ─────────────────────────────────────────────────────
      sheet.setColumnWidth(0, 6);
      sheet.setColumnWidth(1, 24);
      sheet.setColumnWidth(2, 22);
      sheet.setColumnWidth(3, 24);
      sheet.setColumnWidth(4, 14);
      sheet.setColumnWidth(5, 16);
      sheet.setColumnWidth(6, 18);

      // ── Encode to bytes ───────────────────────────────────────────────────
      final List<int>? rawBytes = excel.save();
      if (rawBytes == null) {
        throw Exception('Gagal menghasilkan file Excel');
      }
      final fileBytes = Uint8List.fromList(rawBytes);

      final defaultName =
          'Laporan_Transaksi_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';

      // file_picker v11: FilePicker.saveFile() — pass bytes so Android can
      // write directly without needing separate File I/O permissions.
      String? outputPath = await FilePicker.saveFile(
        dialogTitle: 'Simpan Laporan Excel',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: fileBytes,
      );

      if (outputPath == null) return false; // user cancelled

      // On desktop the path is returned but bytes are not yet written;
      // on Android/iOS bytes are written by the picker itself.
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        if (!outputPath.endsWith('.xlsx')) {
          outputPath = '$outputPath.xlsx';
        }
        await File(outputPath).writeAsBytes(fileBytes);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Berhasil disimpan ke $outputPath')),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Gagal mengekspor: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFBA1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return false;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'antrian':
        return 'Antrian';
      case 'proses':
        return 'Proses';
      case 'selesai':
        return 'Selesai';
      case 'terlambat':
        return 'Terlambat';
      case 'batal':
        return 'Batal';
      default:
        return status;
    }
  }
}
