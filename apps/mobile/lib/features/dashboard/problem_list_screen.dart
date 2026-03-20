import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dsa_prep_coach/features/problems/bloc/problem_bloc.dart';

class ProblemListScreen extends StatelessWidget {
  const ProblemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Problems')),
      body: BlocBuilder<ProblemBloc, ProblemState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('${item.pattern} â€¢ ${item.difficulty} â€¢ ${item.platform}'),
                trailing: Text(item.initialStatus),
              );
            },
          );
        },
      ),
    );
  }
}

