import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "../domain/worker.dart";
import "bloc/workers_bloc.dart";

class NearbyWorkersScreen extends StatelessWidget {
  const NearbyWorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workersBloc = context.read<WorkersBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Workers")),
      body: BlocBuilder<WorkersBloc, WorkersState>(
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
                itemCount: state.workers.length,
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _WorkerTile(worker: state.workers[index]),
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
    );
  }
}

class _WorkerTile extends StatelessWidget {
  const _WorkerTile({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(worker.name),
        subtitle: Text("${worker.primarySkill} - ${worker.distanceKm.toStringAsFixed(1)} km"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(worker.rating.toStringAsFixed(1)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
