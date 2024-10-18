// lib/features/journal/domain/usecases/get_journals.dart
import '../entities/journal.dart';
import '../repositories/journal_repository.dart';

class GetJournals {
  final JournalRepository repository;

  GetJournals(this.repository);

  Future<List<Journal>> call() async {
    return await repository.getJournals();
  }
}
