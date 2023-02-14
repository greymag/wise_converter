import 'package:args/command_runner.dart';
import 'package:wise_converter/cli/commands/import/import_command.dart';

import 'commands/wiseman_command.dart';

class WisemanCommandRunner extends CommandRunner<int> {
  WisemanCommandRunner()
      : super('warren', 'A command tools for Android development.') {
    <WisemanCommand>[
      ImportCommand(),
    ].forEach(addCommand);
  }
}
