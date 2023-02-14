import 'package:wise_converter/cli/commands/wiseman_command.dart';

import 'xml/import_xml_command.dart';

/// Commands convert imported files.
class ImportCommand extends WisemanCommand {
  ImportCommand()
      : super('import', 'Convert import files', subcommands: [
          ImportXmlCommand(),
        ]);

  @override
  Future<int> run() async {
    printUsage();
    return 0;
  }
}
