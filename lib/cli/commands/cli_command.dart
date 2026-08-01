/// Interface du patron de conception "Command".
///
/// Chaque commande CLI (add, list, done, delete, help) est représentée
/// par une classe qui implémente cette interface, ce qui permet de traiter
/// toutes les commandes de façon polymorphe (via une `Map<String, CliCommand>`)
/// plutôt qu'avec un grand `switch` monolithique.
abstract class CliCommand {
  /// Nom de la commande tel que tapé par l'utilisateur (ex: "add").
  String get name;

  /// Description courte affichée dans l'aide.
  String get description;

  /// Exécute la commande avec les arguments restants (après le nom de
  /// la commande). Retourne un code de sortie: 0 = succès, != 0 = erreur.
  int execute(List<String> args);
}
