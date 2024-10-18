// lib/features/journal/domain/usecases/add_journal.dart
import '../repositories/journal_repository.dart';

class AddJournal {
  final JournalRepository repository;

  AddJournal(this.repository);

  Future<void> call(String title, String content) async {
    await repository.addJournal(title, content);
  }
}
