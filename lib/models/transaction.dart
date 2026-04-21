import 'customer.dart';
import 'service.dart';

class TransactionItem {
  final ServiceType service;
  final double quantity;
  final double subtotal;

  const TransactionItem({
    required this.service,
    required this.quantity,
    required this.subtotal,
  });

  TransactionItem copyWith({
    ServiceType? service,
    double? quantity,
    double? subtotal,
  }) {
    return TransactionItem(
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
  final double deliveryFee;
  final double discount;
  final double total;
  final String status; // 'antrian' | 'proses' | 'selesai' | 'terlambat' | 'batal'
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? estimatedDone;
  final String cashierName;

  const Transaction({
    required this.id,
    required this.invoiceNumber,
    required this.customer,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.total,
    required this.status,
    this.isPaid = false,
    required this.createdAt,
    this.estimatedDone,
    required this.cashierName,
  });

  Transaction copyWith({
    String? id,
    String? invoiceNumber,
    Customer? customer,
    List<TransactionItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    String? status,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? estimatedDone,
    String? cashierName,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      estimatedDone: estimatedDone ?? this.estimatedDone,
      cashierName: cashierName ?? this.cashierName,
    );
  }
}

// Dummy transactions
final List<Transaction> dummyTransactions = [
  Transaction(
    id: 't1',
    invoiceNumber: 'INV-20240421-001',
    customer: dummyCustomers[0],
    items: [
      TransactionItem(
        service: dummyServices[0],
        quantity: 3.5,
        subtotal: 42000,
      ),
    ],
    subtotal: 42000,
    deliveryFee: 10000,
    discount: 0,
    total: 52000,
    status: 'selesai',
    isPaid: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    estimatedDone: DateTime.now().subtract(const Duration(hours: 1)),
    cashierName: 'Admin',
  ),
  Transaction(
    id: 't2',
    invoiceNumber: 'INV-20240421-002',
    customer: dummyCustomers[1],
    items: [
      TransactionItem(
        service: dummyServices[1],
        quantity: 2.0,
        subtotal: 40000,
      ),
      TransactionItem(
        service: dummyServices[4],
        quantity: 1,
        subtotal: 45000,
      ),
    ],
    subtotal: 85000,
    deliveryFee: 0,
    discount: 5000,
    total: 80000,
    status: 'proses',
    isPaid: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    estimatedDone: DateTime.now().add(const Duration(hours: 7)),
    cashierName: 'Admin',
  ),
  Transaction(
    id: 't3',
    invoiceNumber: 'INV-20240421-003',
    customer: dummyCustomers[2],
    items: [
      TransactionItem(
        service: dummyServices[0],
        quantity: 5.0,
        subtotal: 60000,
      ),
    ],
    subtotal: 60000,
    deliveryFee: 10000,
    discount: 0,
    total: 70000,
    status: 'antrian',
    isPaid: true,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    estimatedDone: DateTime.now().add(const Duration(days: 2)),
    cashierName: 'Admin',
  ),
  Transaction(
    id: 't4',
    invoiceNumber: 'INV-20240420-001',
    customer: dummyCustomers[3],
    items: [
      TransactionItem(
        service: dummyServices[2],
        quantity: 4.0,
        subtotal: 28000,
      ),
    ],
    subtotal: 28000,
    deliveryFee: 0,
    discount: 0,
    total: 28000,
    status: 'terlambat',
    isPaid: false,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    estimatedDone: DateTime.now().subtract(const Duration(days: 1)),
    cashierName: 'Admin',
  ),
  Transaction(
    id: 't5',
    invoiceNumber: 'INV-20240420-002',
    customer: dummyCustomers[4],
    items: [
      TransactionItem(
        service: dummyServices[6],
        quantity: 2,
        subtotal: 70000,
      ),
    ],
    subtotal: 70000,
    deliveryFee: 15000,
    discount: 0,
    total: 85000,
    status: 'selesai',
    isPaid: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    estimatedDone:
        DateTime.now().subtract(const Duration(hours: 12)),
    cashierName: 'Admin',
  ),
];
