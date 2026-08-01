/// Interface générique de dépôt (repository) pour un type [T].
///
/// Utilise les génériques Dart pour définir un contrat réutilisable,
/// indépendant du type d'objet stocké.
abstract class Repository<T> {
  void add(T item);
  List<T> getAll();
  T getById(String id);
  void update(T item);
  void delete(String id);
  void save();
  void load();
}
