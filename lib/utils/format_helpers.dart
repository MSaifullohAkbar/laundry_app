import 'package:intl/intl.dart';

class FormatHelper {
  /// Formats a double value to Indonesian Rupiah, e.g., Rp 15.000
  static String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Formats a double value to Indonesian numeric format without prefix symbol, e.g., 15.000
  static String formatSimplePrice(double price) {
    return NumberFormat.decimalPattern('id_ID').format(price);
  }

  /// Formats a DateTime object to Indonesian format, e.g., 22 Mei 2026, 17:40
  static String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  }
}
