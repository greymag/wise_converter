import 'package:args/command_runner.dart';
import 'package:wise_converter/cli/out/out.dart' as out;
import 'package:wise_converter/cli/runner.dart';

Future<int?> run(List<String> args) async {
  try {
    return await WisemanCommandRunner().run(args);
  } on UsageException catch (e) {
    out.exception(e);
    return 64;
  } catch (e) {
    out.exception(e);
    return -1;
  }
}
