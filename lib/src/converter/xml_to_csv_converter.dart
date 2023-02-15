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
      const taxesCodes = ['TAXS', 'LBRI'];
      const employeePaymentsCodes = ['SALA', 'PRCP'];

      final String paymentReference;

      if (taxesCodes.contains(purposeCode)) {
        // For taxes it's important to provide paymentRefId
        final restLen = maxPaymentReferenceLen - paymentRefId.length - 1;
        if (restLen >= paymentDesc.length) {
          paymentReference = paymentDesc + ' ' + paymentRefId;
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

          for (var prefix in descMap.keys) {
            if (paymentDesc.startsWith(prefix)) {
              modifiedPaymentDesc = descMap[prefix]!;
              break;
            }
          }

          if (modifiedPaymentDesc.length <= restLen) {
            paymentReference = modifiedPaymentDesc + ' ' + paymentRefId;
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
      final receiverType = employeePaymentsCodes.contains(purposeCode)
          ? 'PERSON'
          : 'INSTITUTION';
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
  // XmlElement get header => root.findAllElements('GrpHdr').first;

  Iterable<XmlElement> getPaymentInformationList() =>
      root.findAllElements('PmtInf');
}
