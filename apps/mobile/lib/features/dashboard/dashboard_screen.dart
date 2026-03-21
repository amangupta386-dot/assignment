import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/analytics/bloc/analytics_bloc.dart';
import 'package:dsa_prep_coach/features/goals/bloc/goal_bloc.dart';
import 'package:dsa_prep_coach/features/goals/monthly_timeline_screen.dart';
import 'package:dsa_prep_coach/features/goals/weekly_goal_screen.dart';
import 'package:dsa_prep_coach/features/pattern_notes/pattern_notes_screen.dart';
import 'package:dsa_prep_coach/features/plan/bloc/plan_bloc.dart';
import 'package:dsa_prep_coach/features/plan/today_plan_screen.dart';
import 'package:dsa_prep_coach/features/problems/bloc/problem_bloc.dart';
import 'package:dsa_prep_coach/features/problems/problem_list_screen.dart';
import 'package:dsa_prep_coach/features/revision/bloc/revision_bloc.dart';
import 'package:dsa_prep_coach/repositories/goal_repository.dart';

import 'today_revision_screen.dart';
import 'weekly_analytics_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actions = <_DashboardShortcut>[
      _DashboardShortcut(
        title: 'Today Plan',
        subtitle: 'Daily focus',
        icon: Icons.wb_sunny_outlined,
        tint: const Color(0xFF0F766E),
        onTap: () {
          context.read<PlanBloc>().add(LoadTodayPlan());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TodayPlanScreen(),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Today Revisions',
        subtitle: 'Due stages',
        icon: Icons.history_edu_outlined,
        tint: const Color(0xFF1D4ED8),
        onTap: () {
          context.read<RevisionBloc>().add(LoadTodayRevisions());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TodayRevisionScreen(),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Problems List',
        subtitle: 'All problems',
        icon: Icons.dataset_outlined,
        tint: const Color(0xFF7C3AED),
        onTap: () {
          context.read<ProblemBloc>().add(LoadProblems());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProblemListScreen(),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Pattern Notes',
        subtitle: 'Quick refs',
        icon: Icons.perm_media_outlined,
        tint: const Color(0xFFEA580C),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PatternNotesScreen(),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Weekly Goal',
        subtitle: 'Plan week',
        icon: Icons.flag_outlined,
        tint: const Color(0xFF0F766E),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => GoalBloc(context.read<GoalRepository>()),
                child: const WeeklyGoalScreen(),
              ),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Monthly Timeline',
        subtitle: 'Week map',
        icon: Icons.view_timeline_outlined,
        tint: const Color(0xFF2563EB),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => GoalBloc(context.read<GoalRepository>()),
                child: const MonthlyTimelineScreen(),
              ),
            ),
          );
        },
      ),
      _DashboardShortcut(
        title: 'Analytics',
        subtitle: 'Track growth',
        icon: Icons.insights_outlined,
        tint: const Color(0xFF9333EA),
        onTap: () {
          context.read<AnalyticsBloc>().add(LoadAnalytics());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WeeklyAnalyticsScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('PrepFlow Dashboard')),
      body: SelectionArea(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Everything important for today, planning, revision, and tracking in one fixed board.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const crossAxisCount = 2;
                      const spacing = 12.0;
                      final rows = (actions.length / crossAxisCount).ceil();
                      final itemWidth =
                          (constraints.maxWidth - spacing) / crossAxisCount;
                      final itemHeight =
                          (constraints.maxHeight - (rows - 1) * spacing) /
                              rows;
                      final childAspectRatio = itemHeight <= 0
                          ? 1.0
                          : itemWidth / itemHeight;

                      return GridView.builder(
                        itemCount: actions.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final action = actions[index];
                          return _DashboardMiniCard(
                            title: action.title,
                            subtitle: action.subtitle,
                            icon: action.icon,
                            tint: action.tint,
                            onTap: action.onTap,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardMiniCard extends StatelessWidget {
  const _DashboardMiniCard({
    required this.title,
    required this.icon,
    required this.tint,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.75),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: tint),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.2,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.2,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardShortcut {
  const _DashboardShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
}
