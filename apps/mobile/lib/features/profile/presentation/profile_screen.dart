import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go("/workers"),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Profile", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      CircleAvatar(radius: 34, child: Icon(Icons.person, size: 34)),
                      SizedBox(height: 10),
                      Text("Aman Sharma", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text("aman@example.com"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Column(
                  children: [
                    ListTile(leading: Icon(Icons.history), title: Text("Booking History")),
                    Divider(height: 1),
                    ListTile(leading: Icon(Icons.location_on_outlined), title: Text("Saved Addresses")),
                    Divider(height: 1),
                    ListTile(leading: Icon(Icons.settings_outlined), title: Text("Preferences")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
