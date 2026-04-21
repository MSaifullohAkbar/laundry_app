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
import 'screens/report/report_menu_screen.dart';
import 'screens/report/transaction_report_screen.dart';
import 'screens/report/transaction_history_screen.dart';
import 'screens/parfum/parfum_screen.dart';
import 'screens/settings/store_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
      path: '/parfum',
      builder: (context, state) => const ParfumScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const StoreSettingsScreen(),
    ),
  ],
);

class LaundryApp extends StatelessWidget {
  const LaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LaundryKu Kasir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
