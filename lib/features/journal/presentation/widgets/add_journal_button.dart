// lib/features/journal/presentation/widgets/add_journal_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/journal_bloc.dart';

class AddJournalButton extends StatelessWidget {
  const AddJournalButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AddJournalDialog(),
        );
      },
      backgroundColor: const Color(0xFF2691A5),
      child: const Icon(Icons.add),
    );
  }
}

class AddJournalDialog extends StatefulWidget {
  const AddJournalDialog({super.key});

  @override
  AddJournalDialogState createState() => AddJournalDialogState();
}

class AddJournalDialogState extends State<AddJournalDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2D30),
      title:
          const Text('Add New Journal', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2691A5)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF2691A5)),
              ),
            ),
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<JournalBloc>().add(AddNewJournal(
                  title: _titleController.text,
                  content: _contentController.text,
                ));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2691A5),
          ),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
