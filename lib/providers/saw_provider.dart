import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';

// Note: Ensure you have `excel` package installed if you want .xlsx support,
// but for simplicity we can support CSV first, or we can use the `excel` package.
import 'package:excel/excel.dart' as ex;

class SawCriterion {
  final String code;
  final String name;
  final String description;
  final double weight; // 0.0 – 1.0
  final bool isBenefit;

  const SawCriterion({
    required this.code,
    required this.name,
    required this.description,
    required this.weight,
    required this.isBenefit,
  });
}

class SawCandidate {
  final String id;
  final String name;
  final double c1; // Frekuensi Order (kali)
  final double c2; // Rata-rata Berat (kg)
  final double c3; // Komplain (kali)

  SawCandidate({
    required this.id,
    required this.name,
    required this.c1,
    required this.c2,
    required this.c3,
  });
}

class SawResult {
  final SawCandidate candidate;
  final Map<String, double> mappedScores; // After conversion to 1-5 scale
  final Map<String, double> normScores; // Normalised
  final double finalScore;
  final int rank;

  const SawResult({
    required this.candidate,
    required this.mappedScores,
    required this.normScores,
    required this.finalScore,
    required this.rank,
  });
}

class SawProvider extends ChangeNotifier {
  bool _isLoading = false;
  final List<SawCandidate> _candidates = [];
  List<SawResult> _results = [];
  String? _errorMessage;

  // Default weights sesuai dokumen: WC1=0.50, WC2=0.30, WC3=0.20
  double _weightC1 = 0.50;
  double _weightC2 = 0.30;
  double _weightC3 = 0.20;

  bool get isLoading => _isLoading;
  List<SawCandidate> get candidates => _candidates;
  List<SawResult> get results => _results;
  String? get errorMessage => _errorMessage;
  double get weightC1 => _weightC1;
  double get weightC2 => _weightC2;
  double get weightC3 => _weightC3;

  List<SawCriterion> get criteria => [
    SawCriterion(
      code: 'C1',
      name: 'Frekuensi Order',
      description: 'Jumlah order laundry (kali)',
      weight: _weightC1,
      isBenefit: true,
    ),
    SawCriterion(
      code: 'C2',
      name: 'Rata-rata Berat',
      description: 'Rata-rata berat cucian per order (kg)',
      weight: _weightC2,
      isBenefit: true,
    ),
    SawCriterion(
      code: 'C3',
      name: 'Frekuensi Komplain',
      description: 'Jumlah komplain dari pelanggan (skala bobot)',
      weight: _weightC3,
      isBenefit: false, // Cost: nilai lebih kecil = lebih baik
    ),
  ];

  void setWeights(double w1, double w2, double w3) {
    _weightC1 = w1;
    _weightC2 = w2;
    _weightC3 = w3;
    notifyListeners();
  }

  void addCandidate(SawCandidate candidate) {
    _candidates.add(candidate);
    _results = []; // Clear results as data changed
    notifyListeners();
  }

  void removeCandidate(String id) {
    _candidates.removeWhere((c) => c.id == id);
    _results = [];
    notifyListeners();
  }

  void clearCandidates() {
    _candidates.clear();
    _results.clear();
    notifyListeners();
  }

  // Tidak perlu lagi fungsi mapping manual karena user sudah menginput bobot (1-5) langsung dari kuesioner

  // ──────────────────────── File Parsing ────────────────────────

  Future<void> importFromCsv(String path) async {
    try {
      final input = await File(path).readAsString();
      final fields = Csv().decode(input);

      // Skip header, parse rows
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length >= 4) {
          _candidates.add(
            SawCandidate(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  i.toString(),
              name: row[0].toString(),
              c1: double.tryParse(row[1].toString()) ?? 0,
              c2: double.tryParse(row[2].toString()) ?? 0,
              c3: double.tryParse(row[3].toString()) ?? 0,
            ),
          );
        }
      }
      _results.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal membaca CSV: $e';
      notifyListeners();
    }
  }

  Future<void> importFromExcel(String path) async {
    try {
      var bytes = File(path).readAsBytesSync();
      var excel = ex.Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet != null) {
          for (var i = 1; i < sheet.maxRows; i++) {
            var row = sheet.rows[i];
            if (row.length >= 4 && row[0] != null) {
              _candidates.add(
                SawCandidate(
                  id:
                      DateTime.now().millisecondsSinceEpoch.toString() +
                      i.toString(),
                  name: row[0]?.value.toString() ?? 'Unknown',
                  c1: double.tryParse(row[1]?.value.toString() ?? '0') ?? 0,
                  c2: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
                  c3: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
                ),
              );
            }
          }
        }
        break; // Only read first sheet
      }
      _results.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal membaca Excel: $e';
      notifyListeners();
    }
  }

  Future<void> pickAndLoadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        if (path.toLowerCase().endsWith('.csv')) {
          await importFromCsv(path);
        } else {
          await importFromExcel(path);
        }
      }
    } catch (e) {
      _errorMessage = 'Gagal memilih file: $e';
      notifyListeners();
    }
  }

  // ──────────────────────── Main SAW Calculation ────────────────────────

  Future<void> calculateSaw() async {
    if (_candidates.isEmpty) {
      _errorMessage = 'Silakan tambahkan data pelanggan terlebih dahulu.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Convert to mapped scores
      final List<Map<String, dynamic>> processedData = [];

      for (final c in _candidates) {
        // Menggunakan bobot yang diinput (1-5) secara langsung
        final mappedC1 = c.c1;
        final mappedC2 = c.c2;
        final mappedC3 = c.c3;

        processedData.add({
          'candidate': c,
          'mapped_C1': mappedC1,
          'mapped_C2': mappedC2,
          'mapped_C3': mappedC3,
        });
      }

      // 2. Find max and min
      double maxC1 = 0, maxC2 = 0, maxC3 = 0;
      double minC1 = 999, minC2 = 999, minC3 = 999;

      for (final d in processedData) {
        if ((d['mapped_C1'] as double) > maxC1) { maxC1 = d['mapped_C1'] as double; }
        if ((d['mapped_C2'] as double) > maxC2) { maxC2 = d['mapped_C2'] as double; }
        if ((d['mapped_C3'] as double) > maxC3) { maxC3 = d['mapped_C3'] as double; }

        if ((d['mapped_C1'] as double) < minC1) { minC1 = d['mapped_C1'] as double; }
        if ((d['mapped_C2'] as double) < minC2) { minC2 = d['mapped_C2'] as double; }
        if ((d['mapped_C3'] as double) < minC3) { minC3 = d['mapped_C3'] as double; }
      }

      if (maxC1 == 0) maxC1 = 1;
      if (maxC2 == 0) maxC2 = 1;
      if (maxC3 == 0) maxC3 = 1;
      if (minC1 == 999) minC1 = 1;
      if (minC2 == 999) minC2 = 1;
      if (minC3 == 999) minC3 = 1;

      // 3. Normalize and score
      final List<SawResult> tempResults = [];
      for (final d in processedData) {
        final c1Raw = d['mapped_C1'] as double;
        final c2Raw = d['mapped_C2'] as double;
        final c3Raw = d['mapped_C3'] as double;

        // Normalisasi sesuai dokumen SAW:
        // C1 & C2 = Benefit → R = Xij / Max(Xj)
        // C3      = Cost    → R = Min(Xj) / Xij
        final c1Norm = c1Raw / maxC1;
        final c2Norm = c2Raw / maxC2;
        // Jika c3Raw = 0 (tidak valid sesuai catatan dokumen), gunakan 1.0
        final c3Norm = c3Raw > 0 ? minC3 / c3Raw : 1.0;

        // Normalisasi bobot jika total bobot slider ≠ 1.0
        final totalW = _weightC1 + _weightC2 + _weightC3;
        final wC1 = _weightC1 / totalW;
        final wC2 = _weightC2 / totalW;
        final wC3 = _weightC3 / totalW;

        final finalScore = (wC1 * c1Norm) + (wC2 * c2Norm) + (wC3 * c3Norm);

        tempResults.add(
          SawResult(
            candidate: d['candidate'] as SawCandidate,
            mappedScores: {'C1': c1Raw, 'C2': c2Raw, 'C3': c3Raw},
            normScores: {'C1': c1Norm, 'C2': c2Norm, 'C3': c3Norm},
            finalScore: finalScore,
            rank: 0,
          ),
        );
      }

      // 4. Rank
      tempResults.sort((a, b) => b.finalScore.compareTo(a.finalScore));
      _results = [];
      for (int i = 0; i < tempResults.length; i++) {
        _results.add(
          SawResult(
            candidate: tempResults[i].candidate,
            mappedScores: tempResults[i].mappedScores,
            normScores: tempResults[i].normScores,
            finalScore: tempResults[i].finalScore,
            rank: i + 1,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error calculating SAW: $e');
      _errorMessage = 'Gagal menghitung SAW: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
