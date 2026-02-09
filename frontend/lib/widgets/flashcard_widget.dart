import 'package:flutter/material.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:frontend/widgets/clickable_words_text.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool isFlipped;
  final Animation<double> flipAnimation;
  final Function(String word, BuildContext context) fetchPapunetImages;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.isFlipped,
    required this.flipAnimation,
    required this.fetchPapunetImages,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final angle = flipAnimation.value * 3.141592653589793;
        final isUnder = (flipAnimation.value >= 0.5);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isUnder
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.141592653589793),
                  child: _buildBackSide(flashcard, context),
                )
              : _buildFrontSide(flashcard, context),
        );
      },
    );
  }

  Widget _buildFrontSide(Flashcard flashcard, BuildContext context) {
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
                  onPressed: () => fetchPapunetImages(flashcard.word, context),
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

  Widget _buildBackSide(Flashcard flashcard, BuildContext context) {
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
