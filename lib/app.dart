import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/transaction/new_transaction_screen.dart';
import 'screens/transaction/pick_customer_screen.dart';
import 'screens/transaction/pick_service_screen.dart';
import 'screens/transaction/transaction_detail_screen.dart';
import 'screens/customer/customer_list_screen.dart';
import 'screens/customer/add_customer_screen.dart';
import 'screens/service/service_list_screen.dart';
import 'screens/service/add_service_screen.dart';
import 'screens/service/edit_service_screen.dart';
import 'screens/service/add_service_type_screen.dart';
import 'screens/report/report_menu_screen.dart';
import 'screens/report/transaction_report_screen.dart';
import 'screens/report/transaction_history_screen.dart';
import 'screens/report/saw_calculation_screen.dart';
import 'screens/report/saw_detail_screen.dart';
import 'screens/report/excel_export_screen.dart';
import 'screens/parfum/parfum_screen.dart';
import 'screens/parfum/add_parfum_screen.dart';
import 'screens/settings/store_settings_screen.dart';
import 'screens/account/account_screen.dart';
import 'screens/payment_method/payment_method_screen.dart';
import 'screens/payment_method/add_payment_method_screen.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  // Daftar route yang hanya bisa diakses admin
  final adminOnlyRoutes = [
    '/services',
    '/services/add',
    '/services/edit',
    '/services/add-type',
    '/parfum',
    '/parfum/add',
    '/parfum/edit',
    '/payment-methods',
    '/payment-methods/add',
    '/settings',
    '/reports/saw',
    '/reports/saw/detail',
  ];

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';
      final currentPath = state.matchedLocation;

      if (!isLoggedIn && !isGoingToAuth) {
        // Redirect unauthenticated users to login
        return '/login';
      }

      if (isLoggedIn && isGoingToAuth) {
        // Redirect authenticated users away from login
        return '/';
      }

      // Role-based access control
      if (isLoggedIn && !authProvider.isAdmin) {
        // Check jika kasir mencoba akses route admin-only
        final isAccessingAdminRoute = adminOnlyRoutes.any((route) => 
          currentPath.startsWith(route)
        );
        
        if (isAccessingAdminRoute) {
          // Redirect kasir ke dashboard jika mencoba akses admin route
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/transaction/new',
        builder: (context, state) => const NewTransactionScreen(),
      ),
      GoRoute(
        path: '/transaction/pick-customer',
        builder: (context, state) => const PickCustomerScreen(),
      ),
      GoRoute(
        path: '/transaction/pick-service',
        builder: (context, state) => const PickServiceScreen(),
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/add',
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServiceListScreen(),
      ),
      GoRoute(
        path: '/services/add',
        builder: (context, state) => const AddServiceScreen(),
      ),
      GoRoute(
        path: '/services/edit/:id',
        builder: (context, state) => EditServiceScreen(
          serviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/services/add-type',
        builder: (context, state) => const AddServiceTypeScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportMenuScreen(),
      ),
      GoRoute(
        path: '/reports/transactions',
        builder: (context, state) => const TransactionReportScreen(),
      ),
      GoRoute(
        path: '/reports/history',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/reports/saw',
        builder: (context, state) => const SawCalculationScreen(),
      ),
      GoRoute(
        path: '/reports/saw/detail',
        builder: (context, state) => const SawDetailScreen(),
      ),
      GoRoute(
        path: '/reports/excel-export',
        builder: (context, state) => const ExcelExportScreen(),
      ),
      GoRoute(
        path: '/parfum/add',
        builder: (context, state) => const AddParfumScreen(),
      ),
      GoRoute(
        path: '/parfum/edit/:id',
        builder: (context, state) => EditParfumScreen(
          parfumId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parfum',
        builder: (context, state) => const ParfumScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const StoreSettingsScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: '/payment-methods/add',
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),
    ],
  );
}

class LaundryApp extends StatefulWidget {
  const LaundryApp({super.key});

  @override
  State<LaundryApp> createState() => _LaundryAppState();
}

class _LaundryAppState extends State<LaundryApp> {
  late final GoRouter _router;
  Timer? _inactivityTimer;
  static const int _inactivityTimeoutMinutes = 15; // Log out setelah 15 menit tidak aktif

  @override
  void initState() {
    super.initState();
    // Watch is not allowed in initState, use read
    final authProvider = context.read<AuthProvider>();
    _router = createAppRouter(authProvider);
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: _inactivityTimeoutMinutes), _logOutUser);
  }

  void _logOutUser() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      authProvider.signOut();
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LaundryKu Kasir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _resetInactivityTimer(),
          onPointerSignal: (_) => _resetInactivityTimer(),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
