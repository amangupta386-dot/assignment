import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/revision_item.dart';

class RevisionRepository {
  RevisionRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<List<RevisionItem>> getTodayRevisions() async {
    try {
      final response = await _apiClient.get('/revisions/today');
      final data = response.data['revisions'] as List<dynamic>;
      return data.map((e) => RevisionItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getTodayRevisions();
      rethrow;
    }
  }

  Future<void> completeRevision(int problemId) async {
    try {
      await _apiClient.post('/revisions/$problemId/complete');
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.completeRevision(problemId);
        return;
      }
      rethrow;
    }
  }

  Future<void> failRevision(int problemId) async {
    try {
      await _apiClient.post('/revisions/$problemId/fail');
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.failRevision(problemId);
        return;
      }
      rethrow;
    }
  }
}
