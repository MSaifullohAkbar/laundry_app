class Parfum {
  final String id;
  final String name;
  final double stockLiters;
  final String iconName;

  const Parfum({
    required this.id,
    required this.name,
    required this.stockLiters,
    required this.iconName,
  });

  bool get isLowStock => stockLiters < 0.5 && stockLiters > 0;
  bool get isOutOfStock => stockLiters <= 0;

  Parfum copyWith({
    String? id,
    String? name,
    double? stockLiters,
    String? iconName,
  }) {
    return Parfum(
      id: id ?? this.id,
      name: name ?? this.name,
      stockLiters: stockLiters ?? this.stockLiters,
      iconName: iconName ?? this.iconName,
    );
  }
}

final List<Parfum> dummyParfums = [
  const Parfum(id: 'p1', name: 'Floral Bouquet', stockLiters: 2.5, iconName: 'water_drop'),
  const Parfum(id: 'p2', name: 'Fresh Ocean', stockLiters: 0.3, iconName: 'water_drop'),
  const Parfum(id: 'p3', name: 'Lavender Dream', stockLiters: 1.8, iconName: 'water_drop'),
  const Parfum(id: 'p4', name: 'Citrus Burst', stockLiters: 0.0, iconName: 'water_drop'),
  const Parfum(id: 'p5', name: 'Vanilla Sweet', stockLiters: 3.2, iconName: 'water_drop'),
  const Parfum(id: 'p6', name: 'Rose Garden', stockLiters: 0.4, iconName: 'water_drop'),
];
