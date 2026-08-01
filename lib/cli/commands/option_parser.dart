/// Parse des options du type `--cle=valeur` ou `--flag` (booléen, valeur "true").
///
/// Utilisé par toutes les commandes qui acceptent des options nommées,
/// ce qui évite de dupliquer la logique de parsing dans chaque commande.
Map<String, String> parseOptions(List<String> args) {
  final result = <String, String>{};
  for (final arg in args) {
    if (arg.startsWith('--')) {
      final stripped = arg.substring(2);
      final eqIndex = stripped.indexOf('=');
      if (eqIndex == -1) {
        result[stripped] = 'true';
      } else {
        result[stripped.substring(0, eqIndex)] = stripped.substring(eqIndex + 1);
      }
    }
  }
  return result;
}
