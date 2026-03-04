import "package:flutter/material.dart";

class TrackJobScreen extends StatelessWidget {
  const TrackJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Job")),
      body: const Center(child: Text("Real-time job state and worker ETA")),
    );
  }
}
