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

    return Scaffold(
      appBar: AppBar(title: const Text('PrepFlow Dashboard')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your DSA cockpit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Jump into today'
                    's work, manage your weekly plan, review pattern notes, and track your progress from one place.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _HeroStat(label: 'Focus', value: 'Today'),
                      _HeroStat(label: 'Mode', value: 'Prep'),
                      _HeroStat(label: 'Flow', value: 'Deep'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _DashboardSection(
              title: 'Daily Flow',
              subtitle: 'Start the most important work first.',
              children: [
                _DashboardActionCard(
                  title: 'Today Plan',
                  subtitle:
                      'See the assigned problem and the extra questions for the day.',
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
                _DashboardActionCard(
                  title: 'Today Revisions',
                  subtitle:
                      'Complete your due revision stages and keep momentum alive.',
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
              ],
            ),
            const SizedBox(height: 18),
            _DashboardSection(
              title: 'Practice Hub',
              subtitle: 'Plan what to solve and keep your references close.',
              children: [
                _DashboardActionCard(
                  title: 'Problems List',
                  subtitle:
                      'Browse your solved set, status, pattern, and optimized complexity.',
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
                _DashboardActionCard(
                  title: 'Pattern Notes',
                  subtitle:
                      'Open your visual pattern references saved from gallery or camera.',
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
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Planning & Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Keep the week organized and track the bigger picture.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                _DashboardMiniCard(
                  title: 'Weekly Goal',
                  icon: Icons.flag_outlined,
                  tint: const Color(0xFF0F766E),
                  onTap: () {
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
                ),
                _DashboardMiniCard(
                  title: 'Monthly Timeline',
                  icon: Icons.view_timeline_outlined,
                  tint: const Color(0xFF2563EB),
                  onTap: () {
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
                ),
                _DashboardMiniCard(
                  title: 'Analytics',
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
                _DashboardMiniCard(
                  title: 'Stay Consistent',
                  icon: Icons.local_fire_department_outlined,
                  tint: const Color(0xFFDC2626),
                  subtitle: 'Daily rhythm',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: tint),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: tint),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
