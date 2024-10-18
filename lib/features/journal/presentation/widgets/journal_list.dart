// lib/features/journal/presentation/widgets/journal_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/journal_bloc.dart';
import '../../domain/entities/journal.dart';

class JournalList extends StatelessWidget {
  const JournalList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        if (state is JournalLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2691A5)));
        } else if (state is JournalLoaded) {
          final journals =
              state.journals.isEmpty ? _exampleJournals : state.journals;
          return ListView.builder(
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final journal = journals[index];
              return Card(
                color: const Color(0xFF2A2D30),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    journal.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    journal.content,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDate(journal.createdAt),
                    style: const TextStyle(color: Color(0xFF2691A5)),
                  ),
                ),
              );
            },
          );
        } else if (state is JournalError) {
          return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.white)));
        }
        return const Center(
            child: Text('No journals found',
                style: TextStyle(color: Colors.white)));
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Journal> get _exampleJournals => [
        Journal(
          id: '1',
          title: 'First Meditation Session',
          content:
              'Today I tried meditating for the first time using the WeberBrain app. It was challenging to quiet my mind at first, but after a few minutes, I started to feel more relaxed. The guided session really helped me focus on my breathing.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Journal(
          id: '2',
          title: 'Productivity Boost',
          content:
              'Used the WeberBrain app for a 30-minute focus session today. I was amazed at how much work I got done! The gentle background sounds really helped me concentrate and stay on task.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Journal(
          id: '3',
          title: 'Stress Relief',
          content:
              'Had a stressful day at work. Used the app for a 15-minute relaxation session before bed. It really helped me unwind and let go of the day\'s tensions. I slept much better than usual.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Journal(
          id: '4',
          title: 'Morning Energy Boost',
          content:
              'Started my day with a 10-minute energizing session on the WeberBrain app. It\'s amazing how much more alert and ready I feel for the day. Might make this a regular part of my morning routine.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
