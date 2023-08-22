import 'package:test/test.dart';
import 'package:wise_toolkit/wise_toolkit.dart';

part 'batch_payment_csv_test.data.dart';

void main() {
  group('BatchPaymentCsv', () {
    group('toSting()', () {
      test('should return valid Wise CSV string', () {
        final csv = BatchPaymentCsv();

        csv.addPayment(
          recipientName: "RS PREHODNI DAVČNI PODRAČUN",
          paymentDesc: "Dohodnina (7.23)",
          iban: "SI56011008881000030",
          amount: 35102,
          currency: Currency.eur,
          purposeCode: "TAXS",
          paymentRefId: "SI1935980621-40002",
        );
        csv.addPayment(
          recipientName: "RS PREHODNI DAVČNI PODRAČUN",
          paymentDesc: "Prispevek za ZZ (7.23)",
          iban: "SI56011008883000073",
          amount: 31842,
          currency: Currency.eur,
          purposeCode: "LBRI",
          paymentRefId: "SI1935980621-45004",
        );
        csv.addPayment(
          recipientName: "Roman Volkov",
          paymentDesc: "Placa (mat.str.) (7/23) Roman Volkov",
          iban: "BE08967536012345",
          amount: 16716,
          currency: Currency.eur,
          purposeCode: "PRCP",
          paymentRefId: "RF040",
        );
        csv.addPayment(
          recipientName: "Aleksandra Volkova",
          paymentDesc: "Placa (7/23) Aleksandra Volkova",
          iban: "LT383250088588112345",
          amount: 74680,
          currency: Currency.eur,
          purposeCode: "SALA",
          paymentRefId: "RF040",
        );

        final str = csv.toString();

        expect(str, expectedCsv1);
      });
    });
  });
}
