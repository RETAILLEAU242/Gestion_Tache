import 'json_serializable.dart';
import 'priority.dart';
import '../exceptions/task_exceptions.dart';

/// Classe abstraite représentant une tâche.
///
/// Implémente [Comparable] (pour le tri) et [JsonSerializable] (interface)
/// afin d'illustrer à la fois l'héritage et l'implémentation d'interface.
abstract class Task implements Comparable<Task>, JsonSerializable {
  final String id;
  String title;
  Priority priority;
  DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  }) {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('Le titre de la tâche ne peut pas être vide.');
    }
  }

  /// Marque la tâche comme terminée.
  void markDone() {
    isDone = true;
  }

  /// Libellé du type de tâche, redéfini par les sous-classes.
  String get typeLabel;

  /// Tri par défaut : priorité décroissante (high, medium, low).
  @override
  int compareTo(Task other) => other.priority.index.compareTo(priority.index);

  /// Compare deux tâches par date limite (les tâches sans date sont
  /// placées à la fin).
  static int compareByDeadline(Task a, Task b) {
    if (a.deadline == null && b.deadline == null) return 0;
    if (a.deadline == null) return 1;
    if (b.deadline == null) return -1;
    return a.deadline!.compareTo(b.deadline!);
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'isDone': isDone,
        'type': typeLabel,
      };

  @override
  String toString() {
    final status = isDone ? '✔' : '✗';
    final due = deadline != null
        ? ' (échéance: ${deadline!.toIso8601String().split('T').first})'
        : '';
    return '[$status] $id | $title | ${priority.name.toUpperCase()} | $typeLabel$due';
  }
}

/// Tâche standard.
class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  @override
  String get typeLabel => 'Simple';

  factory SimpleTask.fromJson(Map<String, dynamic> json) {
    return SimpleTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

/// Tâche urgente : sous-classe de [Task] illustrant l'héritage.
///
/// Une [UrgentTask] est automatiquement considérée en retard ("overdue")
/// si sa date limite est dépassée, et affiche un avertissement.
class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  /// Une tâche urgente est en retard si elle a une échéance dépassée
  /// et n'est pas terminée.
  bool get isOverdue =>
      !isDone && deadline != null && deadline!.isBefore(DateTime.now());

  @override
  String get typeLabel => 'Urgent';

  @override
  String toString() {
    final base = super.toString();
    return isOverdue ? '$base ⚠️ EN RETARD' : base;
  }

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

/// Fabrique une [Task] concrète à partir de son JSON, en se basant sur
/// le champ `type`.
Task taskFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String? ?? 'Simple';
  switch (type) {
    case 'Urgent':
      return UrgentTask.fromJson(json);
    case 'Simple':
      return SimpleTask.fromJson(json);
    default:
      throw InvalidTaskDataException('Type de tâche inconnu: $type');
  }
}
