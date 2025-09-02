// ai_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../ai_settings.dart';

class AISettingsScreen extends StatefulWidget {
  @override
  _AISettingsScreenState createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _customRequirementsController = TextEditingController();

  String _selectedLanguage = 'Korean';
  bool _isGrammar = false;
  int _numberOfExamples = 2;
  bool _translateExamples = true;
  bool _includeHanjaOrPronunciation = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final box = Hive.box<AISettings>('ai_settings');
    final settings = box.isNotEmpty ? box.getAt(0) : null;

    if (settings != null) {
      setState(() {
        _apiKeyController.text = settings.apiKey;
        _selectedLanguage = settings.selectedLanguage;
        _isGrammar = settings.isGrammar;
        _numberOfExamples = settings.numberOfExamples;
        _translateExamples = settings.translateExamples;
        _includeHanjaOrPronunciation = settings.includeHanjaOrPronunciation;
        _customRequirementsController.text = settings.customRequirements;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<AISettings>('ai_settings');
      final settings = AISettings(
        apiKey: _apiKeyController.text.trim(),
        selectedLanguage: _selectedLanguage,
        isGrammar: _isGrammar,
        numberOfExamples: _numberOfExamples,
        translateExamples: _translateExamples,
        includeHanjaOrPronunciation: _includeHanjaOrPronunciation,
        customRequirements: _customRequirementsController.text.trim(),
      );

      await box.clear();
      await box.add(settings);

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _customRequirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKorean = _selectedLanguage == 'Korean';

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Card Maker Settings'),
        backgroundColor: Color(0xFF222831),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFF222831),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // API Key Field
                TextFormField(
                  controller: _apiKeyController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'DeepSeek API Key',
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
                      return 'Please enter your API key';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // Language Selection
                Text('Language:', style: TextStyle(color: Colors.white70)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Korean', style: TextStyle(color: Colors.white)),
                        value: 'Korean',
                        groupValue: _selectedLanguage,
                        onChanged: (value) => setState(() => _selectedLanguage = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('English', style: TextStyle(color: Colors.white)),
                        value: 'English',
                        groupValue: _selectedLanguage,
                        onChanged: (value) => setState(() => _selectedLanguage = value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Content Type
                Text('Content Type:', style: TextStyle(color: Colors.white70)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Phrase', style: TextStyle(color: Colors.white)),
                        value: false,
                        groupValue: _isGrammar,
                        onChanged: (value) => setState(() => _isGrammar = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Grammar', style: TextStyle(color: Colors.white)),
                        value: true,
                        groupValue: _isGrammar,
                        onChanged: (value) => setState(() => _isGrammar = value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Number of Examples
                Text('Number of Examples:', style: TextStyle(color: Colors.white70)),
                DropdownButtonFormField<int>(
                  value: _numberOfExamples,
                  dropdownColor: Color(0xFF393E46),
                  style: TextStyle(color: Colors.white),
                  items: [0, 1, 2, 3]
                      .map((count) => DropdownMenuItem(
                    value: count,
                    child: Text('$count', style: TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _numberOfExamples = value!),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Hanja/Pronunciation
                SwitchListTile(
                  title: Text(
                    isKorean ? 'Include Hanja' : 'Include Pronunciation',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _includeHanjaOrPronunciation,
                  onChanged: (value) => setState(() => _includeHanjaOrPronunciation = value),
                ),

                // Translate Examples
                SwitchListTile(
                  title: Text('Translate Examples', style: TextStyle(color: Colors.white)),
                  value: _translateExamples,
                  onChanged: (value) => setState(() => _translateExamples = value),
                ),
                SizedBox(height: 20),

                // Custom Requirements
                TextFormField(
                  controller: _customRequirementsController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Requirements:',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'You can write:\n- Examples more about education\n- Include comparing it with similar phrases\n- Focus on specific usage contexts',
                    hintStyle: TextStyle(color: Colors.white54),
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
                SizedBox(height: 30),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: Text('Save Settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}