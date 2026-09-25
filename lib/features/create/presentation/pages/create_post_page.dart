import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/presentation/components/drafts_drawer.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_state.dart';
import 'package:offline_note/features/create/presentation/pages/edit_post_page.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DraftCubit>().startDraftsStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DraftCubit, DraftState>(
      listener: (context, state) {
        if (state is DraftError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Draft Error: ${state.message}")),
          );
        }
        if (state is DraftDeleted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Draft deleted.")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Create'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: const Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
        endDrawer: const DraftsDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => EditPostPage()));
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
