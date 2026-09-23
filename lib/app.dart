import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/data/local/drift_local_post_repository.dart';
import 'package:offline_note/features/create/data/local/local_post_database.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/router.dart';

class App extends StatefulWidget {
  final localPostDatabase = LocalPostDatabase();

  late final LocalPostRepository localPostRepository = DriftLocalPostRepository(
    localPostDatabase,
  );

  App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalPostDatabase>.value(
          value: widget.localPostDatabase,
        ),
        RepositoryProvider<LocalPostRepository>.value(
          value: widget.localPostRepository,
        ),
      ],
      child: BlocProvider<DraftCubit>(
        create: (context) => DraftCubit(
          localPostRepository: context.read<LocalPostRepository>(),
        ),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "Offline Note",
          routerConfig: router,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.localPostDatabase.close();
    super.dispose();
  }
}
