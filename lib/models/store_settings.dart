class StoreSettings {
  final String name;
  final String address;
  final String notes;
  final String footer;

  const StoreSettings({
    this.name = 'LaundryKu',
    this.address = '',
    this.notes = '',
    this.footer = '',
  });

  factory StoreSettings.fromMap(Map<String, dynamic> map) {
    return StoreSettings(
      name: map['name'] ?? 'LaundryKu',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      footer: map['footer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'notes': notes,
      'footer': footer,
    };
  }
}
