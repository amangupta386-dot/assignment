import '../core/network/api_client.dart';
import '../models/problem_model.dart';

class ProblemRepository {
  ProblemRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProblemModel>> getProblems() async {
    final response = await _apiClient.get('/problems');
    final data = response.data['problems'] as List<dynamic>;
    return data.map((e) => ProblemModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> addProblem({
    required String title,
    required String platform,
    required String difficulty,
    required String pattern,
    required String initialStatus,
  }) async {
    await _apiClient.post('/problems', data: {
      'title': title,
      'platform': platform,
      'difficulty': difficulty,
      'pattern': pattern,
      'initialStatus': initialStatus,
    });
  }
}
