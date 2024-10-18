// lib/features/journal/domain/entities/journal.dart
import 'package:equatable/equatable.dart';

class Journal extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  const Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, createdAt];

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
