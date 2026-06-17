import 'package:intl/intl.dart';

class NumberFormatter {
  static String format(double value) {
    if (value >= 1e18) return '\$${(value / 1e18).toStringAsFixed(2)}Qi';
    if (value >= 1e15) return '\$${(value / 1e15).toStringAsFixed(2)}Qa';
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(1)}K';
    return '\$${value.toStringAsFixed(0)}';
  }

  static String formatNoSign(double value) {
    final s = format(value);
    return s.startsWith('\$') ? s.substring(1) : s;
  }

  static String formatPerSec(double value) {
    return '+${format(value)}/сек';
  }

  static String formatCompact(double value) {
    final f = NumberFormat.compact(locale: 'en_US');
    return '\$${f.format(value)}';
  }
}
