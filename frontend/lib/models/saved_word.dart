import 'package:hive/hive.dart';

part 'saved_word.g.dart';

@HiveType(typeId: 0)
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

  SavedWord({
    required this.word,
    required this.pos,
    required this.definition,
    required this.example,
    DateTime? dateAdded,
    this.imageUrl,
  }) : dateAdded = dateAdded ?? DateTime.now();
}
