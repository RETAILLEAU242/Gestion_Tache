import '../../exceptions/task_exceptions.dart';
import '../../repository/task_repository.dart';
import 'cli_command.dart';
import 'exit_codes.dart';

/// Commande `done` — marque une tâche comme terminée.
class DoneCommand implements CliCommand {
  final TaskRepository repository;

  DoneCommand(this.repository);

  @override
  String get name => 'done';

  @override
  String get description => 'done <id>';

  @override
  int execute(List<String> args) {
    if (args.isEmpty) {
      print('Erreur: identifiant manquant.');
      print('Usage: $description');
      return ExitCodes.usageError;
    }

    try {
      repository.markDone(args[0]);
      print('Tâche "${args[0]}" marquée comme terminée.');
      return ExitCodes.success;
    } on TaskNotFoundException catch (e) {
      print('Erreur: ${e.message}');
      return ExitCodes.generalError;
    } on StorageException catch (e) {
      print('Erreur de stockage: ${e.message}');
      return ExitCodes.ioError;
    }
  }
}
