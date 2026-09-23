import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_state.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

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
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
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
          onPressed: () {},
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
