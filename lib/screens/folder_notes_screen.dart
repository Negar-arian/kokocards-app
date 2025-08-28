import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../folder.dart';

class FolderNotesScreen extends StatefulWidget {
  final String folderId;

  const FolderNotesScreen({
    Key? key,
    required this.folderId,
  }) : super(key: key);

  @override
  _FolderNotesScreenState createState() => _FolderNotesScreenState();
}

class _FolderNotesScreenState extends State<FolderNotesScreen> {
  late final TextEditingController _notesController;
  late final Folder _currentFolder;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadFolderData();
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
    _notesController.text = _currentFolder.notes ?? '';
  }

  Future<void> _saveNotes() async {
    final folderBox = Hive.box<Folder>('folders');
    final index = folderBox.values.toList().indexWhere((f) => f.id == widget.folderId);

    if (index != -1) {
      final updatedFolder = _currentFolder.copyWith(
        notes: _notesController.text,
      );
      await folderBox.putAt(index, updatedFolder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes saved')),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831), // Set the background color to #222831
      appBar: AppBar(
        title: Text('${_currentFolder.name} Notes'),
        backgroundColor: Color(_currentFolder.color),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNotes,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF222831), // Set the body background to #222831
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _notesController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: TextStyle(color: Colors.white), // Set text color to white for better visibility
            decoration: const InputDecoration(
              hintText: 'Write your notes here...',
              hintStyle: TextStyle(color: Colors.grey), // Set hint text color to grey
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}