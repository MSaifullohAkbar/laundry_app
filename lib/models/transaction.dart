import 'customer.dart';
import 'service.dart';

class TransactionItem {
  final String? id;
  final ServiceType service;
  final double quantity;
  final double subtotal;

  const TransactionItem({
    this.id,
    required this.service,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      service: ServiceType.fromMap(map['services'] ?? map['service'] ?? {}),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap(String transactionId) {
    return {
      'transaction_id': transactionId,
      'service_id': service.id,
      'quantity': quantity,
      'price_per_unit': service.price,
      'subtotal': subtotal,
    };
  }

  TransactionItem copyWith({
    String? id,
    ServiceType? service,
    double? quantity,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

class Transaction {
  final String id;
  final String invoiceNumber;
  final Customer customer;
  final List<TransactionItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String
  status; // 'antrian' | 'proses' | 'selesai' | 'terlambat' | 'batal'
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? estimatedDone;
  final String? paymentMethodId;
  final String? kasirName;
  final String? userId;

  const Transaction({
    required this.id,
    required this.invoiceNumber,
    required this.customer,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    required this.status,
    this.isPaid = false,
    required this.createdAt,
    this.estimatedDone,
    this.paymentMethodId,
    this.kasirName,
    this.userId,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    final itemsData = map['transaction_items'] as List<dynamic>? ?? [];
    return Transaction(
      id: map['id'],
      invoiceNumber: map['invoice_number'] ?? '',
      customer: Customer.fromMap(map['customers'] ?? {}),
      items: itemsData
          .map((i) => TransactionItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      subtotal: (map['total_amount'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['grand_total'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'antrian',
      isPaid: map['payment_status'] == 'paid',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      estimatedDone: map['estimated_completion'] != null
          ? DateTime.tryParse(map['estimated_completion'])
          : null,
      paymentMethodId: map['payment_method_id'],
      userId: map['user_id'],
      kasirName: map['users'] != null 
          ? (map['users']['full_name'] ?? map['users']['email']?.split('@')?.first) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoice_number': invoiceNumber,
      'customer_id': customer.id,
      'status': status,
      'payment_status': isPaid ? 'paid' : 'unpaid',
      'total_amount': subtotal,
      'discount': discount,
      'grand_total': total,
      'estimated_completion': estimatedDone?.toIso8601String(),
      'payment_method_id': paymentMethodId,
    };
  }

  Transaction copyWith({
    String? id,
    String? invoiceNumber,
    Customer? customer,
    List<TransactionItem>? items,
    double? subtotal,
    double? discount,
    double? total,
    String? status,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? estimatedDone,
    String? paymentMethodId,
    String? kasirName,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      estimatedDone: estimatedDone ?? this.estimatedDone,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      kasirName: kasirName ?? this.kasirName,
      userId: userId ?? this.userId,
    );
  }
}
