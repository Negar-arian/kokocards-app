import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../flashcard.dart';
import 'package:hive/hive.dart';

class FileIO {
  static Future<String> exportFlashcards(List<Flashcard> cards) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/flashcards_export.json');
    final jsonList = cards.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    return file.path; // return path for sharing
  }

  static Future<void> importFlashcards(File file) async {
    final content = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    final box = Hive.box<Flashcard>('flashcards');

    for (var item in jsonList) {
      final card = Flashcard.fromJson(item);
      box.add(card);
    }
  }
}
