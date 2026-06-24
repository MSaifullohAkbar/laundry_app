import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class ReportProvider extends ChangeNotifier {
  String _selectedPeriod = 'Hari Ini';
  bool _isLoading = false;

  double _totalRevenue = 0;
  int _completedTransactions = 0;
  double _previousRevenue = 0;
  List<Map<String, dynamic>> _chartData = [];

  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  double get totalRevenue => _totalRevenue;
  int get completedTransactions => _completedTransactions;
  List<Map<String, dynamic>> get chartData => _chartData;

  String get growthPercentage {
    if (_previousRevenue == 0) return '+0%';
    final growth = ((_totalRevenue - _previousRevenue) / _previousRevenue) * 100;
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(0)}%';
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime prevStartDate;
      DateTime prevEndDate;

      switch (_selectedPeriod) {
        case 'Minggu':
          startDate = now.subtract(const Duration(days: 7));
          prevStartDate = now.subtract(const Duration(days: 14));
          prevEndDate = startDate;
          break;
        case 'Bulan':
          startDate = DateTime(now.year, now.month, 1);
          // Handle January correctly
          final prevMonth = now.month == 1 ? 12 : now.month - 1;
          final prevYear = now.month == 1 ? now.year - 1 : now.year;
          prevStartDate = DateTime(prevYear, prevMonth, 1);
          prevEndDate = startDate;
          break;
        default: // Hari Ini
          startDate = DateTime(now.year, now.month, now.day);
          prevStartDate = startDate.subtract(const Duration(days: 1));
          prevEndDate = startDate;
          break;
      }

      // Fetch current period
      final currentResponse = await supabase
          .from('transactions')
          .select('grand_total, status, created_at')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', now.toIso8601String());

      _totalRevenue = 0;
      _completedTransactions = 0;
      for (final tx in currentResponse) {
        if (tx['status'] == 'selesai') {
          _totalRevenue += (tx['grand_total'] as num?)?.toDouble() ?? 0;
          _completedTransactions++;
        }
      }

      // Fetch previous period for growth calculation
      final prevResponse = await supabase
          .from('transactions')
          .select('grand_total, status')
          .gte('created_at', prevStartDate.toIso8601String())
          .lt('created_at', prevEndDate.toIso8601String());

      _previousRevenue = 0;
      for (final tx in prevResponse) {
        if (tx['status'] == 'selesai') {
          _previousRevenue += (tx['grand_total'] as num?)?.toDouble() ?? 0;
        }
      }

      // Build chart data (last 7 days)
      _chartData = [];
      final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        double dayRevenue = 0;
        for (final tx in currentResponse) {
          if (tx['status'] == 'selesai') {
            final txDate = DateTime.tryParse(tx['created_at'] ?? '');
            if (txDate != null &&
                !txDate.isBefore(dayStart) &&
                txDate.isBefore(dayEnd)) {
              dayRevenue += (tx['grand_total'] as num?)?.toDouble() ?? 0;
            }
          }
        }
        _chartData.add({
          'day': dayLabels[day.weekday - 1],
          'amount': dayRevenue,
        });
      }
    } catch (e) {
      debugPrint('Error fetching report data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
