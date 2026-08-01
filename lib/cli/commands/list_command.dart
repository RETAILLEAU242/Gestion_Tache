import '../../exceptions/task_exceptions.dart';
import '../../repository/task_repository.dart';
import 'cli_command.dart';
import 'exit_codes.dart';
import 'option_parser.dart';

/// Commande `list` — liste toutes les tâches, triées par priorité ou date.
class ListCommand implements CliCommand {
  final TaskRepository repository;

  ListCommand(this.repository);

  @override
  String get name => 'list';

  @override
  String get description => 'list [--sort=priority|date]';

  @override
  int execute(List<String> args) {
    final options = parseOptions(args);
    final sortOption = options['sort'] ?? 'priority';

    if (sortOption != 'priority' && sortOption != 'date') {
      print('Erreur: --sort doit valoir "priority" ou "date" (reçu: "$sortOption").');
      return ExitCodes.usageError;
    }

    final sortBy = sortOption == 'date' ? SortBy.deadline : SortBy.priority;

    try {
      final tasks = repository.getAllSorted(sortBy);
      if (tasks.isEmpty) {
        print('Aucune tâche enregistrée.');
        return ExitCodes.success;
      }
      for (final task in tasks) {
        print(task);
      }
      return ExitCodes.success;
    } on StorageException catch (e) {
      print('Erreur de stockage: ${e.message}');
      return ExitCodes.ioError;
    }
  }
}
