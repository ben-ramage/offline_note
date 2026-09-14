import 'package:flutter/material.dart';
import 'package:offline_note/journal/presentation/pages/tab_scaffold.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: 'My Journal',
      tabs: [
        Tab(text: 'Notes'),
        Tab(text: 'Pending'),
      ],
      tabViews: [NotesTab(), PendingTab()],
    );
  }
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notes'));
  }
}

class PendingTab extends StatelessWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Pending'));
  }
}
