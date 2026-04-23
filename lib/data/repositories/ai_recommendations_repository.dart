import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/firestore_collections.dart';
import '../../core/providers/firebase_providers.dart';
import '../models/ai_recommendation.dart';
import 'base_repository.dart';

part 'ai_recommendations_repository.g.dart';

class AiRecommendationsRepository
    extends BaseFirestoreRepository<AiRecommendation> {
  AiRecommendationsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(FirestoreCollections.aiRecommendations);

  @override
  AiRecommendation fromJson(Map<String, dynamic> json) =>
      AiRecommendation.fromJson(json);

  @override
  Map<String, dynamic> toJson(AiRecommendation model) => model.toJson();

  Stream<List<AiRecommendation>> watchForUser(String userId, {int limit = 20}) {
    return collection
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(mapQuery);
  }

  Future<void> submitFeedback(String recommendationId, String feedback) =>
      update(recommendationId, {'feedback': feedback});
}

@Riverpod(keepAlive: true)
AiRecommendationsRepository aiRecommendationsRepository(Ref ref) =>
    AiRecommendationsRepository(ref.watch(firebaseFirestoreProvider));
