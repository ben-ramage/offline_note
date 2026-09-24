import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_note/features/create/presentation/components/draft_tile.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_cubit.dart';
import 'package:offline_note/features/create/presentation/cubits/draft_state.dart';

class DraftsDrawer extends StatelessWidget {
  const DraftsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<DraftCubit, DraftState>(
                buildWhen: (previous, current) =>
                    current is DraftsLoaded ||
                    current is DraftError ||
                    current is DraftInitial,
                builder: (context, state) {
                  if (state is DraftsLoaded) {
                    final drafts = state.drafts;

                    if (drafts.isEmpty) {
                      return const Center(child: Text("No drafts yet."));
                    }

                    return ListView.builder(
                      itemCount: drafts.length,
                      itemBuilder: (context, index) {
                        final draft = drafts[index];

                        return Dismissible(
                          key: ValueKey(draft.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Delete draft?'),
                                    content: const Text(
                                      'Are you sure you want to delete this draft?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ) ??
                                false;
                          },
                          onDismissed: (direction) {
                            context.read<DraftCubit>().deleteDraft(draft.id);
                          },
                          child: DraftTile(
                            title: draft.title,
                            subtitle: Text('Draft .createdAt'),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    );
                  } else if (state is DraftError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  return const Center(child: Text("Loading drafts..."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
