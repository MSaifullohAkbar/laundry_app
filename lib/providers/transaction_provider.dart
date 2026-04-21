import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/customer.dart';
import '../models/service.dart';

class CartItem {
  final ServiceType service;
  double quantity;
  CartItem({required this.service, this.quantity = 1});
  double get subtotal => service.price * quantity;
}

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = List.from(dummyTransactions);

  // Cart state for new transaction
  Customer? _cartCustomer;
  final List<CartItem> _cartItems = [];

  List<Transaction> get transactions => _transactions;
  Customer? get cartCustomer => _cartCustomer;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

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

  void completeTransaction() {
    if (_cartCustomer == null || _cartItems.isEmpty) return;

    final now = DateTime.now();
    final items = _cartItems
        .map((c) => TransactionItem(
              service: c.service,
              quantity: c.quantity,
              subtotal: c.subtotal,
            ))
        .toList();

    final total = cartSubtotal;
    final newTx = Transaction(
      id: 'tx_${now.millisecondsSinceEpoch}',
      invoiceNumber:
          'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(_transactions.length + 1).toString().padLeft(3, '0')}',
      customer: _cartCustomer!,
      items: items,
      subtotal: total,
      total: total,
      status: 'antrian',
      isPaid: false,
      createdAt: now,
      estimatedDone: now.add(const Duration(days: 2)),
      cashierName: 'Admin',
    );

    _transactions.insert(0, newTx);
    clearCart();
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
