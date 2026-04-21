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

final List<ServiceType> dummyServices = [
  const ServiceType(
    id: 's1',
    name: 'Cuci Komplit Reguler',
    category: 'kiloan',
    price: 12000,
    unit: 'kg',
    durationHours: 48,
    description: 'Cuci, kering, dan setrika',
  ),
  const ServiceType(
    id: 's2',
    name: 'Cuci Komplit Express',
    category: 'kiloan',
    price: 20000,
    unit: 'kg',
    isExpress: true,
    durationHours: 12,
    description: 'Cuci, kering, dan setrika cepat',
  ),
  const ServiceType(
    id: 's3',
    name: 'Cuci Saja',
    category: 'kiloan',
    price: 7000,
    unit: 'kg',
    includeDry: false,
    includeIron: false,
    durationHours: 24,
    description: 'Hanya pencucian',
  ),
  const ServiceType(
    id: 's4',
    name: 'Setrika Saja',
    category: 'kiloan',
    price: 5000,
    unit: 'kg',
    includeWash: false,
    includeDry: false,
    durationHours: 12,
    description: 'Hanya setrika',
  ),
  const ServiceType(
    id: 's5',
    name: 'Jas / Blazer',
    category: 'satuan',
    price: 45000,
    unit: 'pcs',
    isPremium: true,
    durationHours: 72,
    description: 'Dry clean untuk jas dan blazer',
  ),
  const ServiceType(
    id: 's6',
    name: 'Gaun / Dress',
    category: 'satuan',
    price: 55000,
    unit: 'pcs',
    isPremium: true,
    durationHours: 72,
    description: 'Dry clean untuk gaun dan dress',
  ),
  const ServiceType(
    id: 's7',
    name: 'Sepatu',
    category: 'satuan',
    price: 35000,
    unit: 'pcs',
    isPremium: true,
    durationHours: 48,
    description: 'Cuci sepatu profesional',
  ),
  const ServiceType(
    id: 's8',
    name: 'Selimut / Bed Cover',
    category: 'satuan',
    price: 30000,
    unit: 'pcs',
    durationHours: 48,
    description: 'Cuci selimut dan bed cover',
  ),
];
