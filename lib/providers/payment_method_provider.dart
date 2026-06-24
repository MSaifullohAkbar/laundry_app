import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';
import '../services/supabase_service.dart';

class PaymentMethodProvider extends ChangeNotifier {
  List<PaymentMethod> _methods = [];
  bool _isLoading = false;

  List<PaymentMethod> get methods => List.unmodifiable(_methods);
  List<PaymentMethod> get activeMethods =>
      _methods.where((m) => m.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('payment_methods')
          .select()
          .order('created_at', ascending: true);

      _methods = response.map((data) => PaymentMethod.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMethod(PaymentMethod method) async {
    try {
      final response = await supabase.from('payment_methods').insert({
        'name': method.name,
        'type': method.type,
        'account_number': method.accountNumber,
        'account_name': method.accountName,
        'is_active': method.isActive,
      }).select().single();

      _methods.add(PaymentMethod.fromMap(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      rethrow;
    }
  }

  Future<void> updateMethod(PaymentMethod updated) async {
    try {
      final response = await supabase
          .from('payment_methods')
          .update(updated.toMap())
          .eq('id', updated.id)
          .select()
          .single();

      final index = _methods.indexWhere((m) => m.id == updated.id);
      if (index != -1) {
        _methods[index] = PaymentMethod.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating payment method: $e');
      rethrow;
    }
  }

  Future<void> toggleActive(String id) async {
    final index = _methods.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final currentStatus = _methods[index].isActive;
    
    // Optimistic update
    _methods[index] = _methods[index].copyWith(isActive: !currentStatus);
    notifyListeners();

    try {
      await supabase
          .from('payment_methods')
          .update({'is_active': !currentStatus})
          .eq('id', id);
    } catch (e) {
      // Revert if failed
      debugPrint('Error toggling status: $e');
      _methods[index] = _methods[index].copyWith(isActive: currentStatus);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMethod(String id) async {
    try {
      await supabase.from('payment_methods').delete().eq('id', id);
      _methods.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting method: $e');
      rethrow;
    }
  }
}
