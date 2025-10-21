import 'package:hive/hive.dart';

part 'saved_article.g.dart';

@HiveType(typeId: 2)
class SavedArticle {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final Map<String, dynamic>? image;

  @HiveField(4)
  final DateTime savedDate;

  @HiveField(5)
  final List<Map<String, dynamic>> structuredContent;

  SavedArticle({
    required this.title,
    required this.date,
    required this.content,
    this.image,
    required this.savedDate,
    required this.structuredContent,
  });

  factory SavedArticle.fromJson(Map<String, dynamic> json) {
    return SavedArticle(
      title: json['title'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
      image: json['image'] != null ? 
        (json['image'] as Map).cast<String, dynamic>() : 
        null,
      savedDate: json['savedDate'] != null ? 
        DateTime.tryParse(json['savedDate'].toString()) ?? DateTime.now() : 
        DateTime.now(),
      structuredContent: json['structuredContent'] != null ?
        (json['structuredContent'] as List).map((item) => (item as Map).cast<String, dynamic>()).toList() :
        [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'content': content,
      'image': image,
      'savedDate': savedDate.toIso8601String(),
      'structuredContent': structuredContent,
    };
  }
}