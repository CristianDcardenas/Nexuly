import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/review.dart';
import 'base_repository.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository extends BaseFirestoreRepository<Review> {
  ReviewsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.reviews);

  @override
  Review fromJson(Map<String, dynamic> json) => Review.fromJson(json);

  @override
  Map<String, dynamic> toJson(Review model) => model.toJson();

  /// Reseñas públicas de un profesional (requiere índice:
  /// target_id + target_role + created_at).
  Stream<List<Review>> watchPublicForProfessional(String professionalId) {
    return collection
        .where('target_id', isEqualTo: professionalId)
        .where('target_role', isEqualTo: 'professional')
        .where('is_public', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(mapQuery);
  }

  /// Evaluaciones internas sobre un usuario (no visibles públicamente).
  Stream<List<Review>> watchInternalForUser(String userId) {
    return collection
        .where('target_id', isEqualTo: userId)
        .where('target_role', isEqualTo: 'user')
        .where('is_public', isEqualTo: false)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(mapQuery);
  }
}

@Riverpod(keepAlive: true)
ReviewsRepository reviewsRepository(Ref ref) =>
    ReviewsRepository(ref.watch(firebaseFirestoreProvider));
