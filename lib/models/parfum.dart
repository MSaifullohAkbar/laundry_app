class Parfum {
  final String id;
  final String name;
  final double stockLiters;

  const Parfum({
    required this.id,
    required this.name,
    required this.stockLiters,
  });

  factory Parfum.fromMap(Map<String, dynamic> map) {
    return Parfum(
      id: map['id'],
      name: map['name'] ?? '',
      stockLiters: (map['stock_liters'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'stock_liters': stockLiters,
    };
  }

  bool get isLowStock => stockLiters < 0.5 && stockLiters > 0;
  bool get isOutOfStock => stockLiters <= 0;

  Parfum copyWith({
    String? id,
    String? name,
    double? stockLiters,
  }) {
    return Parfum(
      id: id ?? this.id,
      name: name ?? this.name,
      stockLiters: stockLiters ?? this.stockLiters,
    );
  }
}
