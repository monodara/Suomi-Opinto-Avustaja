import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 3)
class Flashcard extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String pos;

  @HiveField(2)
  String definition;

  @HiveField(3)
  String example;

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  bool isLearned;

  @HiveField(6)
  String? imageUrl;

  Flashcard({
    required this.word,
    required this.pos,
    required this.definition,
    required this.example,
    DateTime? createdDate,
    this.isLearned = false,
    this.imageUrl,
  }) : createdDate = createdDate ?? DateTime.now();
}