class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final String? address;
  final bool isVip;
  final String? avatarUrl;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.address,
    this.isVip = false,
    this.avatarUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? address,
    bool? isVip,
    String? avatarUrl,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      isVip: isVip ?? this.isVip,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Dummy data
final List<Customer> dummyCustomers = [
  const Customer(
    id: 'c1',
    name: 'Budi Santoso',
    phone: '081234567890',
    gender: 'Laki-laki',
    address: 'Jl. Merdeka No. 10, Jakarta',
    isVip: true,
  ),
  const Customer(
    id: 'c2',
    name: 'Siti Rahayu',
    phone: '082345678901',
    email: 'siti@email.com',
    gender: 'Perempuan',
    address: 'Jl. Sudirman No. 5, Jakarta',
    isVip: false,
  ),
  const Customer(
    id: 'c3',
    name: 'Ahmad Fauzi',
    phone: '083456789012',
    gender: 'Laki-laki',
    address: 'Jl. Thamrin No. 20, Jakarta',
    isVip: true,
  ),
  const Customer(
    id: 'c4',
    name: 'Dewi Putri',
    phone: '084567890123',
    email: 'dewi@email.com',
    gender: 'Perempuan',
    address: 'Jl. Gatot Subroto No. 15, Jakarta',
    isVip: false,
  ),
  const Customer(
    id: 'c5',
    name: 'Rizki Pratama',
    phone: '085678901234',
    gender: 'Laki-laki',
    address: 'Jl. Kuningan No. 8, Jakarta',
    isVip: false,
  ),
  const Customer(
    id: 'c6',
    name: 'Maya Sari',
    phone: '086789012345',
    email: 'maya@email.com',
    gender: 'Perempuan',
    address: 'Jl. Kebayoran No. 3, Jakarta Selatan',
    isVip: true,
  ),
];
