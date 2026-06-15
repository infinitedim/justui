import 'package:file/local.dart';
import 'package:just_ui_cli/just_ui_cli.dart';

void main(List<String> arguments) async {
  await runCli(arguments, const LocalFileSystem());
}
