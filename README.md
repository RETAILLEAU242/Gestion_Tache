# Task CLI — Gestionnaire de tâches en ligne de commande (Dart)

Application CLI de gestion de tâches écrite en **Dart pur** (sans Flutter), réalisée
dans le cadre d'un projet de certification.

## Fonctionnalités

- ➕ Ajouter une tâche (titre, priorité `low`/`medium`/`high`, date limite optionnelle)
- 📋 Lister toutes les tâches, triées par priorité ou par date
- ✅ Marquer une tâche comme terminée
- 🗑️ Supprimer une tâche
- 💾 Persistance automatique dans un fichier JSON local (`tasks.json`)

## Exigences techniques couvertes

| Exigence | Où | Détail |
|---|---|---|
| Classe abstraite + héritage | `lib/models/task.dart` | `Task` (abstraite) → `SimpleTask`, `UrgentTask` |
| Interface #1 | `lib/models/json_serializable.dart` | `JsonSerializable`, implémentée par `Task` (qui implémente aussi `Comparable<Task>`) |
| Interface #2 | `lib/cli/commands/cli_command.dart` | `CliCommand`, implémentée par `AddCommand`, `ListCommand`, `DoneCommand`, `DeleteCommand`, `HelpCommand` (patron **Command**, dispatch polymorphe sans `switch`) |
| Génériques | `lib/repository/repository.dart` | `abstract class Repository<T>`, implémentée par `TaskRepository` |
| Exceptions personnalisées | `lib/exceptions/task_exceptions.dart` | `TaskNotFoundException`, `InvalidTaskDataException`, `StorageException` |
| Codes de sortie | `lib/cli/commands/exit_codes.dart` | `success` (0), `generalError` (1), `usageError` (64), `ioError` (74) — convention Unix |
| Tests unitaires (`package:test`) | `test/` | 26 tests au total (voir détail plus bas) |
| Lints | `analysis_options.yaml` | `package:lints/recommended.yaml` |

## Architecture : patron "Command"

Chaque commande CLI (`add`, `list`, `done`, `delete`, `help`) est une classe
séparée qui implémente l'interface `CliCommand` :

```dart
abstract class CliCommand {
  String get name;
  String get description;
  int execute(List<String> args); // retourne un code de sortie
}
```

`Cli` (dans `lib/cli/cli.dart`) construit une `Map<String, CliCommand>` et
délègue l'exécution à la bonne commande de façon polymorphe. Ce découpage
(un fichier par commande, testable indépendamment) remplace un grand
`switch` monolithique et facilite l'ajout de nouvelles commandes sans
toucher au reste du code (principe ouvert/fermé).

## Structure du projet

```
task_cli/
├── bin/
│   └── main.dart                     # Point d'entrée CLI (gère le code de sortie process)
├── lib/
│   ├── cli/
│   │   ├── cli.dart                  # Dispatcher polymorphe (patron Command)
│   │   └── commands/
│   │       ├── cli_command.dart      # Interface CliCommand
│   │       ├── add_command.dart
│   │       ├── list_command.dart
│   │       ├── done_command.dart
│   │       ├── delete_command.dart
│   │       ├── help_command.dart
│   │       ├── option_parser.dart    # Parsing partagé des options --cle=valeur
│   │       └── exit_codes.dart       # Codes de sortie standards
│   ├── exceptions/
│   │   └── task_exceptions.dart      # Exceptions personnalisées
│   ├── models/
│   │   ├── json_serializable.dart    # Interface JsonSerializable
│   │   ├── priority.dart
│   │   └── task.dart                 # Task (abstraite), SimpleTask, UrgentTask
│   └── repository/
│       ├── repository.dart           # Interface générique Repository<T>
│       └── task_repository.dart      # Implémentation JSON
├── test/
│   ├── task_repository_test.dart     # 12 tests : modèle + persistance
│   └── cli_commands_test.dart        # 14 tests : commandes + codes de sortie
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Prérequis

- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0.0

Vérifier l'installation :
```bash
dart --version
```

## Installation

```bash
git clone <url-de-votre-repo>
cd task_cli
dart pub get
```

## Lancer l'application

```bash
# Afficher l'aide
dart run bin/main.dart help

# Ajouter une tâche simple
dart run bin/main.dart add --title="Réviser Dart" --priority=medium

# Ajouter une tâche urgente avec échéance
dart run bin/main.dart add --title="Rendre le rapport" --priority=high --deadline=2026-08-15 --urgent

# Lister les tâches (triées par priorité par défaut)
dart run bin/main.dart list

# Lister les tâches triées par date limite
dart run bin/main.dart list --sort=date

# Marquer une tâche comme terminée (utiliser l'id affiché par "list")
dart run bin/main.dart done <id>

# Supprimer une tâche
dart run bin/main.dart delete <id>
```

Les données sont automatiquement sauvegardées dans `tasks.json` à la racine du projet
après chaque opération d'ajout, de modification ou de suppression.

## Lancer les tests

```bash
dart test
```

Cela exécute les **26 tests unitaires** répartis sur deux fichiers :

- `test/task_repository_test.dart` (12 tests) : ajout, validation des données,
  tri par priorité et par date, marquage "terminé", suppression, persistance
  JSON (sauvegarde/rechargement), comportement spécifique de `UrgentTask`
  (détection de retard).
- `test/cli_commands_test.dart` (14 tests) : parsing des options CLI,
  codes de sortie retournés par chaque commande (succès, erreur d'usage,
  erreur générale), comportement de `add`/`list`/`done`/`delete`/`help`
  face à des entrées valides et invalides.

## Choix de conception

- **`Task` (abstraite)** définit le contrat commun (id, titre, priorité, échéance,
  statut) ainsi que le tri par défaut via `Comparable<Task>`. `SimpleTask` est
  l'implémentation standard ; `UrgentTask` hérite de `Task` et ajoute la notion
  de tâche "en retard" (`isOverdue`).
- **`JsonSerializable`** est une interface (classe abstraite utilisée avec
  `implements`) garantissant que toute tâche peut être convertie en `Map`
  pour la persistance JSON.
- **`Repository<T>`** est une interface générique réutilisable pour n'importe
  quel type d'entité ; `TaskRepository` l'implémente pour `Task` et gère la
  lecture/écriture du fichier JSON local, avec gestion d'erreurs via des
  exceptions dédiées (`TaskNotFoundException`, `InvalidTaskDataException`,
  `StorageException`).

## Licence

Projet réalisé à des fins pédagogiques (certification Dart).
