import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "core/router.dart";
import "core/theme/app_theme.dart";
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
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
        ),
      ),
    );
  }
}
