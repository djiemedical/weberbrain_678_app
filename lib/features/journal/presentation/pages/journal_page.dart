// lib/features/journal/presentation/pages/journal_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/journal_bloc.dart';
import '../widgets/journal_list.dart';
import '../widgets/add_journal_button.dart';
import '../../../../core/di/injection_container.dart';

@RoutePage()
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<JournalBloc>()..add(LoadJournals()),
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2225),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F2225),
          elevation: 0,
          title: const Text(
            'My Journals',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const SafeArea(
          child: Column(
            children: [
              Expanded(child: JournalList()),
            ],
          ),
        ),
        floatingActionButton: const AddJournalButton(),
      ),
    );
  }
}
