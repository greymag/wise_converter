import 'package:wise_converter/cli/commands/wiseman_command.dart';

abstract class BaseImportCommand extends WisemanCommand {
  BaseImportCommand(String name, String description,
      {List<WisemanCommand>? subcommands})
      : super(name, description, subcommands: subcommands);
}
