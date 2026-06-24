class ServiceType {
  final String id;
  final String name;
  final String category; // 'kiloan' | 'satuan'
  final double price;
  final String unit; // 'kg' | 'pcs'
  final bool includeWash;
  final bool includeDry;
  final bool includeIron;
  final String? imageUrl;
  final bool isPremium;
  final bool isExpress;
  final int? durationHours;
  final String? description;

  const ServiceType({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.includeWash = true,
    this.includeDry = true,
    this.includeIron = true,
    this.imageUrl,
    this.isPremium = false,
    this.isExpress = false,
    this.durationHours,
    this.description,
  });

  factory ServiceType.fromMap(Map<String, dynamic> map) {
    return ServiceType(
      id: map['id'],
      name: map['name'] ?? '',
      category: map['category'] ?? 'kiloan',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] ?? 'kg',
      includeWash: map['include_wash'] ?? true,
      includeDry: map['include_dry'] ?? true,
      includeIron: map['include_iron'] ?? true,
      imageUrl: map['image_url'],
      isPremium: map['is_premium'] ?? false,
      isExpress: map['is_express'] ?? false,
      durationHours: map['duration_hours'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'include_wash': includeWash,
      'include_dry': includeDry,
      'include_iron': includeIron,
      'image_url': imageUrl,
      'is_premium': isPremium,
      'is_express': isExpress,
      'duration_hours': durationHours,
      'description': description,
    };
  }

  String get formattedDuration {
    if (durationHours == null) return '2 Hari';
    if (durationHours! < 24) return '$durationHours Jam';
    return '${(durationHours! / 24).round()} Hari';
  }

  ServiceType copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    bool? includeWash,
    bool? includeDry,
    bool? includeIron,
    String? imageUrl,
    bool? isPremium,
    bool? isExpress,
    int? durationHours,
    String? description,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      includeWash: includeWash ?? this.includeWash,
      includeDry: includeDry ?? this.includeDry,
      includeIron: includeIron ?? this.includeIron,
      imageUrl: imageUrl ?? this.imageUrl,
      isPremium: isPremium ?? this.isPremium,
      isExpress: isExpress ?? this.isExpress,
      durationHours: durationHours ?? this.durationHours,
      description: description ?? this.description,
    );
  }
}
