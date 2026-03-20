import '../core/network/api_client.dart';
import '../core/data/local_fallback_store.dart';
import '../models/problem_model.dart';

class ProblemRepository {
  ProblemRepository(this._apiClient);

  final ApiClient _apiClient;
  final LocalFallbackStore _local = LocalFallbackStore.instance;

  Future<List<ProblemModel>> getProblems() async {
    try {
      final response = await _apiClient.get('/problems');
      final data = response.data['problems'] as List<dynamic>;
      return data
          .map(
              (e) => ProblemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) return _local.getProblems();
      rethrow;
    }
  }

  Future<void> addProblem({
    required String title,
    required String platform,
    required String difficulty,
    required String pattern,
    required String timeComplexity,
    required String initialStatus,
  }) async {
    try {
      await _apiClient.post('/problems', data: {
        'title': title,
        'platform': platform,
        'difficulty': difficulty,
        'pattern': pattern,
        'timeComplexity': timeComplexity,
        'initialStatus': initialStatus,
      });
    } catch (e) {
      if (_apiClient.isConnectivityError(e)) {
        _local.addProblem(
          title: title,
          platform: platform,
          difficulty: difficulty,
          pattern: pattern,
          timeComplexity: timeComplexity,
          initialStatus: initialStatus,
        );
        return;
      }
      rethrow;
    }
  }
}
