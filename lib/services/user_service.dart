import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import 'supabase_service.dart';

/// Service untuk manajemen user (khusus admin)
class UserService {
  /// Mengambil semua user (hanya admin)
  static Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((data) => AppUser.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      rethrow;
    }
  }

  /// Mengambil user berdasarkan ID
  static Future<AppUser?> getUserById(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  /// Membuat user baru (hanya admin)
  /// Menggunakan Supabase Edge Function 'create-user' yang berjalan dengan service role key
  static Future<AppUser> createUser({
    required String email,
    required String password,
    required UserRole role,
    String? fullName,
  }) async {
    try {
      // Panggil Edge Function yang menggunakan service_role key di server-side
      // Pastikan Edge Function 'create-user' sudah di-deploy di Supabase
      final response = await supabase.functions.invoke(
        'create-user',
        body: {
          'email': email,
          'password': password,
          'role': role.value,
          'full_name': fullName ?? '',
        },
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMsg = errorData?['error'] ?? 'Gagal membuat user';
        throw Exception(errorMsg);
      }

      final data = response.data as Map<String, dynamic>;
      final userId = data['user_id'] as String?;
      if (userId == null) {
        throw Exception('Response tidak valid dari server');
      }

      // Ambil data user dari tabel users
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User berhasil dibuat tapi profil tidak ditemukan');
      }

      return user;
    } on FunctionException catch (e) {
      debugPrint('Edge Function error creating user: ${e.reasonPhrase}');
      throw Exception('Gagal membuat user: ${e.reasonPhrase}');
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  /// Update role user (hanya admin)
  static Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await supabase
          .from('users')
          .update({'role': role.value})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  /// Update status aktif user (hanya admin)
  static Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }

  /// Update profile user
  static Future<void> updateUserProfile({
    required String userId,
    String? fullName,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (fullName != null) {
        updates['full_name'] = fullName;
      }

      if (updates.isNotEmpty) {
        await supabase
            .from('users')
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Hapus user (hanya admin)
  /// Menggunakan Supabase Edge Function 'delete-user' yang berjalan dengan service role key
  /// Note: Ini akan trigger cascade delete karena foreign key
  static Future<void> deleteUser(String userId) async {
    try {
      // Panggil Edge Function yang menggunakan service_role key di server-side
      // Pastikan Edge Function 'delete-user' sudah di-deploy di Supabase
      final response = await supabase.functions.invoke(
        'delete-user',
        body: {'user_id': userId},
      );

      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMsg = errorData?['error'] ?? 'Gagal menghapus user';
        throw Exception(errorMsg);
      }
    } on FunctionException catch (e) {
      debugPrint('Edge Function error deleting user: ${e.reasonPhrase}');
      throw Exception('Gagal menghapus user: ${e.reasonPhrase}');
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  /// Mengambil statistik user
  static Future<Map<String, int>> getUserStats() async {
    try {
      final users = await getAllUsers();
      
      return {
        'total': users.length,
        'admin': users.where((u) => u.role == UserRole.admin).length,
        'kasir': users.where((u) => u.role == UserRole.kasir).length,
        'active': users.where((u) => u.isActive).length,
        'inactive': users.where((u) => !u.isActive).length,
      };
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
      return {
        'total': 0,
        'admin': 0,
        'kasir': 0,
        'active': 0,
        'inactive': 0,
      };
    }
  }
}
