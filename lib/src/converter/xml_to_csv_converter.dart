import 'dart:io';

import 'package:wise_toolkit/wise_toolkit.dart';
import 'package:xml/xml.dart';

/// Convert SEPA XML to Wise CSV
/// https://docs.oracle.com/cd/E16582_01/doc.91/e15104/fields_sepa_pay_file_appx.htm#EOAEL01692
class XmlToCsvConverter {
  Future<File> convert(File xmlFile, String destPath) async {
    final XmlDocument xml;
    try {
      xml = XmlDocument.parse(await xmlFile.readAsString());
    } catch (e) {
      throw Exception('Failed load XML ${xmlFile.path}: $e');
    }

    final csv = BatchPaymentCsv();
    final paymentsInfo = xml.getPaymentInformationList();
    for (var paymentNode in paymentsInfo) {
      // Credit Transfer Transaction Information
      final creditNode = paymentNode.getElement('CdtTrfTxInf')!;
      final creditorNode = creditNode.getElement('Cdtr')!;
      final creditorAccNode = creditNode.getElement('CdtrAcct')!;

      final remittanceInfoNode =
          creditNode.getElement('RmtInf')!.getElement('Strd')!;
      final paymentDesc =
          remittanceInfoNode.getElement('AddtlRmtInf')!.innerText;
      final paymentRefId = remittanceInfoNode
          .getElement('CdtrRefInf')!
          .getElement('Ref')!
          .innerText;

      final amountNode = creditNode.getElement('Amt')!.getElement('InstdAmt')!;
      final currencyCode = amountNode.getAttribute('Ccy')!;

      final currency = Currency.byCode(currencyCode);
      if (currency == null) {
        throw Exception("Currency <$currencyCode> are not supported");
      }

      final purposeCode =
          creditNode.getElement('Purp')!.getElement('Cd')!.innerText;

      final recipientName = creditorNode.getElement('Nm')!.innerText;

      final amountStr = amountNode.innerText;
      final amount = WTUtils.parseAmount(amountStr, currency.minorDigits);
      if (amount == null) {
        throw Exception(
            "Failed to parse amount <$amountStr> (currency $currencyCode)");
      }

      final iban =
          creditorAccNode.getElement('Id')!.getElement('IBAN')!.innerText;

      csv.addPayment(
        recipientName: recipientName,
        paymentDesc: paymentDesc,
        iban: iban,
        amount: amount,
        currency: currency,
        purposeCode: purposeCode,
        paymentRefId: paymentRefId,
      );
    }

    final output = File(destPath);
    await output.writeAsString(csv.toString());

    return output;
  }
}

extension _SepaXmlDocumentExtension on XmlDocument {
  XmlElement get root => findAllElements('CstmrCdtTrfInitn').first;
  // XmlElement get header => root.findAllElements('GrpHdr').first;

  Iterable<XmlElement> getPaymentInformationList() =>
      root.findAllElements('PmtInf');
}
