import '../core/network/api_client.dart';
import '../models/revision_item.dart';

class RevisionRepository {
  RevisionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<RevisionItem>> getTodayRevisions() async {
    final response = await _apiClient.get('/revisions/today');
    final data = response.data['revisions'] as List<dynamic>;
    return data.map((e) => RevisionItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> completeRevision(int problemId) async {
    await _apiClient.post('/revisions/$problemId/complete');
  }

  Future<void> failRevision(int problemId) async {
    await _apiClient.post('/revisions/$problemId/fail');
  }
}
