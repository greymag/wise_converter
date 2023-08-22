part of 'batch_payment_csv_test.dart';

const expectedCsv1 = '''
name,recipientEmail,paymentReference,receiverType,amountCurrency,amount,sourceCurrency,targetCurrency,IBAN
"RS PREHODNI DAVCNI PODRACUN","","Dohodnina (7.23) SI1935980621-40002","INSTITUTION","source","351.02","EUR","EUR","SI56011008881000030",
"RS PREHODNI DAVCNI PODRACUN","","PrispevekZZ SI1935980621-45004","INSTITUTION","source","318.42","EUR","EUR","SI56011008883000073",
"Roman Volkov","","Placa (mat.str.) (7/23) Roman Volko","PERSON","source","167.16","EUR","EUR","BE08967536012345",
"Aleksandra Volkova","","Placa (7/23) Aleksandra Volkova","PERSON","source","746.80","EUR","EUR","LT383250088588112345",''';
