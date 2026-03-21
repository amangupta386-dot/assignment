import 'package:dio/dio.dart';
import 'package:dsa_prep_coach/core/data/local_fallback_store.dart';
import 'package:dsa_prep_coach/core/network/api_client.dart';
import 'package:dsa_prep_coach/core/theme/app_theme.dart';
import 'package:dsa_prep_coach/features/analytics/bloc/analytics_bloc.dart';
import 'package:dsa_prep_coach/features/dashboard/dashboard_screen.dart';
import 'package:dsa_prep_coach/features/goals/bloc/goal_bloc.dart';
import 'package:dsa_prep_coach/features/plan/bloc/plan_bloc.dart';
import 'package:dsa_prep_coach/features/problems/bloc/problem_bloc.dart';
import 'package:dsa_prep_coach/features/revision/bloc/revision_bloc.dart';
import 'package:dsa_prep_coach/repositories/analytics_repository.dart';
import 'package:dsa_prep_coach/repositories/goal_repository.dart';
import 'package:dsa_prep_coach/repositories/plan_repository.dart';
import 'package:dsa_prep_coach/repositories/problem_repository.dart';
import 'package:dsa_prep_coach/repositories/revision_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalFallbackStore.instance.resetForTesting();
  });

  tearDown(() {
    LocalFallbackStore.instance.resetForTesting();
  });

  testWidgets('dashboard renders once and fits on a smaller phone height',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final apiClient = _OfflineApiClient();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProblemBloc(ProblemRepository(apiClient)),
          ),
          BlocProvider(
            create: (_) => RevisionBloc(RevisionRepository(apiClient)),
          ),
          BlocProvider(
            create: (_) => PlanBloc(PlanRepository(apiClient)),
          ),
          BlocProvider(
            create: (_) => GoalBloc(GoalRepository(apiClient)),
          ),
          BlocProvider(
            create: (_) => AnalyticsBloc(AnalyticsRepository(apiClient)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PrepFlow Dashboard'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _OfflineApiClient extends ApiClient {
  DioException _error(String path) => DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'Offline for widget test',
      );

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Future<Response<dynamic>>.error(_error(path));
  }

  @override
  Future<Response<dynamic>> post(String path, {Object? data}) {
    return Future<Response<dynamic>>.error(_error(path));
  }

  @override
  bool isConnectivityError(Object error) {
    return error is DioException &&
        error.type == DioExceptionType.connectionError;
  }
}
