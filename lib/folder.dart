// folder.dart
import 'package:hive/hive.dart';

part 'folder.g.dart';

@HiveType(typeId: 1)
class Folder {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final String id; // Unique identifier for each folder

  @HiveField(3) // New field for notes
  final String? notes; // Nullable notes field

  Folder({
    required this.name,
    this.color = 0xFFE1E9C9,
    String? id,
    this.notes, // Add notes parameter
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'notes': notes, // Include notes in JSON
  };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    name: json['name'],
    color: json['color'],
    id: json['id'],
    notes: json['notes'], // Include notes from JSON
  );

  // Add copyWith method for easier updates
  Folder copyWith({
    String? name,
    int? color,
    String? id,
    String? notes,
  }) {
    return Folder(
      name: name ?? this.name,
      color: color ?? this.color,
      id: id ?? this.id,
      notes: notes ?? this.notes,
    );
  }
}