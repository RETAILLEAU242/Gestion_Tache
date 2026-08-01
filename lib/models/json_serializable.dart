/// Interface implémentée par tout objet capable de se sérialiser en JSON.
///
/// En Dart, toute classe (même abstraite) peut servir d'interface via
/// le mot-clé `implements`. C'est le mécanisme utilisé ici.
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
