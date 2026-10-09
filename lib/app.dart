import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/data/local/drift_local_post_repository.dart';
import 'package:offline_note/features/create/data/local/local_post_database.dart';
import 'package:offline_note/features/create/data/remote/firebase_remote_post_repository.dart';
import 'package:offline_note/features/create/data/sync/sync_queue_repository.dart';
import 'package:offline_note/features/create/data/sync/sync_runner.dart';
import 'package:offline_note/features/create/domain/repos/local_post_repository.dart';
import 'package:offline_note/features/create/domain/repos/remote_post_repository.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/features/create/presentation/cubits/post_cubit.dart';
import 'package:offline_note/features/image_upload/data/firebase_image_upload_repository.dart';
import 'package:offline_note/features/image_upload/domain/repos/image_upload_repository.dart';
import 'package:offline_note/router.dart';

class App extends StatefulWidget {
  final localPostDatabase = LocalPostDatabase();

  late final LocalPostRepository localPostRepository = DriftLocalPostRepository(
    localPostDatabase,
  );

  late final SyncQueueRepository syncQueueRepository = SyncQueueRepository(
    localPostDatabase,
  );

  late final RemotePostRepository remotePostRepository =
      FirebaseRemotePostRepository();

  late final ImageUploadRepository imageUploadRepository =
      FirebaseImageUploadRepository();

  late final SyncRunner syncRunner = SyncRunner(
    localPostRepository: localPostRepository,
    syncQueueRepository: syncQueueRepository,
    remotePostRepository: remotePostRepository,
    imageUploadRepository: imageUploadRepository,
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
        RepositoryProvider<SyncQueueRepository>.value(
          value: widget.syncQueueRepository,
        ),
        RepositoryProvider<RemotePostRepository>.value(
          value: widget.remotePostRepository,
        ),
        RepositoryProvider<ImageUploadRepository>.value(
          value: widget.imageUploadRepository,
        ),
        RepositoryProvider<SyncRunner>.value(value: widget.syncRunner),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DraftCubit>(
            create: (context) => DraftCubit(
              localPostRepository: context.read<LocalPostRepository>(),
            ),
          ),
          BlocProvider<PostCubit>(
            create: (context) => PostCubit(
              localPostRepository: context.read<LocalPostRepository>(),
              syncQueueRepository: context.read<SyncQueueRepository>(),
              syncRunner: context.read<SyncRunner>(),
            ),
          ),
        ],
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
