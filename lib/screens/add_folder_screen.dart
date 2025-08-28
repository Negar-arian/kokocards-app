// add_folder_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../folder.dart';

class AddFolderScreen extends StatefulWidget {
  @override
  _AddFolderScreenState createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFFE1E9C9);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF222831),
          title: const Text(
            'New Folder',
            style: TextStyle(color: Colors.white),
          )),
      backgroundColor: Color(0xFF222831),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Folder Name' ,labelStyle: TextStyle(color: Colors.white60)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a folder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Choose Color:' , style: TextStyle(color: Colors.white60),),
              const SizedBox(height: 20),
              Wrap(
                spacing: 30,
                runSpacing: 10,
                children: [
                  _buildColorChoice(const Color(0xFFD862BC)),
                  _buildColorChoice(const Color(0xFFF15C5C)),
                  _buildColorChoice(const Color(0xFFF0DE36)),
                  _buildColorChoice(const Color(0xFF5FBDB0)),

                  _buildColorChoice(const Color(0xFFD4E6F1)),  // Light blue
                  _buildColorChoice(const Color(0xFFFF597B)),  // Light yellow
                  _buildColorChoice(const Color(0xFFF5D5E6)),  // Light rose

                  _buildColorChoice(const Color(0xFFFFD6A0)),  // Light seafoam
                  _buildColorChoice(const Color(0xFFF09C67)),  // Light lilac
                  _buildColorChoice(const Color(0xFF5432D3)),  // Light beige
                  _buildColorChoice(const Color(0xFFCF455C)),  // Blush pink
                  _buildColorChoice(const Color(0xFF21AA93)),  // Mint cream
                  _buildColorChoice(const Color(0xFFE9F1D4)),  // Light lime
                  _buildColorChoice(const Color(0xFF895494)),  // Light coral
                  _buildColorChoice(const Color(0xFFBF5CAA)),  // Light periwinkle
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newFolder = Folder(
                      name: _nameController.text,
                      color: _selectedColor.value,
                      notes: '',
                    );
                    Hive.box<Folder>('folders').add(newFolder);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Folder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor.value == color.value
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}