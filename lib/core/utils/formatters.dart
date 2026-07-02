import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class AppFormatters {
  static String formatFCFA(double amount) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: AppConstants.currency,
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

  /// Format court pour les listes et cartes (ex: "3 juil 2026").
  static String formatShortDate(DateTime date) {
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format avec jour de la semaine (ex: "Lun. 3 janv.").
  static String formatDateWithWeekday(DateTime date) {
    const weekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    final wd = weekdays[date.weekday - 1];
    final mo = months[date.month - 1];
    return '$wd ${date.day} $mo';
  }
}
