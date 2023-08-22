import 'package:list_ext/list_ext.dart';

enum Currency {
  eur(code: 'EUR');

  static Currency? byCode(String code) =>
      Currency.values.firstWhereOrNull((e) => e.code == code);

  final String code;
  final int minorDigits;

  const Currency({
    required this.code,
    this.minorDigits = 2,
  });
}
