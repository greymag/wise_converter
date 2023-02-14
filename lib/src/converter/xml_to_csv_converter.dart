import 'dart:io';

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

    final csv = StringBuffer(
        "name,recipientEmail,paymentReference,receiverType,amountCurrency,amount,sourceCurrency,targetCurrency,IBAN");

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
      final currency = amountNode.getAttribute('Ccy')!;

      final purposeCode =
          creditNode.getElement('Purp')!.getElement('Cd')!.innerText;

      final recipientName = creditorNode.getElement('Nm')!.innerText;
      final recipientEmail = '';

      const maxPaymentReferenceLen = 35;
      final restLen = maxPaymentReferenceLen - paymentRefId.length - 1;
      final String paymentReference;
      if (restLen < 5) {
        paymentReference = paymentRefId;
      } else if (paymentDesc.length <= restLen) {
        paymentReference = paymentDesc + ' ' + paymentRefId;
      } else {
        paymentReference =
            paymentDesc.substring(0, restLen) + ' ' + paymentRefId;
      }

      // TODO: some accurate way to define receiverType (may be Purp + name? or interactive mode for choosing manually)
      final receiverType =
          ['SALA', 'PRCP'].contains(purposeCode) ? 'PERSON' : 'INSTITUTION';
      final amountCurrency = 'source';
      final amount = amountNode.innerText;
      final sourceCurrency = currency;
      final targetCurrency = currency;
      final iban =
          creditorAccNode.getElement('Id')!.getElement('IBAN')!.innerText;

      _writeCsvLine(csv, [
        recipientName,
        recipientEmail,
        paymentReference,
        receiverType,
        amountCurrency,
        amount,
        sourceCurrency,
        targetCurrency,
        iban
      ]);
    }

    final output = File(destPath);
    await output.writeAsString(csv.toString());

    return output;
  }

  void _writeCsvLine(StringBuffer csv, List<Object> items) {
    csv.writeln();
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
      csv
        ..write('"')
        ..write(processedItem)
        ..write('",');
    }
  }
}

extension _SepaXmlDocumentExtension on XmlDocument {
  XmlElement get root => findAllElements('CstmrCdtTrfInitn').first;
  XmlElement get header => root.findAllElements('GrpHdr').first;

  Iterable<XmlElement> getPaymentInformationList() =>
      root.findAllElements('PmtInf');

  // void forEachResource(void Function(XmlElement child) callback) {
  //   for (final child in resources.children) {
  //     if (child is XmlElement) callback(child);
  //   }
  // }
}

// extension XmlElementExtension on XmlElement {
//   String get attributeName => getAttribute('name')!;
// }
