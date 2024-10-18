// lib/features/journal/data/datasources/journal_local_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/journal.dart';

abstract class JournalLocalDataSource {
  Future<List<Journal>> getJournals();
  Future<void> addJournal(Journal journal);
}

class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  final SharedPreferences sharedPreferences;

  JournalLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Journal>> getJournals() async {
    final jsonString = sharedPreferences.getString('journals');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((jsonMap) => Journal.fromJson(jsonMap)).toList();
    }
    return [];
  }

  @override
  Future<void> addJournal(Journal journal) async {
    final List<Journal> journals = await getJournals();
    journals.add(journal);
    final List<Map<String, dynamic>> jsonList =
        journals.map((j) => j.toJson()).toList();
    await sharedPreferences.setString('journals', json.encode(jsonList));
  }
}
