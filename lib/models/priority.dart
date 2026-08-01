/// Niveau de priorité d'une tâche.
///
/// L'ordre déclaré (low < medium < high) est utilisé pour le tri :
/// `Priority.high.index` est le plus grand, donc high est trié en premier
/// lorsqu'on trie par priorité décroissante.
enum Priority {
  low,
  medium,
  high;

  /// Construit une [Priority] à partir d'une chaîne (insensible à la casse).
  /// Lève une [FormatException] si la valeur est inconnue.
  static Priority fromString(String value) {
    final normalized = value.trim().toLowerCase();
    for (final p in Priority.values) {
      if (p.name == normalized) return p;
    }
    throw FormatException(
      'Priorité invalide: "$value". Valeurs acceptées: low, medium, high.',
    );
  }
}
