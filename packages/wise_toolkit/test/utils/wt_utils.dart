import 'package:test/test.dart';
import 'package:tuple/tuple.dart';
import 'package:wise_toolkit/wise_toolkit.dart';

void main() {
  group('WTUtils', () {
    group('getAmountString()', () {
      const data = [
        Tuple3(12345, 2, '123.45'),
        Tuple3(56789, 1, '5678.9'),
        Tuple3(54321, 0, '54321'),
        Tuple3(235467, 3, '235.467'),
        Tuple3(1234, 4, '0.1234'),
        Tuple3(23, 5, '0.00023'),
      ];
      test('should return amount in expected format', () {
        for (var d in data) {
          final res = WTUtils.getAmountString(d.item1, d.item2);
          expect(res, d.item3);
        }
      });
    });

    group('parseAmount()', () {
      const data = [
        Tuple3('351.02', 2, 35102),
        Tuple3('351.02.2', 2, null),
        Tuple3('351,02', 2, null),
        Tuple3('3 51.02', 2, null),
        Tuple3('13.07', 2, 1307),
        Tuple3('746.80', 2, 74680),
        Tuple3('12.3', 2, 1230),
        Tuple3('12.3', 3, 12300),
        Tuple3('45', 2, 4500),
        Tuple3('67.00', 2, 6700),
        Tuple3('89.000000', 2, 8900),
      ];
      test('should return expected amount value', () {
        for (var d in data) {
          final res = WTUtils.parseAmount(d.item1, d.item2);
          expect(res, d.item3);
        }
      });
    });
  });
}
