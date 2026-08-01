/// Codes de sortie standards, inspirés des conventions Unix (sysexits.h).
class ExitCodes {
  ExitCodes._();

  /// Tout s'est bien passé.
  static const int success = 0;

  /// Erreur générale (donnée invalide, tâche introuvable...).
  static const int generalError = 1;

  /// Mauvaise utilisation de la commande (arguments manquants/invalides).
  static const int usageError = 64;

  /// Erreur d'entrée/sortie (lecture/écriture du fichier JSON).
  static const int ioError = 74;
}
