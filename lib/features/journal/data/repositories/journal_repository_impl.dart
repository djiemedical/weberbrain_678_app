// lib/features/journal/data/repositories/journal_repository_impl.dart
import '../../domain/entities/journal.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_local_data_source.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  JournalRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Journal>> getJournals() async {
    return await localDataSource.getJournals();
  }

  @override
  Future<void> addJournal(String title, String content) async {
    final journal = Journal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    await localDataSource.addJournal(journal);
  }
}
