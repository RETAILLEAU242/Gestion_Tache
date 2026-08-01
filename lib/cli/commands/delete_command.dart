import '../../exceptions/task_exceptions.dart';
import '../../repository/task_repository.dart';
import 'cli_command.dart';
import 'exit_codes.dart';

/// Commande `delete` — supprime une tâche.
class DeleteCommand implements CliCommand {
  final TaskRepository repository;

  DeleteCommand(this.repository);

  @override
  String get name => 'delete';

  @override
  String get description => 'delete <id>';

  @override
  int execute(List<String> args) {
    if (args.isEmpty) {
      print('Erreur: identifiant manquant.');
      print('Usage: $description');
      return ExitCodes.usageError;
    }

    try {
      repository.delete(args[0]);
      print('Tâche "${args[0]}" supprimée.');
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
