import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../flashcard.dart';
import '../folder.dart';
import 'add_folder_screen.dart';
import 'search_screen.dart';
import 'folder_content_screen.dart';
import 'about.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel_dart/excel_dart.dart' as excel;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:share_plus/share_plus.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isper = true;
  bool _selecting = false;
  final Set<String> _selectedFolderIds = {};

  get folderColor => null;

  void toggleLanguage() {
    setState(() {
      _isper = !_isper;
    });
}

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar:
      _selecting
          ? AppBar(
        backgroundColor: Color(0xFF00ADB5),
        title: Text('${_selectedFolderIds.length} selected'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: _cancelSelection,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareSelectedFolders,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedFolderIds.isNotEmpty ? _deleteSelectedFolders : null,
          ),
        ],
      )
          : AppBar(

        backgroundColor: Color(0xFF222831),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF222831),
        ),
        child: Column(
          children: [
            if (!_selecting) SizedBox(height: 20),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Folder>('folders').listenable(),
                builder: (context, Box<Folder> folderBox, _) {
                  if (folderBox.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder, size: 60, color: Colors.blueGrey[100]),
                          SizedBox(height: 20),
                          Text(
                            'No folders yet',
                            style: TextStyle(fontSize: 18, color: Colors.blueGrey[100]),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Create your first folder',
                            style: TextStyle(color: Colors.blueGrey[100]),
                          ),
                          SizedBox(height: 80),
                          // Text(
                          //   'Negar_Arian',
                          //   style: TextStyle(color: Colors.blueGrey[50]),
                          // ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width > 900 ? 5 : 3) : 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: folderBox.length,
                    itemBuilder: (context, index) {
                      final folder = folderBox.getAt(index)!;
                      return _buildFolderCard(context, folder, folderBox, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        overlayOpacity: 0.2,
        spaceBetweenChildren: 10,
        icon: Icons.add,
        elevation: 5,
        activeIcon: Icons.close,
        backgroundColor:Color(0xFF00ADB5),
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(

            child: Icon(Icons.file_upload),
            backgroundColor:Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            onTap: _importFolder,  // already defined
          ),
          SpeedDialChild(
            child: Icon(Icons.create_new_folder),
            // label: 'Add Folder',
            backgroundColor: Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            onTap: _addFolder, // already defined
          ),
          SpeedDialChild(
            child: Icon(Icons.search),
            // label: 'Search',
            backgroundColor:Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            onTap: _search, // will define later
          ),

          SpeedDialChild(
            child: Icon(Icons.info),
            backgroundColor: Color(0xFF00ADB5),
            foregroundColor: Colors.white,
            onTap: _navigateToReleaseGuide, // Use the navigation method
            // label: 'Release Guide', // Add a label for clarity
            // labelStyle: TextStyle(
            //   fontWeight: FontWeight.w500,
            //   color: Colors.white,
            //   fontSize: 16.0,
            // ),
            labelBackgroundColor:Color(0xFF00ADB5),
          ),
        ],
      ),
    );
  }

  void _navigateToReleaseGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>  AboutScreen(), // Your guide screen
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, Folder folder, Box<Folder> folderBox, int index) {
    final isSelected = _selectedFolderIds.contains(folder.id);

    return GestureDetector(
      onLongPress: () {
        if (!_selecting) {
          setState(() {
            _selecting = true;
            _selectedFolderIds.add(folder.id);
          });
        }
      },
      onTap: () {
        if (_selecting) {
          setState(() {
            if (isSelected) {
              _selectedFolderIds.remove(folder.id);
              if (_selectedFolderIds.isEmpty) {
                _selecting = false;
              }
            } else {
              _selectedFolderIds.add(folder.id);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FolderContentScreen(folderId: folder.id),
            ),
          );
        }
      },
      child: Card(
        color: Color(0xFF393E46).withOpacity(isSelected ? 0.5 : 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder , size: 50 , color: Color(folder.color),),
                    SizedBox(height: 4),
                    Text(
                      folder.name,
                      style: TextStyle(
                        fontSize: _getFontSize(folder.name),
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: _getFlashcardCount(folder.id),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          '$count ${count == 1 ? 'card' : 'cards'}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_selecting)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDefaultContent();
    });
  }
  double _getFontSize(String? noteText) {
    if (noteText == null || noteText.isEmpty) return 16; // Default size

    final length = noteText.length;

    if (length > 30) return 12;
    if (length> 20) return 13;
    if (length> 10) return 15;
    return 18;
  }
  Future<void> _loadDefaultContent() async {
    final folderBox = Hive.box<Folder>('folders');
    if (folderBox.isEmpty) {
      try {
        final content = await rootBundle.loadString('assets/default/default_content.json');
        final jsonData = jsonDecode(content);

        for (var folderData in jsonData['folders']) {
          // Create folder
          final folder = Folder(
            name: folderData['name'],
            color: folderData['color'],
            notes: folderData['notes'] ?? '',
          );
          await folderBox.add(folder);

          // Add flashcards if they exist
          if (folderData['flashcards'] is List) {
            final flashcardBox = Hive.box<Flashcard>('flashcards');
            for (var cardData in folderData['flashcards']) {
              await flashcardBox.add(Flashcard.fromJson({
                ...cardData,
                'folderId': folder.id,
              }));
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading default content: $e');
      }
    }
  }

  Future<void> _shareSelectedFolders() async {
    if (_selectedFolderIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select folders to share')),
      );
      return;
    }

    final format = await _showExportFormatDialog();
    if (format == null) return;

    try {
      final folderBox = Hive.box<Folder>('folders');
      final flashcardBox = Hive.box<Flashcard>('flashcards');

      // Get selected folders and their flashcards
      final foldersToExport = folderBox.values
          .where((folder) => _selectedFolderIds.contains(folder.id))
          .toList();

      final exportData = {
        'folders': foldersToExport.map((folder) {
          return {
            'name': folder.name,
            'color': folder.color,
            'notes': folder.notes,
            'flashcards': flashcardBox.values
                .where((card) => card.folderId == folder.id)
                .map((card) => card.toJson())
                .toList(),
          };
        }).toList(),
      };

      await _performShare(exportData, format);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: ${e.toString()}')),
      );
    }
  }

  Future<String?> _showExportFormatDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('JSON (Recommended)'),
              onTap: () => Navigator.pop(context, 'json'),
            ),
            ListTile(
              title: Text('Text Summary'),
              onTap: () => Navigator.pop(context, 'text'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performShare(Map<String, dynamic> data, String format) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (format == 'json') {
      final file = File('${tempDir.path}/folders_$timestamp.json');
      await file.writeAsString(jsonEncode(data));
      await Share.shareXFiles([XFile(file.path)],
        subject: '${data['folders'].length} Folders Export',
      );
    } else {
      // Text format
      final textContent = StringBuffer();
      textContent.writeln('Exported ${data['folders'].length} folders\n');

      for (var folder in data['folders']) {
        textContent.writeln('=== ${folder['name']} ===');
        textContent.writeln('Notes: ${folder['notes'] ?? 'No notes'}');
        textContent.writeln('Flashcards: ${folder['flashcards'].length}');
        textContent.writeln();
      }

      await Share.share(textContent.toString());
    }
  }

  Future<void> _importFolder() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xlsx'],
        allowMultiple: false,
      );



      if (result == null || result.files.isEmpty || result.files.first.path == null) {
        return;
      }

      final filePath = result.files.first.path!;
      final file = File(filePath);
      final extension = result.files.first.extension?.toLowerCase() ?? '';

      // Read file content
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      // Handle different JSON structures
      if (decoded is Map && decoded.containsKey('folders')) {
        // Structure with multiple folders
        await _handleMultiFolderImport(decoded['folders']);
      } else if (decoded is List) {
        // Structure with flashcards (single folder)
        final folderName = await _showFolderNameDialog(context, '');
        if (folderName == null || folderName.isEmpty) return;

        await _importFlashcardsToFolder(
          cards: decoded,
          folderName: folderName,
          folderColor: 0xFFFFFFFF, // Default color
          folderNotes: 'Imported on ${DateTime.now().toString()}',
        );
      } else if (decoded is Map && decoded.containsKey('phrase')) {
        // Single flashcard import
        final folderName = await _showFolderNameDialog(context, '');
        if (folderName == null || folderName.isEmpty) return;



        await _importFlashcardsToFolder(
          cards: [decoded],
          folderName: folderName,
          folderColor: 0xFFE1E9C9, // Default color
          folderNotes: 'Single card imported on ${DateTime.now().toString()}',
        );
      } else {
        throw FormatException('Unsupported JSON format');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _showFolderNameDialog(BuildContext context, String defaultName) async {
    final controller = TextEditingController(text: defaultName );
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF222831),
        title: const Text('Folder Name' ,style: TextStyle(color: Colors.white),),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(

            hintStyle: TextStyle(color: Colors.white38),
            hintText: 'Enter folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }



  Future<void> _handleMultiFolderImport(List<dynamic> foldersData) async {
    final folderBox = Hive.box<Folder>('folders');
    final flashcardBox = Hive.box<Flashcard>('flashcards');



    for (var folderData in foldersData) {
      if (folderData is! Map<String, dynamic>) continue;

      int folderColor = folderData['color'] ?? 0xFFE1E9C9;

      if (folderData['color'] == null && folderData['flashcards'] is List) {
        final cards = folderData['flashcards'] as List;
        for (var cardData in cards) {
          if (cardData is Map<String, dynamic> && cardData['color'] != null) {
            folderColor = cardData['color'] as int;
            break; // Use first card's color and stop looking
          }
        }
      }

// Create folder with all properties
      final folder = Folder(
        name: folderData['name'] ?? 'Imported Folder',
        color: folderColor, // Use the first card's color
        notes: folderData['notes'] ?? 'Imported on ${DateTime.now().toString()}',
      );


      // Create folder with all properties
      // final folder = Folder(
      //   name: folderData['name'] ?? 'Imported Folder',
      //   color: folderData['color'] ?? 0xFFE1E9C9,
      //   notes: folderData['notes'] ?? 'Imported on ${DateTime.now().toString()}',
      // );
      await folderBox.add(folder);

      // Import flashcards if they exist
      if (folderData['flashcards'] is List) {
        for (var cardData in folderData['flashcards']) {
          if (cardData is! Map<String, dynamic>) continue;

          await flashcardBox.add(Flashcard.fromJson({
            ...cardData,
            'folderId': folder.id,
          }));
        }
      }
    }


  }

  Future<void> _importFlashcardsToFolder({
    required List<dynamic> cards,
    required String folderName,
    required int folderColor,
    required String folderNotes,
  }) async {
    final folderBox = Hive.box<Folder>('folders');
    final flashcardBox = Hive.box<Flashcard>('flashcards');

    for (var cardData in cards) {
      if (cardData is Map<String, dynamic> && cardData['color'] != null) {
        folderColor = cardData['color'] as int;
        break; // Use first card's color and stop looking
      }
    }

    // Create the folder
    final folder = Folder(
      name: folderName,
      color: folderColor,
      notes: folderNotes,
    );
    await folderBox.add(folder);

    // Import all cards
    int importedCount = 0;
    for (var cardData in cards) {
      try {
        if (cardData is! Map<String, dynamic>) continue;
        await flashcardBox.add(Flashcard.fromJson({
          ...cardData,

          'folderId': folder.id,
        }));
        importedCount++;
      } catch (e) {
        debugPrint('Error importing card: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $importedCount flashcards to "$folderName"' , style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF222831),),
      );
    }
  }



  String _getExcelCellValue(excel.Data? cell) {
    if (cell == null) return '';
    final value = cell.value;
    return value?.toString().trim() ?? '';
  }

  Future<int> _getFlashcardCount(String folderId) async {
    final flashcardBox = Hive.box<Flashcard>('flashcards');
    return flashcardBox.values.where((card) => card.folderId == folderId).length;
  }

  Future<void> _deleteSelectedFolders() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  Color(0xFF333941),
        title: Text('Delete Folders' ,style: TextStyle(color: Colors.white),),
        content: Text('Delete ${_selectedFolderIds.length} folders and all their flashcards?',style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF00ADB5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final folderBox = Hive.box<Folder>('folders');
    final flashcardBox = Hive.box<Flashcard>('flashcards');

    // Delete flashcards first
    final flashcardsToDelete = flashcardBox.values
        .where((card) => _selectedFolderIds.contains(card.folderId))
        .toList();

    for (var flashcard in flashcardsToDelete) {
      final key = flashcardBox.keyAt(flashcardBox.values.toList().indexOf(flashcard));
      await flashcardBox.delete(key);
    }

    // Then delete folders
    final foldersToDelete = folderBox.values
        .where((folder) => _selectedFolderIds.contains(folder.id))
        .toList();

    for (var folder in foldersToDelete) {
      final key = folderBox.keyAt(folderBox.values.toList().indexOf(folder));
      await folderBox.delete(key);
    }



    setState(() {
      _selectedFolderIds.clear();
      _selecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${foldersToDelete.length} folders')),
    );
  }

  void _addFolder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddFolderScreen()),
    );
  }

  void _search() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchScreen()),
    );
  }

  void _about() {
    print("About tapped");
  }

  void _cancelSelection() {
    setState(() {
      _selecting = false;
      _selectedFolderIds.clear();
    });
  }
}

