import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flashcard.dart';
import 'folder.dart';
import 'screens/home_screen.dart';
import 'ai_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(FlashcardAdapter());
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(AISettingsAdapter());
    await Hive.openBox<Flashcard>('flashcards');
    await Hive.openBox<AISettings>('ai_settings');
    await Hive.openBox<Folder>('folders');
    runApp(FlashcardApp());
  } catch (e) {
    print('Error initializing Hive: $e');
    // Consider showing an error screen or message
    runApp(ErrorApp(error: e));
  }
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flashcards',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

// Simple error widget to show if initialization fails
class ErrorApp extends StatelessWidget {
  final dynamic error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text('Initialization Error', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Text(error.toString(), textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => main(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}