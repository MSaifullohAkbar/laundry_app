import 'package:flutter/foundation.dart';
import '../models/parfum.dart';
import '../services/supabase_service.dart';

class ParfumProvider extends ChangeNotifier {
  List<Parfum> _parfums = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Parfum> get parfums => _parfums;
  bool get isLoading => _isLoading;

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

  Future<void> fetchParfums() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('parfums')
          .select()
          .order('name', ascending: true);

      _parfums = response.map((data) => Parfum.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching parfums: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addParfum(Parfum parfum) async {
    try {
      final response = await supabase.from('parfums').insert(parfum.toMap()).select().single();

      _parfums.add(Parfum.fromMap(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding parfum: $e');
      rethrow;
    }
  }

  Future<void> updateParfum(String id, {String? name, double? stockLiters}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (stockLiters != null) updates['stock_liters'] = stockLiters;

    if (updates.isEmpty) return;

    try {
      final response = await supabase
          .from('parfums')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      final idx = _parfums.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        _parfums[idx] = Parfum.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating parfum: $e');
      rethrow;
    }
  }

  Parfum? getParfumById(String id) {
    final idx = _parfums.indexWhere((p) => p.id == id);
    return idx >= 0 ? _parfums[idx] : null;
  }
}
