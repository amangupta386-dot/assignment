import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_config.dart';
import 'features/analytics/bloc/analytics_bloc.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/goals/bloc/goal_bloc.dart';
import 'features/plan/bloc/plan_bloc.dart';
import 'features/problems/bloc/problem_bloc.dart';
import 'features/revision/bloc/revision_bloc.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/goal_repository.dart';
import 'repositories/plan_repository.dart';
import 'repositories/problem_repository.dart';
import 'repositories/revision_repository.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  debugPrint('Using API base URL: ${AppConfig.baseUrl}');

  final apiClient = ApiClient();

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ProblemRepository(apiClient)),
        RepositoryProvider(create: (_) => RevisionRepository(apiClient)),
        RepositoryProvider(create: (_) => PlanRepository(apiClient)),
        RepositoryProvider(create: (_) => GoalRepository(apiClient)),
        RepositoryProvider(create: (_) => AnalyticsRepository(apiClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  ProblemBloc(context.read<ProblemRepository>())),
          BlocProvider(
              create: (context) =>
                  RevisionBloc(context.read<RevisionRepository>())),
          BlocProvider(
              create: (context) => PlanBloc(context.read<PlanRepository>())),
          BlocProvider(
              create: (context) => GoalBloc(context.read<GoalRepository>())),
          BlocProvider(
              create: (context) =>
                  AnalyticsBloc(context.read<AnalyticsRepository>())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
