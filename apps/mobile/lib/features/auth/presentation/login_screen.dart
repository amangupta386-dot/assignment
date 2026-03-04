import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Email")),
            const TextField(decoration: InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go("/workers"), child: const Text("Continue"))
          ],
        ),
      ),
    );
  }
}
