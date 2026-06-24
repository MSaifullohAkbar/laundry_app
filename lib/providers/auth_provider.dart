import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  AppUser? _currentUser;
  StreamSubscription? _authStateSubscription;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  AppUser? get currentUser => _currentUser;
  
  // Helper getters untuk role
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isKasir => _currentUser?.isKasir ?? false;
  UserRole? get userRole => _currentUser?.role;

  AuthProvider() {
    _checkInitialAuth();
    _setupAuthListener();
  }

  void _checkInitialAuth() async {
    final session = supabase.auth.currentSession;
    _isAuthenticated = session != null;
    
    if (_isAuthenticated) {
      await _fetchUserProfile();
    }
    
    notifyListeners();
  }

  void _setupAuthListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final newAuthState = session != null;
      
      if (_isAuthenticated != newAuthState) {
        _isAuthenticated = newAuthState;
        
        if (_isAuthenticated) {
          await _fetchUserProfile();
        } else {
          _currentUser = null;
        }
        
        notifyListeners();
      }
    });
  }

  /// Mengambil data user profile dari database
  Future<void> _fetchUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Profil tidak ditemukan di tabel public.users
        debugPrint('User profile not found in public.users');
        await signOut();
        throw Exception('Profil RBAC tidak ditemukan. Silakan jalankan SQL troubleshooting di Supabase.');
      }

      _currentUser = AppUser.fromMap(response);
      debugPrint('User profile loaded: ${_currentUser?.email} (${_currentUser?.roleLabel})');
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Jika gagal fetch profile, pastikan ter-logout
      await signOut();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user != null) {
        // Fetch user profile setelah login sukses
        await _fetchUserProfile();
        
        // Check jika user tidak aktif
        if (_currentUser?.isActive == false) {
          await signOut();
          throw Exception('Akun Anda telah dinonaktifkan. Hubungi administrator.');
        }
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user profile (berguna setelah update profile)
  Future<void> refreshUserProfile() async {
    if (!_isAuthenticated) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _fetchUserProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
