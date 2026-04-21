import 'package:flutter/foundation.dart';
import '../models/parfum.dart';

class ParfumProvider extends ChangeNotifier {
  final List<Parfum> _parfums = List.from(dummyParfums);
  String _searchQuery = '';

  List<Parfum> get parfums => _parfums;

  List<Parfum> get filteredParfums {
    if (_searchQuery.isEmpty) return _parfums;
    return _parfums
        .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addParfum(Parfum parfum) {
    _parfums.add(parfum);
    notifyListeners();
  }

  void updateStock(String id, double newStock) {
    final idx = _parfums.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _parfums[idx] = _parfums[idx].copyWith(stockLiters: newStock);
      notifyListeners();
    }
  }
}

class ReportProvider extends ChangeNotifier {
  String _selectedPeriod = 'Hari Ini';

  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Simulated stats
  double get totalRevenue {
    switch (_selectedPeriod) {
      case 'Hari Ini':
        return 4250000;
      case 'Minggu':
        return 18500000;
      case 'Bulan':
        return 75000000;
      default:
        return 4250000;
    }
  }

  int get completedTransactions {
    switch (_selectedPeriod) {
      case 'Hari Ini':
        return 84;
      case 'Minggu':
        return 312;
      case 'Bulan':
        return 1248;
      default:
        return 84;
    }
  }

  String get growthPercentage {
    switch (_selectedPeriod) {
      case 'Hari Ini':
        return '+12%';
      case 'Minggu':
        return '+8%';
      case 'Bulan':
        return '+15%';
      default:
        return '+12%';
    }
  }

  List<Map<String, dynamic>> get chartData {
    return [
      {'day': 'Sen', 'amount': 3200000},
      {'day': 'Sel', 'amount': 2800000},
      {'day': 'Rab', 'amount': 4100000},
      {'day': 'Kam', 'amount': 3600000},
      {'day': 'Jum', 'amount': 4800000},
      {'day': 'Sab', 'amount': 5200000},
      {'day': 'Min', 'amount': 4250000},
    ];
  }
}
