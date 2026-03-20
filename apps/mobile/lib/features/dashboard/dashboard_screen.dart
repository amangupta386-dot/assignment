import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../analytics/bloc/analytics_bloc.dart';
import '../analytics/weekly_analytics_screen.dart';
import '../goals/bloc/goal_bloc.dart';
import '../goals/weekly_goal_screen.dart';
import '../plan/bloc/plan_bloc.dart';
import '../plan/today_plan_screen.dart';
import '../problems/add_problem_screen.dart';
import '../problems/bloc/problem_bloc.dart';
import '../problems/problem_list_screen.dart';
import '../revision/bloc/revision_bloc.dart';
import '../revision/today_revision_screen.dart';

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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayPlanScreen()));
            },
            child: const Text('Today Plan'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<RevisionBloc>().add(LoadTodayRevisions());
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayRevisionScreen()));
            },
            child: const Text('Today Revisions'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              context.read<ProblemBloc>().add(LoadProblems());
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProblemListScreen()));
            },
            child: const Text('Problems List'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProblemScreen()));
            },
            child: const Text('Add Problem'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              context.read<GoalBloc>().add(LoadCurrentGoal());
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyGoalScreen()));
            },
            child: const Text('Weekly Goal'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              context.read<AnalyticsBloc>().add(LoadAnalytics());
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyAnalyticsScreen()));
            },
            child: const Text('Weekly Analytics'),
          ),
        ],
      ),
    );
  }
}
