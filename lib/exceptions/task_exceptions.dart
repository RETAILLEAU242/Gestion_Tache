/// Exception levée lorsqu'une tâche demandée n'existe pas dans le dépôt.
class TaskNotFoundException implements Exception {
  final String message;
  TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message';
}

/// Exception levée lorsque des données de tâche sont invalides
/// (titre vide, priorité inconnue, date mal formée, etc.).
class InvalidTaskDataException implements Exception {
  final String message;
  InvalidTaskDataException(this.message);

  @override
  String toString() => 'InvalidTaskDataException: $message';
}

/// Exception levée en cas de problème de lecture/écriture du fichier
/// de persistance (JSON).
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
