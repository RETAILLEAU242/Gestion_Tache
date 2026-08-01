import 'dart:io';

import 'package:task_cli/cli/cli.dart';
import 'package:task_cli/repository/task_repository.dart';

void main(List<String> args) {
  final repository = TaskRepository('tasks.json');
  final cli = Cli(repository);
  final exitCode = cli.run(args);
  exit(exitCode);
}
