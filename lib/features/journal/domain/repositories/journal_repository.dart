// lib/features/journal/domain/repositories/journal_repository.dart
import '../entities/journal.dart';

abstract class JournalRepository {
  Future<List<Journal>> getJournals();
  Future<void> addJournal(String title, String content);
}
