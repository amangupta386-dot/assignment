import "package:flutter/material.dart";

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Worker")),
      body: const Center(child: Text("Review and rating submission")),
    );
  }
}
