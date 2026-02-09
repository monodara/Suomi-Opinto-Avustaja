import 'package:flutter/material.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:hive/hive.dart';
import '../utils/aurora_gradient.dart';
import '../widgets/clickable_words_text.dart';
import '../widgets/papunet_image_dialog.dart'; // New import

class FlashcardDetailPage extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardDetailPage({super.key, required this.flashcard});

  @override
  State<FlashcardDetailPage> createState() => _FlashcardDetailPageState();
}

class _FlashcardDetailPageState extends State<FlashcardDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  PageController? _pageController;
  List<Flashcard>? _flashcards;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final flashcardBox = await Hive.openBox<Flashcard>('flashcards');
    final loadedFlashcards = flashcardBox.values.toList();
    int initialIndex = loadedFlashcards.indexOf(widget.flashcard);
    if (initialIndex == -1) initialIndex = 0;
    setState(() {
      _flashcards = loadedFlashcards;
      _currentIndex = initialIndex;
      _pageController = PageController(initialPage: _currentIndex);
      _isLoading = false;
    });
  }

  void _updateFlashcardInList(Flashcard updatedFlashcard) {
    setState(() {
      _flashcards![_currentIndex] = updatedFlashcard;
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_flashcards == null || _flashcards!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Ei kortteja saatavilla')),
      );
    }
    if (_currentIndex < 0 || _currentIndex >= _flashcards!.length) {
      _currentIndex = 0;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraGradient.createAuroraGradient(),
          ),
          child: AppBar(
            title: const Text(
              'SisuHyy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 闪卡滑动视图
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _flashcards!.length,
                    itemBuilder: (context, index) {
                      if (index < 0 || index >= _flashcards!.length) {
                        return Container();
                      }
                      return _buildFlashcardView(_flashcards![index]);
                    },
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _isFlipped = false; // 切换卡片时重置翻转状态
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 页面指示器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_flashcards!.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // 学会按钮
                ElevatedButton(
                  onPressed: _toggleLearnedStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _flashcards![_currentIndex].isLearned
                        ? Colors.green
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _flashcards![_currentIndex].isLearned
                        ? 'Ei opittu'
                        : 'Opittu',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLearnedStatus() async {
    try {
      if (_flashcards == null || _flashcards!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ei kortteja saatavilla'),
            ),
          );
        }
        return;
      }
      if (_currentIndex < 0 || _currentIndex >= _flashcards!.length) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Virheellinen kortin indeksi'),
            ),
          );
        }
        return;
      }
      final flashcardBox = await Hive.openBox<Flashcard>(
        'flashcards',
      );
      final currentCard = _flashcards![_currentIndex];
      final boxList = flashcardBox.values.toList();
      int actualIndex = -1;
      for (int i = 0; i < boxList.length; i++) {
        if (boxList[i].word == currentCard.word &&
            boxList[i].pos == currentCard.pos) {
          actualIndex = i;
          break;
        }
      }
      if (actualIndex == -1 || actualIndex >= boxList.length) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Korttia ei löytynyt tai virheellinen indeksi',
              ),
            ),
          );
        }
        return;
      }
      final updatedFlashcard = Flashcard(
        word: currentCard.word,
        pos: currentCard.pos,
        definition: currentCard.definition,
        example: currentCard.example,
        createdDate: currentCard.createdDate,
        nextReviewDate: currentCard.nextReviewDate, // Keep existing nextReviewDate
        isLearned: !currentCard.isLearned, // Toggle isLearned
        imageUrl: currentCard.imageUrl,
      );
      await flashcardBox.putAt(actualIndex, updatedFlashcard);
      setState(() {
        _flashcards![_currentIndex] = updatedFlashcard;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedFlashcard.isLearned
                  ? 'Merkitty opituksi'
                  : 'Merkitty ei-opituksi',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Virhe: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildFlashcardView(Flashcard flashcard) {
    return GestureDetector(
      onTap: () {
        if (!_isFlipped) {
          _flipController.forward();
        } else {
          _flipController.reverse();
        }
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * 3.141592653589793;
          final isUnder = (_flipAnimation.value >= 0.5);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isUnder
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.141592653589793),
                    child: _buildBackSide(flashcard),
                  )
                : _buildFrontSide(flashcard),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(Flashcard flashcard) {
    return Container(
      key: ValueKey('front_${flashcard.word}'),
      width: 300,
      height: 200, // Fixed height to maintain consistency
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (flashcard.imageUrl != null && flashcard.imageUrl!.isNotEmpty)
            // Word and image layout when image exists
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Word text
                Text(
                  flashcard.word,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ), // Reduced space between text and image
                // Image
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4.0), // Reduced padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        6,
                      ), // Smaller border radius
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Image.network(
                          flashcard.imageUrl!,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80, // Smaller loading container
                              height: 80, // Smaller loading container
                              color: Colors.blue[700],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2, // Thinner loading indicator
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80, // Smaller error container
                              height: 80, // Smaller error container
                              color: Colors.blue[700],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 24, // Smaller icon
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            // Only word layout when no image
            Center(
              child: Text(
                flashcard.word,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          // Positioned the image and AI buttons at the bottom right
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.white, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return PapunetImageDialog(
                          word: flashcard.word,
                          currentFlashcard: flashcard,
                          currentFlashcardIndex: _currentIndex,
                          onImageSelected: _updateFlashcardInList,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    // 预留 AI 生成图片按钮
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AI-kuvan luonti tulossa pian'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide(Flashcard flashcard) {
    return Container(
      key: ValueKey('back_${flashcard.word}'),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 词性和定义
            Text(
              '${flashcard.pos}: ${flashcard.definition}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 例句
            const Text(
              'Esimerkki:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: Colors.black87,
                ),
                child: ClickableWordsText(text: flashcard.example),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
