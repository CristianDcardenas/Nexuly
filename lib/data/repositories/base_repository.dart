import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/failures.dart';

/// Mapea excepciones crudas de Firestore a `NexulyFailure`.
Never _rethrowAsFailure(Object e, StackTrace st) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        throw PermissionFailure(e.message ?? 'Permiso denegado', e);
      case 'not-found':
        throw NotFoundFailure(e.message ?? 'No encontrado', e);
      case 'unavailable':
      case 'deadline-exceeded':
        throw NetworkFailure(e.message ?? 'Sin conexión', e);
      default:
        throw UnknownFailure(e.message ?? e.code, e);
    }
  }
  throw UnknownFailure(e.toString(), e);
}

/// Helpers comunes para repositorios que trabajan con una colección tipada.
///
/// Cada repositorio concreto define `collection` y `fromJson`, y obtiene
/// gratis CRUD + streams tipados con manejo de errores homogéneo.
abstract class BaseFirestoreRepository<T> {
  const BaseFirestoreRepository();

  /// Colección raíz o subcolección ya referenciada.
  CollectionReference<Map<String, dynamic>> get collection;

  /// Cómo convertir el doc Firestore → modelo.
  T fromJson(Map<String, dynamic> json);

  /// Cómo convertir el modelo → doc Firestore.
  /// Por defecto asumimos que el modelo Freezed expone `toJson()`.
  Map<String, dynamic> toJson(T model);

  /// Normaliza el doc añadiendo el `id` para que los modelos que lo usan
  /// puedan leerlo (p.ej. Service, ServiceRequest).
  T _hydrate(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final withId = {...data, 'id': doc.id};
    return fromJson(withId);
  }

  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return _hydrate(doc);
    } catch (e, st) {
      _rethrowAsFailure(e, st);
    }
  }

  Stream<T?> watchById(String id) {
    return collection.doc(id).snapshots().map(
      (doc) {
        if (!doc.exists) return null;
        return _hydrate(doc);
      },
    ).handleError((Object e, StackTrace st) => _rethrowAsFailure(e, st));
  }

  Future<void> set(String id, T model, {bool merge = true}) async {
    try {
      await collection
          .doc(id)
          .set(toJson(model), SetOptions(merge: merge));
    } catch (e, st) {
      _rethrowAsFailure(e, st);
    }
  }

  Future<String> add(T model) async {
    try {
      final ref = await collection.add(toJson(model));
      return ref.id;
    } catch (e, st) {
      _rethrowAsFailure(e, st);
    }
  }

  Future<void> update(String id, Map<String, Object?> data) async {
    try {
      await collection.doc(id).update(data);
    } catch (e, st) {
      _rethrowAsFailure(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e, st) {
      _rethrowAsFailure(e, st);
    }
  }

  List<T> mapQuery(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map(_hydrate).toList();
  }
}
