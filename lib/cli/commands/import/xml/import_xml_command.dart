import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:wise_converter/cli/commands/import/base_import_command.dart';
import 'package:wise_converter/cli/exceptions/run_exception.dart';
import 'package:wise_converter/src/converter/xml_to_csv_converter.dart';

/// Command to convert XML to CVS for import in Wise.
class ImportXmlCommand extends BaseImportCommand {
  static const _argPath = 'path';

  ImportXmlCommand()
      : super(
          'xml',
          'Converts XML to CVS for import in Wise.',
        ) {
    argParser.addOption(
      _argPath,
      abbr: 'p',
      help: 'Imported XML file path',
      valueHelp: 'XML_FILE_PATH',
    );
  }

  @override
  Future<int> run() async {
    final args = argResults!;
    final path = args[_argPath] as String?;

    if (path == null) {
      return error(1, message: 'XML file path is required.');
    }

    try {
      final xmlPath = path;
      final csvPath = p.setExtension(path, '.csv');

      final converter = XmlToCsvConverter();
      final output = await converter.convert(File(xmlPath), csvPath);
      return success(message: 'Successfully converted to ${output.path}');
    } on RunException catch (e) {
      return exception(e);
    } catch (e, st) {
      printVerbose('Exception: $e\n$st');
      return error(2, message: 'Failed by: $e');
    }
  }
}
