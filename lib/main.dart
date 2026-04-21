import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'providers/customer_provider.dart';
import 'providers/service_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/report_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const LaundryKuApp());
}

class LaundryKuApp extends StatelessWidget {
  const LaundryKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ParfumProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const LaundryApp(),
    );
  }
}
