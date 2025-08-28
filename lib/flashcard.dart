import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 0)
class Flashcard {
  @HiveField(0)
  final String phrase;

  @HiveField(1)
  final String pronunciation;

  @HiveField(2)
  final int stars;

  @HiveField(3)
  final String level;

  @HiveField(4)
  final int color;

  @HiveField(5)
  late final String folderId;

  @HiveField(6)
  final String? meaning;  // Nullable meaning field

  @HiveField(7)
  final String? example;  // Nullable example field

  @HiveField(8)
  final String? note;     // Nullable note field

  Flashcard({
    required this.phrase,
    required this.pronunciation,
    required this.stars,
    required this.level,
    required this.folderId,
    this.color = 0xFFE1E9C9,
    this.meaning,
    this.example,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'phrase': phrase,
    'pronunciation': pronunciation,
    'stars': stars,
    'level': level,
    'color': color,
    'folderId': folderId,
    'meaning': meaning,
    'example': example,
    'note': note,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    phrase: json['phrase'],
    pronunciation: json['pronunciation'],
    stars: json['stars'],
    level: json['level'],
    color: json['color'] ?? 0xFFE1E9C9,
    folderId: json['folderId'],
    meaning: json['meaning'],
    example: json['example'],
    note: json['note'],
  );

  get id => null;

  Flashcard copyWith({
    String? phrase,
    String? pronunciation,
    int? stars,
    String? level,
    int? color,
    String? folderId,
    String? meaning,
    String? example,
    String? note,
  }) {
    return Flashcard(
      phrase: phrase ?? this.phrase,
      pronunciation: pronunciation ?? this.pronunciation,
      stars: stars ?? this.stars,
      level: level ?? this.level,
      color: color ?? this.color,
      folderId: folderId ?? this.folderId,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      note: note ?? this.note,
    );
  }
}