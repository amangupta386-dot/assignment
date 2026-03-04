import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class CreateJobScreen extends StatelessWidget {
  const CreateJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF4FF), Color(0xFFF5F2EA)],
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
                  Text("Create Job", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "What do you need?",
                          prefixIcon: Icon(Icons.home_repair_service),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Describe the issue",
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                color: const Color(0xFF0B8A7A),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Smart estimate: INR 450 - INR 650",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go("/jobs/track"),
                child: const Text("Post Job"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
