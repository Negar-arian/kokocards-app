import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../flashcard.dart';
import '../folder.dart';
import 'add_card_screen.dart';
import 'scroll_view_screen.dart';
import 'folder_notes_screen.dart';
import 'package:excel_dart/excel_dart.dart' as excel;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FolderContentScreen extends StatefulWidget {
  final String folderId;

  const FolderContentScreen({Key? key, required this.folderId}) : super(key: key);

  @override
  State<FolderContentScreen> createState() => _FolderContentScreenState();
}

class _FolderContentScreenState extends State<FolderContentScreen> {
  bool _selecting = false;
  bool _isImporting = false;
  Set<int> _selectedIndices = {};
  late final Folder _currentFolder;
  List<Flashcard> _currentFolderCards = [];
  bool _sortByStars = false;
  IconData _starsIcon = Icons.star_border; // Initial icon

  Future<Box<T>> _getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }



  Future<void> _initializeData() async {
    await _getBox<Folder>('folders');
    await _getBox<Flashcard>('flashcards');
    if (mounted) {
      setState(() {
        _loadFolderData();
      });
    }
  }

  void _toggleStarSorting() {
    setState(() {
      _sortByStars = !_sortByStars;
      _starsIcon = _sortByStars ? Icons.star : Icons.star_border;
    });
  }

  Future<void> _loadFolderData() async {
    final folderBox = await _getBox<Folder>('folders');
    setState(() {
      _currentFolder = folderBox.values.firstWhere(
            (f) => f.id == widget.folderId,
        orElse: () => Folder(
          name: 'Unknown Folder',
          id: 'default-${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    });
  }
  Future<void> _importFlashcards() async {
    try {
      setState(() => _isImporting = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'xlsx'],
      );

      if (result == null || result.files.isEmpty || result.files.first.path == null) {
        debugPrint('No file selected');
        return;
      }

      final filePath = result.files.first.path!;
      final file = File(filePath);
      final extension = result.files.first.extension?.toLowerCase() ?? '';
      final box = Hive.box<Flashcard>('flashcards');
      int importedCount = 0;

      debugPrint('Selected file: $filePath with extension: $extension');

      if (extension == 'json') {
        debugPrint('Reading JSON file...');
        final content = await file.readAsString();
        final decoded = jsonDecode(content);

        if (decoded is! List) {
          throw FormatException('Invalid JSON format, root is not a List');
        }

        debugPrint('JSON contains ${decoded.length} items');

        for (var item in decoded) {
          try {
            if (item is! Map<String, dynamic>) {
              debugPrint('Skipping item: not a Map -> $item');
              continue;
            }

            final cardData = Map<String, dynamic>.from(item);
            cardData['folderId'] = widget.folderId;

            final phrase = cardData['phrase']?.toString() ?? '';
            if (!_isStringValid(phrase)) {
              debugPrint('Skipping invalid phrase: "$phrase"');
              continue;
            }

            await box.add(Flashcard.fromJson(cardData));
            debugPrint('Imported card: $phrase');
            importedCount++;
          } catch (e) {
            debugPrint('Error importing card: $e, item: $item');
          }
        }
      } else if (extension == 'xlsx') {
        debugPrint('Reading Excel file...');
        final bytes = await file.readAsBytes();
        final excelDoc = excel.Excel.decodeBytes(bytes);

        // Look for the Flashcards sheet or fall back to the first sheet
        final sheet = excelDoc.tables['Flashcards'] ?? excelDoc.tables.values.first;
        if (sheet == null) {
          throw Exception('No valid sheet found in the Excel file');
        }

        debugPrint('Excel sheet has ${sheet.rows.length} rows (including header)');

        for (var row in sheet.rows.skip(1)) { // Skip header row
          try {
            final phrase = _getExcelCellValue(row[0]); // Phrase
            if (!_isStringValid(phrase)) {
              debugPrint('Skipping invalid/empty phrase in row: $row');
              continue;
            }

            final cardData = {
              'phrase': phrase,
              'meaning': _getExcelCellValue(row[1]),
              'pronunciation': _getExcelCellValue(row[2]),
              'example': _getExcelCellValue(row[3]),
              'level': _getExcelCellValue(row[4]),
              'stars': int.tryParse(_getExcelCellValue(row[5])) ?? 0,
              'color': _currentFolder.color,
              'folderId': widget.folderId,
            };

            await box.add(Flashcard.fromJson(cardData));
            debugPrint('Imported Excel card: $phrase');
            importedCount++;
          } catch (e) {
            debugPrint('Error importing Excel card: $e, row: $row');
          }
        }
      }

      debugPrint('Finished importing. Total: $importedCount');

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Imported $importedCount flashcards ')),
      //   );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${e.toString()}')),
        );
        debugPrint('Full import error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }




  bool _isStringValid(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _getExcelCellValue(excel.Data? cell) {
    if (cell == null) return '';
    final value = cell.value; // <- this is the actual raw value
    return value?.toString().trim() ?? '';
  }



  // bool _isStringValid(String? value) {
  //   if (value == null) return false;
  //   return value.trim() != '';
  // }

  Future<void> _shareFlashcards(List<Flashcard> cards, {String format = 'json'}) async {
    File? tempFile;
    try {
      if (cards.length == 0) {  // Using length == 0
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cards selected for export')),
          );
        }
        return;
      }

      final timestamp = _generateTimestamp();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/flashcards_$timestamp.${format == 'json' ? 'json' : 'xlsx'}';

      if (format == 'json') {
        tempFile = File(filePath);
        await tempFile.writeAsString(jsonEncode(cards.map((c) => c.toJson()).toList()));
      }
      else {
        final excelDoc = excel.Excel.createExcel();
        final sheet = excelDoc['Flashcards'];

        sheet.appendRow(['Phrase', 'Translation','Pronunciation', 'example' , 'Level', 'Stars', 'Color']);

        for (var card in cards) {
          sheet.appendRow([
            card.phrase,
            card.meaning,
            card.pronunciation,
            card.example,
            card.level,
            card.stars.toString(),
            card.color.toString(),
          ]);
        }

        tempFile = File(filePath);
        final bytes = excelDoc.encode();
        if (bytes != null) {
          await tempFile.writeAsBytes(bytes);
        }
      }

      if (tempFile != null && (await tempFile.exists())) {
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          subject: '${_currentFolder.name}',
          text: 'Exported ${cards.length} flashcards',
        );

        Future.delayed(const Duration(seconds: 30), () async {
          try {
            if (tempFile != null && (await tempFile.exists())) {
              await tempFile.delete();
            }
          } catch (e) {
            debugPrint('Cleanup error: $e');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }

      try {
        if (tempFile != null && (await tempFile.exists())) {
          await tempFile.delete();
        }
      } catch (e) {
        debugPrint('Error cleanup failed: $e');
      }
    }
  }
  Future<void> _shareAsText(List<Flashcard> cards) async {
    try {
      if (cards.length == 0) {  // Using length == 0 instead of isEmpty
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cards selected for export')),
          );
        }
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln('       ${_currentFolder.name}');
      buffer.writeln('----------------------------------------');

      for (var card in cards) {
        buffer.writeln(' ${card.phrase}');
        if (_hasContent(card.meaning)) {
          buffer.writeln(' ${card.meaning}');
        }
        if (_hasContent(card.pronunciation)) {
          buffer.writeln('${card.pronunciation}');
        }
        if (_hasContent(card.example)) {
          buffer.writeln('${card.example}');
        }
        if (_hasContent(card.note)) {
          buffer.writeln('${card.note}');
        }
        buffer.writeln('Level: ${card.level}');
        buffer.writeln('Stars: ${card.stars}');
        buffer.writeln('----------------------------------------');
      }

      await Share.share(
        buffer.toString(),
        subject: '${_currentFolder.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing failed: ${e.toString()}')),
        );
      }
    }
  }
  String _generateTimestamp() {
    final now = DateTime.now();
    return [
      now.year.toString(),
      _twoDigits(now.month),
      _twoDigits(now.day),
      _twoDigits(now.hour),
      _twoDigits(now.minute),
    ].join();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _showExportDialog() async {
    if (_selectedIndices.length == 0) {  // Using length == 0
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select flashcards to export')),
        );
      }
      return;
    }

    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  Color(0xFF333942),
        title: const Text('Export Format' , style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('JSON File' , style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'json'),
            ),
            ListTile(
              title: const Text('Excel File', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'xlsx'),
            ),
            ListTile(
              title: const Text('Text (Share Directly)' , style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, 'text'),
            ),
          ],
        ),
      ),
    );

    if (format != null) {
      final cards = _selectedIndices.map((i) => _currentFolderCards[i]).toList();
      if (format == 'text') {
        await _shareAsText(cards);
      } else {
        await _shareFlashcards(cards, format: format);
      }
    }
  }

  Future<void> _deleteSelected() async {
    final box = Hive.box<Flashcard>('flashcards');
    final indicesToDelete = _selectedIndices
        .map((index) => box.values.toList().indexWhere(
          (c) => c.folderId == widget.folderId && c.phrase == _currentFolderCards[index].phrase,
    ))
        .where((index) => index != -1)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indicesToDelete) {
      await box.deleteAt(index);
    }

    setState(() {
      _selectedIndices.clear();
      _selecting = false;
    });
  }

  void _openSelectedCardsView() {
    final selectedCards = _selectedIndices.map((i) => _currentFolderCards[i]).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScrollViewScreen(
          cards: selectedCards,
          initialIndex: 0,
        ),
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, Flashcard card, int index) {
    final isSelected = _selectedIndices.contains(index);

    return Card(
      shadowColor: Colors.grey,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      color: isSelected ? Colors.grey.withOpacity(0.5) : Color(0xFF393E46).withOpacity(0.9),
      shape: RoundedRectangleBorder( // Add this property
        borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(50),
                topLeft: Radius.circular(50),
                topRight: Radius.circular(10),
        ), // Adjust the radius as needed
      ),
      child: InkWell(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(50),
            topLeft: Radius.circular(50),
            topRight: Radius.circular(10),
          ),
        onLongPress: () => setState(() {
          _selecting = true;
          _selectedIndices.add(index);
        }),
        onTap: () {
          if (_selecting) {
            setState(() {
              if (isSelected) {
                _selectedIndices.remove(index);
                if (_selectedIndices.isEmpty) {
                  _selecting = false;
                }
              } else {
                _selectedIndices.add(index);
              }
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScrollViewScreen(
                  cards: _currentFolderCards,
                  initialIndex: index,
                ),
              ),
            );
          }
    },
    child: Padding(
    padding: const EdgeInsets.all(16),
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
    children: [
    Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
    color: Color(card.color),
    shape: BoxShape.circle ,
    ),
    ),
    Expanded(
    child: Center(child:
    Text(
    card.phrase.split('\n')[0],
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold , color: Colors.white70),
    ),),

    ),

    Text(
    ' ★️ ${card.stars} ',
    style: const TextStyle(fontSize: 18, color: Colors.white70),
    ),
    if (_selecting)
    Icon(
    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
    color: Colors.white,
    ),
    ],
    ),
                if (card.pronunciation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                      
                      padding: EdgeInsets.only(left: 135),
                      child: Text(
                    card.pronunciation,
                    style: const TextStyle(fontSize: 16,color: Colors.white70),
                  ))
                ],


              ],
            ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No flashcards in this folder',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first card',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIndices.length == _currentFolderCards.length) {
        // If all are selected, deselect all
        _selectedIndices.clear();
      } else {
        // Select all cards
        _selectedIndices = Set<int>.from(
            Iterable<int>.generate(_currentFolderCards.length)
        );
      }
      // Update selecting state based on selection
      _selecting = _selectedIndices.isNotEmpty;
    });
  }

  List<Widget> _buildAppBarActions() {
    return [

      IconButton(
        icon: Icon(_starsIcon , color: Colors.white70,),
        onPressed: _toggleStarSorting,
        tooltip: 'Sort by stars',
      ),
      if (_selecting && _selectedIndices.isNotEmpty) ...[
        IconButton(
          icon: Icon(
            _selectedIndices.length == _currentFolderCards.length
                ? Icons.deselect
                : Icons.select_all,
          ),
          onPressed: _toggleSelectAll,
          tooltip: _selectedIndices.length == _currentFolderCards.length
              ? 'Deselect all'
              : 'Select all',
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: _openSelectedCardsView,
          tooltip: 'Scroll through selected',
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _deleteSelected,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _showExportDialog,
        ),
      ],
    ];
  }

  SpeedDial _buildSpeedDial() {
    return SpeedDial(
      overlayOpacity: 0.2 ,
      backgroundColor: Color(_currentFolder.color),
      foregroundColor: Colors.white,
      activeChild: const Icon(Icons.close),
      icon: Icons.menu,
      activeIcon: Icons.close,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        // Add Card
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Color(_currentFolder.color),
          foregroundColor: Colors.white,
          // label: 'Add Card',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCardScreen(folderId: widget.folderId),
            ),
          ),
        ),
        // Import Cards
        SpeedDialChild(
          child: _isImporting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.file_upload),
          backgroundColor: Color(_currentFolder.color),
          foregroundColor: Colors.white,
          // label: 'Import Cards',
          onTap: _isImporting ? null : _importFlashcards,
        ),
        // Folder Notes
        SpeedDialChild(
          child: const Icon(Icons.note),
          backgroundColor: Color(_currentFolder.color),
          foregroundColor: Colors.white,
          // label: 'Folder Notes',
          onTap: _openFolderNotes,
        ),
      ],
    );
  }

  bool _hasContent(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.length > 0;  // Using length > 0 instead of isNotEmpty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting
      ? '${_selectedIndices.length}/${_currentFolderCards.length} selected'
          : _currentFolder.name , style: TextStyle( color: Colors.white70),),
        // backgroundColor: Color(_currentFolder.color),
        backgroundColor: Color(0xFF222831),
        foregroundColor: Colors.white70,
        surfaceTintColor: Color(0xFF222831),
        actions: _buildAppBarActions(),
      ),
      body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF222831),
          ),

          child: ValueListenableBuilder(
            valueListenable: Hive.box<Flashcard>('flashcards').listenable(),
            builder: (context, Box<Flashcard> box, _) {
              _currentFolderCards = box.values
                  .where((card) => card.folderId == widget.folderId)
                  .toList();

              if (_sortByStars) {
                _currentFolderCards.sort((a, b) => b.stars.compareTo(a.stars));
              } else {
                // Optional: Add your default sorting here if needed
                // _currentFolderCards.sort((a, b) => a.phrase.compareTo(b.phrase));
              }

              return _currentFolderCards.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _currentFolderCards.length,
                itemBuilder: (context, index) => _buildCardItem(
                  context,
                  _currentFolderCards[index],
                  index,
                ),
              );
            },
          )),
      floatingActionButton: _buildSpeedDial(),
    );
  }
// In the _openFolderNotes method:
  void _openFolderNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderNotesScreen(
          folderId: widget.folderId,
        ),
      ),
    );
  }
}