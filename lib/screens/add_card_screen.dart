import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../flashcard.dart';
import '../folder.dart';

class AddCardScreen extends StatefulWidget {
  final String folderId;
  final Flashcard? cardToEdit;

  const AddCardScreen({
    Key? key,
    required this.folderId,
    this.cardToEdit,
  }) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late final Folder _currentFolder;
  final _formKey = GlobalKey<FormState>();
  final _phraseController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _noteController = TextEditingController();

  int _stars = 0;
  String _level = 'II';
  Color _selectedColor = const Color(0xFFFFFFFF);
  final List<String> levels = ["II", "I"];

  @override
  void initState() {
    super.initState();
    _loadFolderData();

    // Initialize with card data if editing
    if (widget.cardToEdit != null) {
      final card = widget.cardToEdit!;
      _phraseController.text = card.phrase;
      _pronunciationController.text = card.pronunciation;
      _meaningController.text = card.meaning ?? '';
      _exampleController.text = card.example ?? '';
      _noteController.text = card.note ?? '';
      _stars = card.stars;
      _level = card.level;
      _selectedColor = Color(card.color);
    }
  }

  @override
  void dispose() {
    _phraseController.dispose();
    _pronunciationController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadFolderData() {
    final folderBox = Hive.box<Folder>('folders');
    _currentFolder = folderBox.values.firstWhere(
          (f) => f.id == widget.folderId,
      orElse: () => Folder(
        name: 'Unknown Folder',
        id: 'default-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    // Set the selected color to folder color by default for new cards only
    if (widget.cardToEdit == null) {
      _selectedColor = Color(_currentFolder.color);
    }
  }

  void _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final cardBox = Hive.box<Flashcard>('flashcards');

      // Create the flashcard
      final card = Flashcard(
        phrase: _phraseController.text,
        pronunciation: _pronunciationController.text,
        stars: _stars,
        level: _level,
        folderId: widget.folderId,
        color: _selectedColor.value,
        meaning: _meaningController.text.isNotEmpty ? _meaningController.text : null,
        example: _exampleController.text.isNotEmpty ? _exampleController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      try {
        if (widget.cardToEdit != null) {
          // Find the exact card to update using multiple fields for uniqueness
          final allCards = cardBox.values.toList();
          int cardIndex = -1;

          for (int i = 0; i < allCards.length; i++) {
            final existingCard = allCards[i];
            if (existingCard.phrase == widget.cardToEdit!.phrase &&
                existingCard.folderId == widget.cardToEdit!.folderId &&
                existingCard.pronunciation == widget.cardToEdit!.pronunciation) {
              cardIndex = i;
              break;
            }
          }

          if (cardIndex != -1) {
            // Get the key for this index and update
            final cardKey = cardBox.keyAt(cardIndex);
            await cardBox.put(cardKey, card);
          } else {
            // If we can't find the exact card, add as new (fallback)
            await cardBox.add(card);
          }
        } else {
          // Add new card
          await cardBox.add(card);
        }


        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cardToEdit != null ? 'Edit Flashcard' : 'Add New Flashcard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF222831),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFF222831),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phrase
                  TextFormField(
                    controller: _phraseController,
                    style: TextStyle(color: Colors.white), // Added white text
                    decoration: InputDecoration(
                      labelText: 'Phrase/Term',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phrase';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Pronunciation
                  TextFormField(
                    controller: _pronunciationController,
                    style: TextStyle(color: Colors.white), // Added white text
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white70),
                      labelText: 'Pronunciation',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Meaning
                  TextFormField(
                    controller: _meaningController,
                    style: TextStyle(color: Colors.white), // Added white text
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white70),
                      labelText: 'Meaning',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Example
                  TextFormField(
                    controller: _exampleController,
                    style: TextStyle(color: Colors.white), // Added white text
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white70),
                      labelText: 'Example Sentence',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Colors.white),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Note
                  TextFormField(
                    controller: _noteController,
                    style: TextStyle(color: Colors.white), // Added white text
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white70),
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Difficulty Level
                  const Text(
                    'Topik Level:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Color(0xFF393E46),
                      value: _level,
                      style: TextStyle(color: Colors.white), // Added white text
                      decoration: InputDecoration(border: InputBorder.none),
                      items: levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _level = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Color
                  const Text(
                    'Card Color:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildColorChoice(Color(_currentFolder.color)), // Folder color
                      _buildColorChoice(const Color(0xFFD862BC)), // Light pink
                      _buildColorChoice(const Color(0xFF72B896)), // Mint
                      _buildColorChoice(const Color(0xFFF6C667)), // Peach
                      _buildColorChoice(const Color(0xFF686EE2)), // Lavender
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  Center(
                    child: Container(
                      height: 60,
                      width: 200 ,
                      child: ElevatedButton(
                        onPressed: _saveFlashcard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blueAccent.withOpacity(0.5),
                        ),
                        child: Text(
                          widget.cardToEdit != null ? 'Update Flashcard' : 'Save Flashcard',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor.value == color.value
                ? Colors.white
                : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}