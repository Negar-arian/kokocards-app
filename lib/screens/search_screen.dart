import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../flashcard.dart';
import '../folder.dart';
import 'scroll_view_screen.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Flashcard> _searchResults = [];
  bool _isSearching = false;

  void _opencard(BuildContext context, Flashcard flashcard) {
    // Find the index of the tapped card using phrase as identifier
    final initialIndex = _searchResults.indexWhere((card) =>
    card.phrase == flashcard.phrase &&
        card.folderId == flashcard.folderId
    );

    if (initialIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScrollViewScreen(
            cards: _searchResults,
            initialIndex: initialIndex, // Start at the tapped card
          ),
        ),
      );
    } else {
      // Fallback to first card if not found (shouldn't happen)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScrollViewScreen(
            cards: _searchResults,
            initialIndex: 0,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final flashcardBox = Hive.box<Flashcard>('flashcards');
    final queryLower = query.toLowerCase();

    // Only search in the phrase field
    final results = flashcardBox.values.where((flashcard) {
      final phrase = flashcard.phrase?.toLowerCase() ?? '';
      return phrase.contains(queryLower);
    }).toList();

    // Sort by phrase match (exact matches first)
    results.sort((a, b) {
      final aPhrase = a.phrase?.toLowerCase() ?? '';
      final bPhrase = b.phrase?.toLowerCase() ?? '';

      // Exact matches come first
      if (aPhrase == queryLower && bPhrase != queryLower) return -1;
      if (bPhrase == queryLower && aPhrase != queryLower) return 1;

      // Then by how early the match appears in the phrase
      final aIndex = aPhrase.indexOf(queryLower);
      final bIndex = bPhrase.indexOf(queryLower);

      if (aIndex != bIndex) {
        return aIndex.compareTo(bIndex);
      }

      // Finally by phrase length (shorter phrases first)
      return aPhrase.length.compareTo(bPhrase.length);
    });

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        backgroundColor: Color(0xFF222831),
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search flashcards...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          autofocus: true,
          onChanged: (value) {
            _performSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _performSearch('');
            },
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          'Enter a search term to find flashcards',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found for "${_searchController.text}"',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final folderBox = Hive.box<Folder>('folders');

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final flashcard = _searchResults[index];
        final folder = folderBox.values.firstWhere(
              (folder) => folder.id == flashcard.folderId,
          orElse: () => Folder(name: 'Unknown', color: 0xFFE1E9C9),
        );

        return Card(
          color:  Color(0xBB444A52),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Color(folder.color).withOpacity(0.3),
                shape: BoxShape.rectangle , borderRadius:  BorderRadius.circular(10),
              ),
              child: Padding(padding: EdgeInsets.all(5)
              ,child: Center(
                    child: Text(
                      folder.name,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),
            title: Text(flashcard.phrase.split('\n')[0] ,style: TextStyle(color: Colors.white),),
            subtitle: Text(flashcard.meaning ?? 'No meaning' ,style: TextStyle(color: Colors.white),),
            onTap: () => _opencard(context, flashcard),
          ),
        );
      },
    );
  }
}
