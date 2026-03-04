import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class TrackJobScreen extends StatelessWidget {
  const TrackJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE4F5F1), Color(0xFFF5F2EA)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go("/workers"),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Track Job", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Electrician Visit", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: 0.65),
                      SizedBox(height: 10),
                      Text("Worker assigned and on the way"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text("Rahul Verma"),
                  subtitle: const Text("ETA: 14 mins"),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text("Call"),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go("/payment"),
                child: const Text("Continue to Payment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
