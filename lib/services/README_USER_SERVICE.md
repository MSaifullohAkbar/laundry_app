# User Service API Reference
## Panduan Penggunaan UserService

---

## 📌 Import

```dart
import 'package:laundryku/services/user_service.dart';
import 'package:laundryku/models/user.dart';
```

---

## 🔍 Get All Users (Admin Only)

Mengambil semua user dari database.

```dart
try {
  final List<User> users = await UserService.getAllUsers();
  
  for (var user in users) {
    print('${user.email} - ${user.roleLabel}');
  }
} catch (e) {
  print('Error: $e');
}
```

**Return:**
- `List<User>` - List semua user

**Permission:**
- ✅ Admin: Bisa lihat semua user
- ❌ Kasir: Error (RLS will block)

---

## 👤 Get User by ID

Mengambil data user berdasarkan ID.

```dart
try {
  final User? user = await UserService.getUserById('user-uuid-here');
  
  if (user != null) {
    print('User found: ${user.email}');
  } else {
    print('User not found');
  }
} catch (e) {
  print('Error: $e');
}
```

**Parameters:**
- `userId` (String) - UUID user

**Return:**
- `User?` - Data user atau null jika tidak ditemukan

---

## ➕ Create User (Admin Only)

Membuat user baru.

> ⚠️ **PENTING:** Method ini memerlukan **service_role key** atau **Supabase Edge Function**. 
> Tidak bisa dipanggil langsung dari client dengan anon key.

```dart
try {
  final User newUser = await UserService.createUser(
    email: 'kasir@laundryku.com',
    password: 'SecurePassword123!',
    role: UserRole.kasir,
    fullName: 'Budi Santoso',
  );
  
  print('User created: ${newUser.email}');
} catch (e) {
  print('Error creating user: $e');
}
```

**Parameters:**
- `email` (String, required) - Email user
- `password` (String, required) - Password minimal 8 karakter
- `role` (UserRole, required) - UserRole.admin atau UserRole.kasir
- `fullName` (String, optional) - Nama lengkap user

**Return:**
- `User` - Data user yang baru dibuat

**Alternatif:** Buat user via Supabase Dashboard → Authentication → Add user

---

## 🔄 Update User Role (Admin Only)

Mengubah role user.

```dart
try {
  await UserService.updateUserRole(
    'user-uuid-here',
    UserRole.admin,
  );
  
  print('User role updated successfully');
} catch (e) {
  print('Error: $e');
}
```

**Parameters:**
- `userId` (String) - UUID user yang akan diubah
- `role` (UserRole) - Role baru (UserRole.admin atau UserRole.kasir)

**Return:**
- `Future<void>`

---

## 🔒 Update User Status (Admin Only)

Mengaktifkan atau menonaktifkan user.

```dart
try {
  // Nonaktifkan user
  await UserService.updateUserStatus('user-uuid-here', false);
  
  // Aktifkan user
  await UserService.updateUserStatus('user-uuid-here', true);
  
  print('User status updated');
} catch (e) {
  print('Error: $e');
}
```

**Parameters:**
- `userId` (String) - UUID user
- `isActive` (bool) - true = aktif, false = nonaktif

**Return:**
- `Future<void>`

**Note:** User yang inactive tidak bisa login.

---

## ✏️ Update User Profile

Mengubah data profile user (fullName, dll).

```dart
try {
  await UserService.updateUserProfile(
    userId: 'user-uuid-here',
    fullName: 'John Doe Updated',
  );
  
  print('Profile updated');
} catch (e) {
  print('Error: $e');
}
```

**Parameters:**
- `userId` (String, required) - UUID user
- `fullName` (String, optional) - Nama lengkap baru

**Return:**
- `Future<void>`

**Permission:**
- ✅ User bisa update profile sendiri
- ✅ Admin bisa update profile user lain

---

## 🗑️ Delete User (Admin Only)

Menghapus user dari sistem.

> ⚠️ **WARNING:** Operasi ini PERMANENT dan tidak bisa di-undo!

```dart
try {
  await UserService.deleteUser('user-uuid-here');
  print('User deleted successfully');
} catch (e) {
  print('Error: $e');
}
```

**Parameters:**
- `userId` (String) - UUID user yang akan dihapus

**Return:**
- `Future<void>`

**Note:** 
- User akan dihapus dari `auth.users` dan `public.users` (cascade)
- Jangan hapus user sendiri yang sedang login!

---

## 📊 Get User Statistics

Mengambil statistik user.

```dart
try {
  final Map<String, int> stats = await UserService.getUserStats();
  
  print('Total users: ${stats['total']}');
  print('Admins: ${stats['admin']}');
  print('Kasir: ${stats['kasir']}');
  print('Active: ${stats['active']}');
  print('Inactive: ${stats['inactive']}');
} catch (e) {
  print('Error: $e');
}
```

**Return:**
```dart
{
  'total': 10,      // Total semua user
  'admin': 2,       // Jumlah admin
  'kasir': 8,       // Jumlah kasir
  'active': 9,      // User aktif
  'inactive': 1,    // User tidak aktif
}
```

---

## 🎯 Contoh Penggunaan di Widget

### Example 1: Tampilkan List User (Admin)

```dart
class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final users = await UserService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          title: Text(user.email),
          subtitle: Text(user.roleLabel),
          trailing: Switch(
            value: user.isActive,
            onChanged: (value) async {
              await UserService.updateUserStatus(user.id, value);
              _loadUsers(); // Reload
            },
          ),
        );
      },
    );
  }
}
```

### Example 2: Update Role User

```dart
Future<void> _changeUserRole(String userId, UserRole newRole) async {
  try {
    await UserService.updateUserRole(userId, newRole);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role berhasil diubah')),
    );
    
    // Reload user list
    _loadUsers();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

// Di widget
DropdownButton<UserRole>(
  value: user.role,
  items: [
    DropdownMenuItem(
      value: UserRole.admin,
      child: Text('Admin'),
    ),
    DropdownMenuItem(
      value: UserRole.kasir,
      child: Text('Kasir'),
    ),
  ],
  onChanged: (newRole) {
    if (newRole != null) {
      _changeUserRole(user.id, newRole);
    }
  },
)
```

### Example 3: Check Permission di Widget

```dart
class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Hanya tampilkan tombol jika admin
    if (!authProvider.isAdmin) {
      return SizedBox.shrink(); // Hide widget
    }
    
    return ElevatedButton(
      onPressed: () => context.go('/settings'),
      child: Text('Pengaturan'),
    );
  }
}
```

---

## 🚨 Error Handling

### Common Errors

#### 1. "permission denied for table users"
**Penyebab:** User bukan admin mencoba akses data yang tidak boleh.

**Solusi:** Cek role sebelum panggil method admin-only.

```dart
final authProvider = context.read<AuthProvider>();

if (authProvider.isAdmin) {
  // Safe to call admin methods
  await UserService.getAllUsers();
} else {
  // Show error
  print('Anda tidak punya akses');
}
```

#### 2. "User not found"
**Penyebab:** User ID tidak valid atau user sudah dihapus.

**Solusi:** Selalu cek null.

```dart
final user = await UserService.getUserById(userId);

if (user == null) {
  print('User tidak ditemukan');
  return;
}

// Lanjutkan proses
```

#### 3. "Cannot create user"
**Penyebab:** Menggunakan anon key, bukan service_role key.

**Solusi:** Create user via Supabase Dashboard atau Edge Function.

---

## 🔐 Security Notes

### DO ✅
- Cek role user sebelum tampilkan UI admin
- Validate input sebelum kirim ke service
- Handle error dengan baik
- Log activity untuk audit

### DON'T ❌
- Jangan expose service_role key ke client
- Jangan trust client-side validation saja
- Jangan hardcode user ID di code
- Jangan hapus user yang sedang login

---

## 📚 Related Models

### User Model

```dart
class User {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Getters
  bool get isAdmin => role == UserRole.admin;
  bool get isKasir => role == UserRole.kasir;
  String get displayName => fullName ?? email.split('@').first;
  String get roleLabel => role.label;
}
```

### UserRole Enum

```dart
enum UserRole {
  admin('admin', 'Admin'),
  kasir('kasir', 'Kasir');

  final String value;
  final String label;
  
  const UserRole(this.value, this.label);
}
```

---

## 🧪 Testing Commands

### Check Current User
```dart
final authProvider = context.read<AuthProvider>();
print('Current user: ${authProvider.currentUser?.email}');
print('Role: ${authProvider.currentUser?.roleLabel}');
print('Is Admin: ${authProvider.isAdmin}');
```

### Test RLS Policies
```sql
-- Di Supabase SQL Editor

-- Login sebagai user tertentu (ganti dengan JWT token)
SET request.jwt.claim.sub = 'user-uuid-here';

-- Test query
SELECT * FROM users;
-- Harusnya hanya return row user tersebut (kecuali admin)
```

---

**Last Updated:** 2024  
**Version:** 1.0
