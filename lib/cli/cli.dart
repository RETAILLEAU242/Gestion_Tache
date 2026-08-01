import '../repository/task_repository.dart';
import 'commands/cli_command.dart';
import 'commands/add_command.dart';
import 'commands/list_command.dart';
import 'commands/done_command.dart';
import 'commands/delete_command.dart';
import 'commands/help_command.dart';
import 'commands/exit_codes.dart';

/// Point d'entrée de la logique CLI.
///
/// Construit la table des commandes disponibles (patron "Command") et
/// délègue l'exécution à la commande correspondante de façon polymorphe,
/// plutôt que via un grand `switch` sur des chaînes de caractères.
class Cli {
  late final Map<String, CliCommand> _commands;

  Cli(TaskRepository repository) {
    final commandList = <CliCommand>[
      AddCommand(repository),
      ListCommand(repository),
      DoneCommand(repository),
      DeleteCommand(repository),
    ];
    final help = HelpCommand(commandList);

    _commands = {
      for (final c in commandList) c.name: c,
      help.name: help,
    };
  }

  /// Exécute la commande demandée et retourne un code de sortie
  /// (0 = succès, voir [ExitCodes] pour les autres valeurs).
  int run(List<String> args) {
    if (args.isEmpty) {
      return _commands['help']!.execute(const []);
    }

    final commandName = args[0];
    final rest = args.sublist(1);
    final command = _commands[commandName];

    if (command == null) {
      print('Commande inconnue: "$commandName". Utilisez "help" pour la liste des commandes.');
      return ExitCodes.usageError;
    }

    return command.execute(rest);
  }
}
