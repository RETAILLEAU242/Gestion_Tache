import 'dart:io';

import 'package:task_cli/cli/cli.dart';
import 'package:task_cli/cli/commands/exit_codes.dart';
import 'package:task_cli/cli/commands/option_parser.dart';
import 'package:task_cli/repository/task_repository.dart';
import 'package:test/test.dart';

void main() {
  late String testFilePath;
  late TaskRepository repository;
  late Cli cli;

  setUp(() {
    testFilePath = 'test_cli_${DateTime.now().microsecondsSinceEpoch}.json';
    repository = TaskRepository(testFilePath);
    cli = Cli(repository);
  });

  tearDown(() {
    final file = File(testFilePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  });

  group('parseOptions', () {
    test('extrait les paires --cle=valeur', () {
      final options = parseOptions(['--title=Test', '--priority=high']);
      expect(options['title'], 'Test');
      expect(options['priority'], 'high');
    });

    test('traite les flags sans valeur comme "true"', () {
      final options = parseOptions(['--urgent']);
      expect(options['urgent'], 'true');
    });
  });

  group('Commande add', () {
    test('retourne success (0) et crée la tâche avec un titre valide', () {
      final code = cli.run(['add', '--title=Réviser Dart', '--priority=high']);
      expect(code, ExitCodes.success);
      expect(repository.getAll().length, 1);
    });

    test('retourne usageError si --title est absent', () {
      final code = cli.run(['add', '--priority=high']);
      expect(code, ExitCodes.usageError);
      expect(repository.getAll(), isEmpty);
    });

    test('retourne usageError si la priorité est invalide', () {
      final code = cli.run(['add', '--title=Test', '--priority=extreme']);
      expect(code, ExitCodes.usageError);
    });

    test('retourne usageError si la date limite est mal formée', () {
      final code = cli.run(['add', '--title=Test', '--deadline=pas-une-date']);
      expect(code, ExitCodes.usageError);
    });
  });

  group('Commande list', () {
    test('retourne success même quand la liste est vide', () {
      final code = cli.run(['list']);
      expect(code, ExitCodes.success);
    });

    test('retourne usageError pour une valeur de --sort inconnue', () {
      final code = cli.run(['list', '--sort=inconnu']);
      expect(code, ExitCodes.usageError);
    });
  });

  group('Commandes done / delete', () {
    test('done retourne generalError pour un id inexistant', () {
      final code = cli.run(['done', 'inconnu']);
      expect(code, ExitCodes.generalError);
    });

    test('delete retourne usageError si aucun id n\'est fourni', () {
      final code = cli.run(['delete']);
      expect(code, ExitCodes.usageError);
    });

    test('done puis list confirment la tâche terminée', () {
      cli.run(['add', '--title=A faire', '--priority=low']);
      final id = repository.getAll().first.id;

      final code = cli.run(['done', id]);
      expect(code, ExitCodes.success);
      expect(repository.getById(id).isDone, isTrue);
    });
  });

  group('Commande inconnue et aide', () {
    test('une commande inconnue retourne usageError', () {
      final code = cli.run(['bricoler']);
      expect(code, ExitCodes.usageError);
    });

    test('aucun argument affiche l\'aide et retourne success', () {
      final code = cli.run([]);
      expect(code, ExitCodes.success);
    });

    test('la commande help retourne success', () {
      final code = cli.run(['help']);
      expect(code, ExitCodes.success);
    });
  });
}
