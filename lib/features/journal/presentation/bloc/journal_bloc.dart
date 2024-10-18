// lib/features/journal/presentation/bloc/journal_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/journal.dart';
import '../../domain/usecases/get_journals.dart';
import '../../domain/usecases/add_journal.dart';

// Events
abstract class JournalEvent {}

class LoadJournals extends JournalEvent {}

class AddNewJournal extends JournalEvent {
  final String title;
  final String content;

  AddNewJournal({required this.title, required this.content});
}

// States
abstract class JournalState {}

class JournalInitial extends JournalState {}

class JournalLoading extends JournalState {}

class JournalLoaded extends JournalState {
  final List<Journal> journals;

  JournalLoaded(this.journals);
}

class JournalError extends JournalState {
  final String message;

  JournalError(this.message);
}

// BLoC
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final GetJournals getJournals;
  final AddJournal addJournal;
  List<Journal> _journals = [];

  JournalBloc({required this.getJournals, required this.addJournal})
      : super(JournalInitial()) {
    on<LoadJournals>(_onLoadJournals);
    on<AddNewJournal>(_onAddNewJournal);
  }

  Future<void> _onLoadJournals(
      LoadJournals event, Emitter<JournalState> emit) async {
    emit(JournalLoading());
    try {
      _journals = await getJournals();
      emit(JournalLoaded(_journals));
    } catch (e) {
      emit(JournalError('Failed to load journals'));
    }
  }

  Future<void> _onAddNewJournal(
      AddNewJournal event, Emitter<JournalState> emit) async {
    try {
      await addJournal(event.title, event.content);
      _journals.insert(
          0,
          Journal(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: event.title,
            content: event.content,
            createdAt: DateTime.now(),
          ));
      emit(JournalLoaded(_journals));
    } catch (e) {
      emit(JournalError('Failed to add journal'));
    }
  }
}
