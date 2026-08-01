import 'cli_command.dart';
import 'exit_codes.dart';

/// Commande `help` — affiche la liste des commandes disponibles.
///
/// Reçoit la liste des autres commandes pour générer l'aide dynamiquement,
/// ce qui évite de dupliquer les descriptions à deux endroits.
class HelpCommand implements CliCommand {
  final List<CliCommand> allCommands;

  HelpCommand(this.allCommands);

  @override
  String get name => 'help';

  @override
  String get description => 'help';

  @override
  int execute(List<String> args) {
    final buffer = StringBuffer()
      ..writeln('Gestionnaire de tâches CLI — Dart')
      ..writeln()
      ..writeln('Usage:')
      ..writeln('  dart run bin/main.dart <commande> [options]')
      ..writeln()
      ..writeln('Commandes:');

    for (final command in allCommands) {
      buffer.writeln('  ${command.description}');
    }

    buffer
      ..writeln()
      ..writeln('Exemples:')
      ..writeln('  dart run bin/main.dart add --title="Rapport de stage" '
          '--priority=high --deadline=2026-08-15 --urgent')
      ..writeln('  dart run bin/main.dart list --sort=date')
      ..writeln('  dart run bin/main.dart done abc123')
      ..writeln('  dart run bin/main.dart delete abc123');

    print(buffer.toString().trimRight());
    return ExitCodes.success;
  }
}
