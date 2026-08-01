import 'dart:io';

import 'package:task_cli/models/task.dart';
import 'package:task_cli/models/priority.dart';
import 'package:task_cli/exceptions/task_exceptions.dart';
import 'package:task_cli/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  late String testFilePath;
  late TaskRepository repository;

  setUp(() {
    testFilePath = 'test_tasks_${DateTime.now().microsecondsSinceEpoch}.json';
    repository = TaskRepository(testFilePath);
  });

  tearDown(() {
    final file = File(testFilePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('Ajout de tâches', () {
    test('ajoute une tâche simple et la retrouve dans getAll()', () {
      final task = SimpleTask(
        id: '1',
        title: 'Réviser Dart',
        priority: Priority.medium,
      );
      repository.add(task);

      final all = repository.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'Réviser Dart');
    });

    test('lève InvalidTaskDataException si le titre est vide', () {
      expect(
        () => SimpleTask(id: '2', title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('lève InvalidTaskDataException si l\'id existe déjà', () {
      repository.add(SimpleTask(id: 'dup', title: 'A', priority: Priority.low));
      expect(
        () => repository.add(SimpleTask(id: 'dup', title: 'B', priority: Priority.high)),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });
  });

  group('Tri des tâches', () {
    test('trie par priorité décroissante (high, medium, low)', () {
      repository.add(SimpleTask(id: '1', title: 'Basse', priority: Priority.low));
      repository.add(SimpleTask(id: '2', title: 'Haute', priority: Priority.high));
      repository.add(SimpleTask(id: '3', title: 'Moyenne', priority: Priority.medium));

      final sorted = repository.getAllSorted(SortBy.priority);
      expect(sorted.map((t) => t.priority).toList(),
          [Priority.high, Priority.medium, Priority.low]);
    });

    test('trie par date limite croissante, tâches sans date à la fin', () {
      final now = DateTime.now();
      repository.add(SimpleTask(
        id: '1',
        title: 'Sans date',
        priority: Priority.medium,
      ));
      repository.add(SimpleTask(
        id: '2',
        title: 'Bientôt',
        priority: Priority.low,
        deadline: now.add(const Duration(days: 1)),
      ));
      repository.add(SimpleTask(
        id: '3',
        title: 'Plus tard',
        priority: Priority.low,
        deadline: now.add(const Duration(days: 10)),
      ));

      final sorted = repository.getAllSorted(SortBy.deadline);
      expect(sorted.map((t) => t.id).toList(), ['2', '3', '1']);
    });
  });

  group('Terminer et supprimer', () {
    test('marque une tâche comme terminée', () {
      repository.add(SimpleTask(id: '1', title: 'Tâche', priority: Priority.low));
      repository.markDone('1');
      expect(repository.getById('1').isDone, isTrue);
    });

    test('lève TaskNotFoundException en marquant un id inexistant', () {
      expect(() => repository.markDone('inconnu'),
          throwsA(isA<TaskNotFoundException>()));
    });

    test('supprime une tâche existante', () {
      repository.add(SimpleTask(id: '1', title: 'À supprimer', priority: Priority.low));
      repository.delete('1');
      expect(repository.getAll(), isEmpty);
    });

    test('lève TaskNotFoundException en supprimant un id inexistant', () {
      expect(() => repository.delete('inconnu'),
          throwsA(isA<TaskNotFoundException>()));
    });
  });

  group('Persistance JSON', () {
    test('les données survivent au rechargement depuis le fichier', () {
      repository.add(UrgentTask(
        id: '1',
        title: 'Urgent test',
        priority: Priority.high,
        deadline: DateTime(2026, 1, 1),
      ));

      final reloaded = TaskRepository(testFilePath);
      final tasks = reloaded.getAll();
      expect(tasks.length, 1);
      expect(tasks.first, isA<UrgentTask>());
      expect(tasks.first.title, 'Urgent test');
    });
  });

  group('UrgentTask', () {
    test('isOverdue est vrai pour une échéance passée et non terminée', () {
      final task = UrgentTask(
        id: '1',
        title: 'En retard',
        priority: Priority.high,
        deadline: DateTime(2020, 1, 1),
      );
      expect(task.isOverdue, isTrue);
    });

    test('isOverdue est faux si la tâche est terminée', () {
      final task = UrgentTask(
        id: '1',
        title: 'En retard mais faite',
        priority: Priority.high,
        deadline: DateTime(2020, 1, 1),
      );
      task.markDone();
      expect(task.isOverdue, isFalse);
    });
  });
}
