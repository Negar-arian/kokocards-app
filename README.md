


# 🎴 KokoCards - Flashcard Learning App

<div align="center">
  
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

</div>
<!-- 
##  App Preview
*(Add screenshots here)*

![Home Screen](screenshots/home.jpg)
![Flashcards](screenshots/cards.jpg)
![Search](screenshots/search.jpg)
-->

## ✨ Features

#### 📂 **Organization System**
- Folder Management:  Create folders with custom colors for categorizing flashcards
- Smart Card System: Add cards with pronunciation, meaning, and example sentences in any Language
- Scoring System: Rate cards (★) to track learning progress
- Folder Notes: Add descriptive notes to each folder
- AI flashcard builder: there is an option in add card page that you can fill the flash card fields using LLM's like deepseek.

#### 🔄 Import & Export
- **Share Flashcards**: Export in multiple formats:
  - Complete folders (with cards and notes)
  - Selected cards as JSON, Excel, or text
  - Individual cards as text
- **Import Support**: Import flashcards from:
  - JSON files (complete folders or loose cards)
  - Excel files (for loose cards)

#### 🔍 Smart Navigation & Search
- **Intelligent Search**: Smart ranking algorithm that:
  - Prioritizes exact matches
  - Favors cards starting with search term
  - Prefers shorter cards over longer ones
  - Shows subtle differences between similar words
- **Flexible Navigation**:
  - Vertical scrolling through all cards
  - Horizontal swipe to flip cards
  - Play mode for selected cards only
  - Sort cards by star rating (descending)

## 🚀 How to Use

### Creating Folders
1. Tap the **+** button on the main screen
2. Select "Create New Folder"
3. Enter folder name and choose a color

### Adding Flashcards
1. Enter any folder
2. Tap the **+** button
3. Fill in card details: (or write the word and click on AI generator)
   - Term/Word
   - Pronunciation
   - Meaning/Definition
   - Example Sentence

### Sharing Content
- **Full Folder**: From main screen, share entire folder with all contents
- **Selected Cards**: Inside folder, select cards and share as JSON/Excel/text
- **Single Card**: From card scroll view, share individual card as text

### Importing Flashcards
1. **From Main Screen**: 
   - Import saved JSON folders (complete with structure)
   - Import loose JSON cards into a new folder
2. **Inside Folder**: 
   - Import cards from Excel files
   - Import cards from JSON files

### Navigation Features
- **Star System**: Daboule click an a card in scroll view to add one (★) to the  card  to prioritize learning
- **Play Mode**: Review only selected cards
- **Smart Scroll**: Scroll through search results to see word variations
<!-- 

## 🏗️ Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── about_screen.dart    # About/Help screen
│   ├── folder_screen.dart   # Folder management
│   ├── card_screen.dart     # Card creation/editing
│   └── search_screen.dart   # Smart search
├── models/
│   ├── folder_model.dart
│   ├── card_model.dart
│   └── note_model.dart
├── services/
│   ├── import_service.dart  # JSON/Excel import
│   ├── export_service.dart  # Sharing functionality
│   └── search_service.dart  # Smart search algorithm
└── widgets/
    ├── card_widget.dart     # Flashcard UI
    ├── folder_widget.dart   # Folder item
    └── search_widget.dart   # Search results
```

-->
## 🛠️ Tech Stack

- **Flutter**  - Cross-platform framework
- **Dart** - Programming language
- **Material Design** - UI components
- **File Handling** - JSON/Excel import/export
- **Share Plugin** - Cross-platform sharing

## 📥 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kokocards.git
   cd kokocards
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Target Audience

- **Language Learners**: Perfect for vocabulary building (mainly for learning korean)
- **Students**: Great for exam preparation
- **Teachers**: Create and share flashcards with students
- **Professionals**: Learn technical terms and concepts

## 📄 Supported Formats

| Format | Import | Export | Description |
|--------|--------|--------|-------------|
| **JSON** | ✅ | ✅ | Complete folder structure |
| **Excel (.xlsx)** | ✅ | ✅ | Flashcard data only |
| **Plain Text** | ❌ | ✅ | Simple card sharing |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License



Copyright (C) 2025 Negar Ariannia

You are free to use, modify, and share this app.
But you MUST:
1. Credit me as the creator
2. Link to my GitHub: https://github.com/negar-arian
3. Keep this notice in your version

No warranties - use at your own risk.

## 📞 Contact & Support

For more flashcards and updates, join our Telegram channel: [@kokocards](https://t.me/kokocards)

---

<div align="center">
  
Made with ❤️ using Flutter

⭐ **Star this repo if you find it useful!**

</div>




