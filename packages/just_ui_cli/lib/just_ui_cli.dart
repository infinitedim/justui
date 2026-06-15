import 'dart:io' as io;
import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'src/commands/add_command.dart';
import 'src/commands/diff_command.dart';
import 'src/commands/init_command.dart';
import 'src/commands/list_command.dart';
import 'src/utils/logger.dart';

export 'src/commands/add_command.dart';
export 'src/commands/diff_command.dart';
export 'src/commands/init_command.dart';
export 'src/commands/list_command.dart';
export 'src/config/justui_config.dart';
export 'src/registry/registry_client.dart';
export 'src/utils/logger.dart';
export 'src/utils/pubspec_editor.dart';

/// Executes the CLI with the provided arguments and target file system.
Future<void> runCli(List<String> arguments, FileSystem fileSystem) async {
  final runner = CommandRunner<void>(
    'justui',
    'JustUI CLI - Scaffolding and copy-paste component tool for Flutter.',
  )
    ..addCommand(InitCommand(fileSystem))
    ..addCommand(AddCommand(fileSystem))
    ..addCommand(ListCommand(fileSystem))
    ..addCommand(DiffCommand(fileSystem));

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    JustLogger.error(e.message);
    JustLogger.stdout(e.usage);
    io.exitCode = 64;
  } catch (e) {
    JustLogger.error(e.toString());
    io.exitCode = 1;
  }
}
