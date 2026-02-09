import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 3)
class Flashcard extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String definition;

  @HiveField(2)
  String example;

  @HiveField(3)
  DateTime nextReviewDate;

  @HiveField(4)
  int interval; // in days

  @HiveField(5)
  int repetitions;

  @HiveField(6)
  double easeFactor;

  @HiveField(7)
  bool isLearned;

  @HiveField(8)
  String pos;

  @HiveField(9)
  DateTime createdDate;

  @HiveField(10)
  String? imageUrl;

  Flashcard({
    required this.word,
    required this.definition,
    required this.example,
    required this.nextReviewDate,
    this.interval = 1,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.isLearned = false,
    required this.pos,
    required this.createdDate,
    this.imageUrl,
  });
}
