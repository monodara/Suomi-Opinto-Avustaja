import 'package:hive/hive.dart';

part 'saved_word.g.dart';

@HiveType(typeId: 1) // Increment typeId
class SavedWord extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String pos;

  @HiveField(2)
  String definition;

  @HiveField(3)
  String example;

  @HiveField(4)
  DateTime dateAdded;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  DateTime? _nextReviewDate; // Make nullable in class definition
  DateTime get nextReviewDate => _nextReviewDate ?? (dateAdded ?? DateTime.now()); // Provide default in getter
  set nextReviewDate(DateTime? value) => _nextReviewDate = value;

  @HiveField(7)
  int? _interval; // Make nullable in class definition
  int get interval => _interval ?? 0; // Provide default in getter
  set interval(int? value) => _interval = value;

  @HiveField(8)
  int? _repetitions; // Make nullable in class definition
  int get repetitions => _repetitions ?? 0; // Provide default in getter
  set repetitions(int? value) => _repetitions = value;

  @HiveField(9)
  double? _easeFactor; // Make nullable in class definition
  double get easeFactor => _easeFactor ?? 2.5; // Provide default in getter
  set easeFactor(double? value) => _easeFactor = value;

  @HiveField(10)
  bool? _isLearned; // Make nullable in class definition
  bool get isLearned => _isLearned ?? false; // Provide default in getter
  set isLearned(bool? value) => _isLearned = value;

  @HiveField(11)
  DateTime? _lastLearnedDate; // New field
  DateTime? get lastLearnedDate => _lastLearnedDate;
  set lastLearnedDate(DateTime? value) => _lastLearnedDate = value;

  SavedWord({
    required this.word,
    required this.pos,
    required this.definition,
    required this.example,
    DateTime? dateAdded,
    this.imageUrl,
    DateTime? nextReviewDate,
    int? interval,
    int? repetitions,
    double? easeFactor,
    bool? isLearned,
    DateTime? lastLearnedDate, // New constructor parameter
  })  : dateAdded = dateAdded ?? DateTime.now(),
        _nextReviewDate = nextReviewDate,
        _interval = interval,
        _repetitions = repetitions,
        _easeFactor = easeFactor,
        _isLearned = isLearned,
        _lastLearnedDate = lastLearnedDate; // Initialize new field
}
