import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/service_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/report_provider.dart';
import 'providers/saw_provider.dart';
import 'providers/parfum_provider.dart';
import 'providers/payment_method_provider.dart';
import 'providers/store_settings_provider.dart';
import 'providers/bluetooth_printer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat file .env
  await dotenv.load(fileName: ".env");

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await initializeDateFormatting('id_ID', null);
  runApp(const LaundryKuApp());
}


class LaundryKuApp extends StatelessWidget {
  const LaundryKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ParfumProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SawProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodProvider()),
        ChangeNotifierProvider(create: (_) => StoreSettingsProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothPrinterProvider()..loadSettings()),
      ],
      child: const LaundryApp(),
    );
  }
}
