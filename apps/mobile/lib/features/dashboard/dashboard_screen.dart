import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/analytics/bloc/analytics_bloc.dart';
import 'package:dsa_prep_coach/features/goals/bloc/goal_bloc.dart';
import 'package:dsa_prep_coach/features/goals/monthly_timeline_screen.dart';
import 'package:dsa_prep_coach/features/goals/weekly_goal_screen.dart';
import 'package:dsa_prep_coach/features/plan/bloc/plan_bloc.dart';
import 'package:dsa_prep_coach/features/plan/today_plan_screen.dart';
import 'package:dsa_prep_coach/features/problems/bloc/problem_bloc.dart';
import 'package:dsa_prep_coach/features/revision/bloc/revision_bloc.dart';
import 'package:dsa_prep_coach/repositories/goal_repository.dart';
import 'problem_list_screen.dart';
import 'today_revision_screen.dart';
import 'weekly_analytics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PrepFlow Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () {
              context.read<PlanBloc>().add(LoadTodayPlan());
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TodayPlanScreen()));
            },
            child: const Text('Today Plan'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<RevisionBloc>().add(LoadTodayRevisions());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TodayRevisionScreen()));
            },
            child: const Text('Today Revisions'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<ProblemBloc>().add(LoadProblems());
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProblemListScreen()));
            },
            child: const Text('Problems List'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) =>
                        GoalBloc(context.read<GoalRepository>()),
                    child: const WeeklyGoalScreen(),
                  ),
                ),
              );
            },
            child: const Text('Weekly Goal'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) =>
                        GoalBloc(context.read<GoalRepository>()),
                    child: const MonthlyTimelineScreen(),
                  ),
                ),
              );
            },
            child: const Text('View Monthly Timeline'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              context.read<AnalyticsBloc>().add(LoadAnalytics());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WeeklyAnalyticsScreen()));
            },
            child: const Text('Weekly Analytics'),
          ),
        ],
      ),
    );
  }
}
