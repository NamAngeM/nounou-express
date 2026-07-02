import 'package:intl/intl.dart';

class AppFormatters {
  static String formatFCFA(double amount) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatDistance(double km) {
    if (km < 1) {
      return "${(km * 1000).toInt()} m";
    }
    return "${km.toStringAsFixed(1)} km";
  }

  static String formatChatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (msgDate == yesterday) {
      return "Hier";
    } else if (msgDate.isAfter(lastWeek)) {
      return DateFormat('EEE', 'fr_FR').format(date);
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }
}
