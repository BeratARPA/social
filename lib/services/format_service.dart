import 'package:intl/intl.dart';
import 'package:social/helpers/app_storage.dart';

class FormatService {
  // 🔹 Suffix tanımları (locale -> map)
  static final Map<String, Map<String, String>> _suffixes = {
    "en": {
      "K": "K", // Thousand
      "M": "M", // Million
      "B": "B", // Billion
    },
    "tr": {
      "K": "B", // Bin
      "M": "M", // Milyon
      "B": "Mr", // Milyar
    },
  };

  /// 🔹 Sayı kısaltma (1K, 1M vb.)
  static String formatCount(int count) {
    final suffixMap =
        _suffixes[AppStorage.getString(AppStorage.localeKey)] ??
        _suffixes["en"]!;

    if (count >= 1000000000) {
      return _formatWithSuffix(count, 1000000000, suffixMap["B"]!);
    } else if (count >= 1000000) {
      return _formatWithSuffix(count, 1000000, suffixMap["M"]!);
    } else if (count >= 1000) {
      return _formatWithSuffix(count, 1000, suffixMap["K"]!);
    } else {
      return count.toString();
    }
  }

  /// 🔹 Tarih formatlama
  static String formatDate(DateTime date, {String pattern = "dd.MM.yyyy"}) {
    return DateFormat(
      pattern,
      AppStorage.getString(AppStorage.localeKey),
    ).format(date);
  }

  /// 🔹 Para formatlama
  static String formatCurrency(num amount, {String symbol = "₺"}) {
    final formatter = NumberFormat.currency(
      locale: AppStorage.getString(AppStorage.localeKey),
      symbol: symbol,
    );
    return formatter.format(amount);
  }

  /// 🔹 İç helper
  static String _formatWithSuffix(int count, int divisor, String suffix) {
    double value = count / divisor;

    // Eğer tam sayıysa ".0" gösterme
    if (value % 1 == 0) {
      return value.toInt().toString() + suffix;
    }
    return value.toStringAsFixed(1) + suffix;
  }
}
