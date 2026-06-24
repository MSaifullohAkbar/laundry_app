import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../services/supabase_service.dart';

import '../models/cart_item.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  // Cart state for new transaction
  Customer? _cartCustomer;
  final List<CartItem> _cartItems = [];

  List<Transaction> get transactions => _transactions;
  Customer? get cartCustomer => _cartCustomer;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;

  double get cartSubtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  bool get canCheckout =>
      _cartCustomer != null && _cartItems.isNotEmpty;

  void setCartCustomer(Customer? customer) {
    _cartCustomer = customer;
    notifyListeners();
  }

  void addToCart(ServiceType service) {
    final existing = _cartItems.where((i) => i.service.id == service.id);
    if (existing.isNotEmpty) {
      existing.first.quantity += service.unit == 'kg' ? 1.0 : 1;
    } else {
      _cartItems.add(CartItem(
        service: service,
        quantity: service.unit == 'kg' ? 1.0 : 1,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String serviceId) {
    final idx = _cartItems.indexWhere((i) => i.service.id == serviceId);
    if (idx >= 0) {
      if (_cartItems[idx].quantity > 1) {
        _cartItems[idx].quantity -= 1;
      } else {
        _cartItems.removeAt(idx);
      }
    }
    notifyListeners();
  }

  void removeItemCompletely(String serviceId) {
    _cartItems.removeWhere((i) => i.service.id == serviceId);
    notifyListeners();
  }

  void clearCart() {
    _cartCustomer = null;
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('transactions')
          .select('''
            *,
            customers(*),
            transaction_items(
              *,
              services(*)
            )
          ''')
          .order('created_at', ascending: false);

      _transactions = response.map((data) => Transaction.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeTransaction(String? paymentMethodId) async {
    if (_cartCustomer == null || _cartItems.isEmpty) return;

    final now = DateTime.now();
    final total = cartSubtotal;
    
    // Generate unique invoice number using timestamp
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final uniqueSuffix = now.microsecondsSinceEpoch.toString().substring(8);
    final invoiceNumber = 'INV-$dateStr-$uniqueSuffix';

    // Calculate estimated completion from longest service duration
    int maxDurationHours = 48; // default 2 days
    for (final item in _cartItems) {
      final hours = item.service.durationHours ?? 48;
      if (hours > maxDurationHours) maxDurationHours = hours;
    }
    final estimatedCompletion = now.add(Duration(hours: maxDurationHours));


    try {
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Sesi login tidak valid. Silakan login ulang.');
      }

      // 1. Insert header to transactions table
      final txResponse = await supabase.from('transactions').insert({
        'invoice_number': invoiceNumber,
        'customer_id': _cartCustomer!.id,
        'user_id': currentUserId,
        'payment_method_id': paymentMethodId,
        'status': 'antrian',
        'payment_status': paymentMethodId != null ? 'paid' : 'unpaid',
        'total_amount': total,
        'discount': 0,
        'grand_total': total,
        'estimated_completion': estimatedCompletion.toIso8601String(),
      }).select('''
        *,
        customers(*)
      ''').single();

      final txId = txResponse['id'];

      // 2. Insert items to transaction_items table
      final itemsToInsert = _cartItems.map((item) => <String, dynamic>{
        'transaction_id': txId,
        'service_id': item.service.id,
        'quantity': item.quantity,
        'price_per_unit': item.service.price,
        'subtotal': item.subtotal,
      }).toList();

      final itemsResponse = await supabase
          .from('transaction_items')
          .insert(itemsToInsert)
          .select('''
            *,
            services(*)
          ''');

      // 3. Update local state
      txResponse['transaction_items'] = itemsResponse;
      final newTx = Transaction.fromMap(txResponse);
      
      _transactions.insert(0, newTx);
      clearCart();
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(String transactionId, String newStatus) async {
    try {
      await supabase
          .from('transactions')
          .update({'status': newStatus})
          .eq('id', transactionId);

      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx >= 0) {
        _transactions[idx] = _transactions[idx].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }

  Future<void> markAsPaid(String transactionId, String paymentMethodId) async {
    try {
      await supabase
          .from('transactions')
          .update({
            'payment_status': 'paid',
            'payment_method_id': paymentMethodId,
          })
          .eq('id', transactionId);

      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx >= 0) {
        _transactions[idx] = _transactions[idx].copyWith(
          isPaid: true,
          paymentMethodId: paymentMethodId,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking as paid: $e');
      rethrow;
    }
  }

  // Filtered lists
  List<Transaction> getByStatus(String status) {
    if (status == 'semua') return _transactions;
    return _transactions.where((t) => t.status == status).toList();
  }

  Transaction? getById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  double get todayRevenue {
    final today = DateTime.now();
    return _transactions
        .where((t) =>
            t.status == 'selesai' &&
            t.createdAt.year == today.year &&
            t.createdAt.month == today.month &&
            t.createdAt.day == today.day)
        .fold(0, (sum, t) => sum + t.total);
  }

  int get inQueueCount =>
      _transactions.where((t) => t.status == 'antrian').length;

  int get mustFinishCount =>
      _transactions.where((t) => t.status == 'proses').length;

  int get lateCount =>
      _transactions.where((t) => t.status == 'terlambat').length;
}
