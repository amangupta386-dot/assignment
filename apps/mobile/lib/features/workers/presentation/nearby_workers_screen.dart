import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "../domain/worker.dart";
import "bloc/workers_bloc.dart";

class NearbyWorkersScreen extends StatelessWidget {
  const NearbyWorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workersBloc = context.read<WorkersBloc>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F1EE), Color(0xFFF5F2EA)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<WorkersBloc, WorkersState>(
            builder: (context, state) {
              if (state is WorkersLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WorkersFailure) {
                return _StateMessage(
                  message: state.message,
                  actionLabel: "Retry",
                  onPressed: () => workersBloc.add(
                    WorkersRequested(latitude: 28.6139, longitude: 77.2090),
                  ),
                );
              }

              if (state is WorkersLoaded) {
                if (state.workers.isEmpty) {
                  return _StateMessage(
                    message: "No workers found nearby.",
                    actionLabel: "Refresh",
                    onPressed: () => workersBloc.add(
                      WorkersRequested(latitude: 28.6139, longitude: 77.2090),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    workersBloc.add(
                      WorkersRequested(latitude: 28.6139, longitude: 77.2090),
                    );
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.workers.length + 2,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return const _Header();
                      }
                      if (index == 1) {
                        return const _QuickActions();
                      }
                      return _WorkerTile(worker: state.workers[index - 2]);
                    },
                  ),
                );
              }

              return _StateMessage(
                message: "Fetch workers near your location.",
                actionLabel: "Load Nearby",
                onPressed: () => workersBloc.add(
                  WorkersRequested(latitude: 28.6139, longitude: 77.2090),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nearby Pros", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          "Handpicked workers around you, ready now.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4A5F5A),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionChip(
          label: "Create Job",
          icon: Icons.add_task,
          onTap: () => context.go("/jobs/create"),
        ),
        _ActionChip(
          label: "Track Job",
          icon: Icons.route,
          onTap: () => context.go("/jobs/track"),
        ),
        _ActionChip(
          label: "Payments",
          icon: Icons.payments,
          onTap: () => context.go("/payment"),
        ),
        _ActionChip(
          label: "Profile",
          icon: Icons.person_outline,
          onTap: () => context.go("/profile"),
        ),
      ],
    );
  }
}

class _WorkerTile extends StatelessWidget {
  const _WorkerTile({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE6F4F1),
              child: Icon(Icons.person, color: Color(0xFF0B8A7A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    "${worker.primarySkill}   ${worker.distanceKm.toStringAsFixed(1)} km away",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5D6E6A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFE09A2B)),
                  const SizedBox(width: 4),
                  Text(worker.rating.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0B8A7A)),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(onPressed: onPressed, child: Text(actionLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
