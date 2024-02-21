import 'package:wise_toolkit/wise_toolkit.dart';

class BatchPaymentCsv {
  final _csv = StringBuffer(
      "name,recipientEmail,paymentReference,receiverType,amountCurrency,amount,sourceCurrency,targetCurrency,IBAN");

  void addPayment({
    required String recipientName,
    required String paymentDesc,
    required String iban,
    required int amount,
    required Currency currency,
    required String purposeCode,
    required String paymentRefId,
    String recipientEmail = '',
  }) {
    const maxPaymentReferenceLen = 35;
    // TODO: "Plačilo DDV za: 7-7.2023" short to "PlaciloDDV 7.23 %reference%"
    const taxesCodes = ['TAXS', 'LBRI', 'VATX'];
    const employeePaymentsCodes = ['SALA', 'PRCP', 'BONU'];

    final String paymentReference;
    if (taxesCodes.contains(purposeCode)) {
      // For taxes it's important to provide paymentRefId
      final restLen = maxPaymentReferenceLen - paymentRefId.length - 1;
      if (restLen >= paymentDesc.length) {
        paymentReference = '$paymentDesc $paymentRefId';
      } else if (restLen < 5) {
        paymentReference = paymentRefId;
      } else {
        var modifiedPaymentDesc = paymentDesc;
        const descMap = {
          'Prispevek za PIZ': 'PrispevekPIZ',
          'Prispevek za PPD in PB': 'PrispevekPPDinPB',
          'Prispevek za STV': 'PrispevekSTV',
          'Prispevek za ZAP': 'PrispevekZAP',
          'Prispevek za ZZ': 'PrispevekZZ',
        };
        // TODO: Plačilo DDV za: 8.2023 -> PlaciloDDV 8.23 SI1935980621-62006

        for (var prefix in descMap.keys) {
          if (paymentDesc.startsWith(prefix)) {
            modifiedPaymentDesc = descMap[prefix]!;
            break;
          }
        }

        if (modifiedPaymentDesc.length <= restLen) {
          paymentReference = '$modifiedPaymentDesc $paymentRefId';
        } else {
          paymentReference =
              paymentRefId + modifiedPaymentDesc.substring(0, restLen);
        }
      }
    } else {
      paymentReference = paymentDesc.length > maxPaymentReferenceLen
          ? paymentDesc.substring(0, maxPaymentReferenceLen)
          : paymentDesc;
    }

    // TODO: some accurate way to define receiverType (may be Purp + name? or interactive mode for choosing manually)
    final receiverType =
        employeePaymentsCodes.contains(purposeCode) ? 'PERSON' : 'INSTITUTION';

    const amountCurrency = 'source';
    final sourceCurrency = currency.code;
    final targetCurrency = currency.code;

    final amountStr = WTUtils.getAmountString(amount, currency.minorDigits);

    _writeCsvLine([
      recipientName,
      recipientEmail,
      paymentReference,
      receiverType,
      amountCurrency,
      amountStr,
      sourceCurrency,
      targetCurrency,
      iban
    ]);
  }

  @override
  String toString() {
    return _csv.toString();
  }

  void _writeCsvLine(List<Object> items) {
    _csv.writeln();
    for (var item in items) {
      final processedItem = item
          .toString()
          .replaceAll('"', "'")
          .replaceAll('š', 's')
          .replaceAll('Š', 'S')
          .replaceAll('č', 'c')
          .replaceAll('Č', 'C')
          .replaceAll('ż', 'z')
          .replaceAll('Ż', 'z');
      _csv
        ..write('"')
        ..write(processedItem)
        ..write('",');
    }
  }
}
