import 'dart:convert';
import 'dart:io';

import '../models/task.dart';
import '../models/priority.dart';
import '../exceptions/task_exceptions.dart';
import 'repository.dart';

/// Critères de tri disponibles pour lister les tâches.
enum SortBy { priority, deadline }

/// Implémentation de [Repository]<[Task]> qui persiste les données
/// dans un fichier JSON local.
class TaskRepository implements Repository<Task> {
  final String filePath;
  final List<Task> _tasks = [];

  TaskRepository(this.filePath) {
    load();
  }

  @override
  void add(Task item) {
    if (_tasks.any((t) => t.id == item.id)) {
      throw InvalidTaskDataException('Une tâche avec l\'id "${item.id}" existe déjà.');
    }
    _tasks.add(item);
    save();
  }

  @override
  List<Task> getAll() => List.unmodifiable(_tasks);

  /// Retourne les tâches triées selon [sortBy].
  List<Task> getAllSorted(SortBy sortBy) {
    final copy = List<Task>.from(_tasks);
    if (sortBy == SortBy.priority) {
      copy.sort();
    } else {
      copy.sort(Task.compareByDeadline);
    }
    return copy;
  }

  @override
  Task getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      throw TaskNotFoundException('Aucune tâche trouvée avec l\'id "$id".');
    }
  }

  @override
  void update(Task item) {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException('Aucune tâche trouvée avec l\'id "${item.id}".');
    }
    _tasks[index] = item;
    save();
  }

  /// Marque une tâche comme terminée par son [id].
  void markDone(String id) {
    final task = getById(id);
    task.markDone();
    save();
  }

  @override
  void delete(String id) {
    final existed = _tasks.any((t) => t.id == id);
    if (!existed) {
      throw TaskNotFoundException('Aucune tâche trouvée avec l\'id "$id".');
    }
    _tasks.removeWhere((t) => t.id == id);
    save();
  }

  @override
  void save() {
    try {
      final file = File(filePath);
      final data = _tasks.map((t) => t.toJson()).toList();
      file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      throw StorageException('Impossible d\'écrire le fichier "$filePath": $e');
    }
  }

  @override
  void load() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        _tasks.clear();
        return;
      }
      final content = file.readAsStringSync();
      if (content.trim().isEmpty) {
        _tasks.clear();
        return;
      }
      final decoded = jsonDecode(content) as List<dynamic>;
      _tasks
        ..clear()
        ..addAll(decoded.map((e) => taskFromJson(e as Map<String, dynamic>)));
    } on FormatException catch (e) {
      throw StorageException('Fichier JSON invalide "$filePath": $e');
    } catch (e) {
      throw StorageException('Impossible de lire le fichier "$filePath": $e');
    }
  }
}

/// Génère un identifiant simple basé sur l'horodatage.
String generateTaskId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(36);

// Ré-export pratique pour les consommateurs de ce fichier.
typedef PriorityType = Priority;
