import '../../models/task.dart';
import '../../models/priority.dart';
import '../../exceptions/task_exceptions.dart';
import '../../repository/task_repository.dart'; // TaskRepository + generateTaskId()
import 'cli_command.dart';
import 'exit_codes.dart';
import 'option_parser.dart';

/// Commande `add` — ajoute une nouvelle tâche.
class AddCommand implements CliCommand {
  final TaskRepository repository;

  AddCommand(this.repository);

  @override
  String get name => 'add';

  @override
  String get description =>
      'add --title="Titre" [--priority=low|medium|high] [--deadline=AAAA-MM-JJ] [--urgent]';

  @override
  int execute(List<String> args) {
    final options = parseOptions(args);

    final title = options['title'];
    if (title == null || title.trim().isEmpty) {
      print('Erreur: l\'option --title est obligatoire.');
      print('Usage: $description');
      return ExitCodes.usageError;
    }

    final Priority priority;
    try {
      priority = Priority.fromString(options['priority'] ?? 'medium');
    } on FormatException catch (e) {
      print('Erreur: ${e.message}');
      return ExitCodes.usageError;
    }

    DateTime? deadline;
    final deadlineStr = options['deadline'];
    if (deadlineStr != null && deadlineStr.isNotEmpty) {
      try {
        deadline = DateTime.parse(deadlineStr);
      } catch (_) {
        print('Erreur: format de date invalide pour --deadline: "$deadlineStr" '
            '(attendu: AAAA-MM-JJ).');
        return ExitCodes.usageError;
      }
    }

    final isUrgent = options.containsKey('urgent');
    final id = generateTaskId();

    try {
      final task = isUrgent
          ? UrgentTask(id: id, title: title, priority: priority, deadline: deadline)
          : SimpleTask(id: id, title: title, priority: priority, deadline: deadline);

      repository.add(task);
      print('Tâche ajoutée: $task');
      return ExitCodes.success;
    } on InvalidTaskDataException catch (e) {
      print('Erreur: ${e.message}');
      return ExitCodes.generalError;
    } on StorageException catch (e) {
      print('Erreur de stockage: ${e.message}');
      return ExitCodes.ioError;
    }
  }
}
