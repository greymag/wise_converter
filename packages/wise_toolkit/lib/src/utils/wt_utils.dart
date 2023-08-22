import 'dart:math';

class WTUtils {
  static int? parseAmount(String str, int minorDigits) {
    final parts = str.split('.');
    if (parts.length > 2) return null;

    final wholePart =
        _parseStrToInt(parts.first + ''.padLeft(minorDigits, '0'));
    final fractionalPart = parts.length > 1
        ? _parseStrToInt(normalizeFractionalPart(parts[1], minorDigits))
        : 0;

    if (wholePart == null || fractionalPart == null) return null;

    return wholePart + fractionalPart;
  }

  static String getAmountString(int amount, int minorDigits) {
    final base = pow(10, minorDigits);
    final wholePart = amount ~/ base;
    final fractionalPart = amount % base;

    if (fractionalPart > 0) {
      var fractionalPartStr = fractionalPart.toString();

      while (fractionalPartStr.length < minorDigits) {
        fractionalPartStr = '0$fractionalPartStr';
      }

      return '$wholePart.$fractionalPartStr';
    } else {
      return wholePart.toString();
    }
  }

  static String normalizeFractionalPart(String str, int len) {
    final strLen = str.length;
    return strLen > len ? str.substring(0, len) : str.padRight(len, '0');
  }

  static int? _parseStrToInt(String str) {
    final val = int.tryParse(str);
    return val == null || val.toString().padLeft(str.length, '0') != str
        ? null
        : val;
  }

  WTUtils._();
}
