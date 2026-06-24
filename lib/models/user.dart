import 'package:flutter/foundation.dart';

enum UserRole {
  admin('admin', 'Admin'),
  kasir('kasir', 'Kasir');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.kasir,
    );
  }
}

@immutable
class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor dari Map (Supabase response)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      role: UserRole.fromString(map['role'] as String),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.value,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with untuk immutability
  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isAdmin => role == UserRole.admin;
  bool get isKasir => role == UserRole.kasir;

  String get displayName => fullName ?? email.split('@').first;
  String get roleLabel => role.label;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, role: ${role.value}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.role == role &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        role.hashCode ^
        isActive.hashCode;
  }
}
