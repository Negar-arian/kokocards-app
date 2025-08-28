import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flip_card/flip_card.dart';
import 'package:share_plus/share_plus.dart';
import '../flashcard.dart';
import 'add_card_screen.dart';

class ScrollViewScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final int initialIndex;

  const ScrollViewScreen({
    Key? key,
    required this.cards,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ScrollViewScreen> createState() => _ScrollViewScreenState();
}

class _ScrollViewScreenState extends State<ScrollViewScreen> {
  bool _showStarAnimation = false;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _starButtonClicked = false; // Track if star was clicked in current session
  final Map<int, GlobalKey<FlipCardState>> _flipCardKeys = {};
  double _starBurstSize = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    for (int i = 0; i < widget.cards.length; i++) {
      _flipCardKeys[i] = GlobalKey<FlipCardState>();

    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _addStar() async {
    try {
      final box = Hive.box<Flashcard>('flashcards');
      final currentCard = widget.cards[_currentIndex];

      // Always add +1 star

      final updatedCard = currentCard.copyWith(
        stars: currentCard.stars + (_starButtonClicked ? -1 : 1),
      );

      setState(() {
        _showStarAnimation = true;
        widget.cards[_currentIndex] = updatedCard;
        _starButtonClicked = !_starButtonClicked; // Mark as clicked in this session
      });
      _starBurstSize = 0;
      for (var size = 0; size <= 300; size += 35) {
        await Future.delayed(const Duration(milliseconds: 20));
        if (mounted) setState(() => _starBurstSize = size.toDouble());
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _showStarAnimation = false);

      // Update in Hive
      final index = box.values.toList().indexWhere(
              (c) => c.folderId == currentCard.folderId && c.phrase == currentCard.phrase
      );

      if (index != -1) {
        await box.putAt(index, updatedCard);
      }
    } catch (e) {
      debugPrint('Error adding star: $e');
    }
  }

  void _handleHorizontalDrag(DragEndDetails details, int index) {
    if (details.primaryVelocity == null) return;

    final flipCardKey = _flipCardKeys[index];
    if (flipCardKey?.currentState == null) return;

    // Just toggle normally - flip_card package doesn't support directional flipping
    flipCardKey!.currentState!.toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = widget.cards[_currentIndex];
    // Show empty star if not clicked in this session, otherwise show current count

    final showEmptyStar = !_starButtonClicked;

    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_currentIndex + 1}/${widget.cards.length}' ,style: TextStyle( color: Colors.white),),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCurrentCard(),
            tooltip: 'Edit card',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCurrentCard(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(


        children: [


    Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/image1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.cards.length,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _starButtonClicked = false; // Reset for new card
                });
              },
              itemBuilder: (context, index) {
                final card = widget.cards[index];
                return GestureDetector(
                    onDoubleTap: () {
                      _addStar();
                      setState(() {
                        _showStarAnimation = true;
                      });
                      Future.delayed(Duration(milliseconds: 200), () {
                        setState(() {
                          _showStarAnimation = false;
                        });
                      });
                    },
                    onHorizontalDragEnd: (details) => _handleHorizontalDrag(details, index),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.07, // 5% of screen height
                        horizontal: MediaQuery.of(context).size.width * 0.09, // 8% of screen width
                      ),
                      child: FlipCard(
                        key: _flipCardKeys[index],
                        flipOnTouch: false,
                        direction: FlipDirection.HORIZONTAL,
                        front: _buildCardFront(card),
                        back: _buildCardBack(card),
                      ),
                    ));
              },
            ),
          ),
          if (_showStarAnimation)
            Center(
              child: Icon(
                Icons.star,
                color: Colors.white70.withOpacity(0.8),
                // size: _starBurstSize,
                size: _starBurstSize * MediaQuery.of(context).size.width / 400,
              ) ,),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: 180),
        child:FloatingActionButton(
          child: Container(
            constraints: BoxConstraints(minWidth: 70), // Add constraints
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  size: 38,
                  showEmptyStar ? Icons.star_border : Icons.star,
                  color: Colors.white70,

                ),
                Flexible( // Add Flexible or Expanded
                  child: Text(
                    currentCard.stars.toString(),
                    style: const TextStyle(fontSize: 17 , color: Colors.white70),
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _addStar,
        ) ,),
    );
  }

  // Even better approach using LayoutBuilder
  Widget _buildCardFront(Flashcard card) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          color: Color(0xFF222831),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05), // Responsive padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: constraints.maxWidth * 0.6, // 30% of card width
                  height: constraints.maxHeight * 0.02, // 5% of card height
                  decoration: BoxDecoration(
                    color: Color(card.color),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.4), // 40% spacing
                Text(
                  card.phrase,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(card.phrase, constraints.maxWidth , constraints.maxHeight),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.pronunciation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    card.pronunciation,
                    style: const TextStyle(fontSize: 24 , color: Colors.white70),
                  ),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(card.level , style: TextStyle(color: Colors.white70 , fontSize: 25), ),

                    Text(
                      '★ ${card.stars}' ,
                      style: const TextStyle(fontSize: 24, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBack(Flashcard card) {
    return Card(
      color: Color(0xFF222831),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05, // 5% of screen height
          horizontal: MediaQuery.of(context).size.width * 0.03, // 8% of screen width
        ),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (card.meaning?.isNotEmpty ?? false)
              Text(
                card.meaning!,
                style: TextStyle(fontSize: _getFontSize(card.meaning),fontWeight: FontWeight.bold , color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            if (card.example?.isNotEmpty ?? false) ...[

              Text(
                "_____________________ \n${card.example!}",
                style: TextStyle(fontSize: 17 , color: Colors.white),
                maxLines: 10,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (card.note?.isNotEmpty ?? false) ...[

              Text(
                "_____________________ \n ${card.note!}",
                style: TextStyle(fontSize: _getNoteFontSize(card.note ), color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 22,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Spacer(),

          ],
        ),
      ),
    );
  }

  double _getFontSize(String? noteText) {
    if (noteText == null || noteText.isEmpty) return 16; // Default size

    final length = noteText.length;

    if (length > 30) return 21;
    if (length> 20) return 28;
    if (length> 10) return 32;
    return 40;
  }

  void _editCurrentCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(
          folderId: widget.cards[_currentIndex].folderId,
          cardToEdit: widget.cards[_currentIndex],
        ),
      ),
    ).then((editedCard) {
      if (editedCard != null) {
        setState(() {
          widget.cards[_currentIndex] = editedCard;
        });
        _updateCardInHive(editedCard);
      }
    });
  }
  double _getResponsiveFontSize(String text, double maxWidth , double maxHeight) {
    final length = text.length;

    // Base sizes adjusted for screen width
    final baseSize = ((maxWidth * 0.08) + (maxHeight * 0.08))/2; // 10% of card width as base

    if (length > 30) return baseSize * 0.7;
    if (length > 20) return baseSize * 0.8;
    if (length > 10) return baseSize * 0.9;
    return baseSize;
  }
  Future<void> _updateCardInHive(Flashcard editedCard) async {
    try {
      final box = Hive.box<Flashcard>('flashcards');
      final index = box.values.toList().indexWhere(
              (c) => c.folderId == editedCard.folderId && c.phrase == editedCard.phrase
      );
      if (index != -1) {
        await box.putAt(index, editedCard);
      }
    } catch (e) {
      debugPrint('Error updating card: $e');
    }
  }

  Future<void> _shareCurrentCard() async {
    final card = widget.cards[_currentIndex];
    final text = '''
    
   ${card.phrase} (${card.pronunciation})

          ${card.meaning ?? 'N/A'}

           ${card.example ?? 'N/A'}
           
        ${card.level} | stars: ${card.stars}
        
''';

    await Share.share(text);
  }

  double _getNoteFontSize(String? noteText) {
    if (noteText == null || noteText.isEmpty) return 16; // Default size

    final length = noteText.length;

    if (length > 200) return 13; // Very long notes - smaller font
    if (length > 100) return 15;  // Long notes
    if (length > 50) return 17;  // Medium notes
    return 18;                   // Short notes - larger font
  }

}