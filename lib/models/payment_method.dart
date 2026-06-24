class PaymentMethod {
  final String id;
  final String name;
  final String type; // 'cash', 'transfer', 'ewallet', 'qris'
  final String? accountNumber;
  final String? accountName;
  final bool isActive;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.accountNumber,
    this.accountName,
    this.isActive = true,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'] ?? '',
      type: map['type'] ?? 'cash',
      accountNumber: map['account_number'],
      accountName: map['account_name'],
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'account_number': accountNumber,
      'account_name': accountName,
      'is_active': isActive,
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? type,
    String? accountNumber,
    String? accountName,
    bool? isActive,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      isActive: isActive ?? this.isActive,
    );
  }

  static String typeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'transfer':
        return 'Transfer Bank';
      case 'ewallet':
        return 'E-Wallet';
      case 'qris':
        return 'QRIS';
      default:
        return type;
    }
  }
}
