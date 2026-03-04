import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "core/router.dart";
import "features/workers/data/workers_repository.dart";
import "features/workers/presentation/bloc/workers_bloc.dart";

void main() {
  runApp(const KaarigarApp());
}

class KaarigarApp extends StatelessWidget {
  const KaarigarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WorkersRepository>(create: (context) => WorkersRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WorkersBloc>(
            create: (context) => WorkersBloc(
              workersRepository: context.read<WorkersRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: "Kaarigar",
          routerConfig: appRouter,
          theme: ThemeData(colorSchemeSeed: const Color(0xFF0F766E), useMaterial3: true),
        ),
      ),
    );
  }
}
