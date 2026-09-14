import 'package:flutter/material.dart';
import 'package:offline_note/journal/presentation/pages/tab_scaffold.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: TabScaffold(
        title: 'My Journal',
        header: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'images/avataar_ben.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Ben Ramage",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('Thoughts, notes and ideas.', textAlign: TextAlign.center),
            ],
          ),
        ),
        tabs: [
          Tab(text: 'Notes'),
          Tab(text: 'Pending'),
        ],
        tabViews: [NotesTab(), PendingTab()],
      ),
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
