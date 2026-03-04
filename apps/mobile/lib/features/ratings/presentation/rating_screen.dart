import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE4ECFF), Color(0xFFF5F2EA)],
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
                    icon: const Icon(Icons.close),
                  ),
                  Text("Rate Worker", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
                      const SizedBox(height: 10),
                      const Text("Rahul Verma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(Icons.star, color: Color(0xFFE09A2B), size: 34),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const TextField(
                        maxLines: 4,
                        decoration: InputDecoration(labelText: "Write a short review"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go("/profile"),
                child: const Text("Submit Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
