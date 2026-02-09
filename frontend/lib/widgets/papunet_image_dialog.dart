import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PapunetImageDialog extends StatefulWidget {
  final String word;
  final Flashcard currentFlashcard;
  final int currentFlashcardIndex;
  final Function(Flashcard updatedFlashcard) onImageSelected;

  const PapunetImageDialog({
    super.key,
    required this.word,
    required this.currentFlashcard,
    required this.currentFlashcardIndex,
    required this.onImageSelected,
  });

  @override
  State<PapunetImageDialog> createState() => _PapunetImageDialogState();
}

class _PapunetImageDialogState extends State<PapunetImageDialog> {
  List<dynamic> _images = [];
  bool _isLoadingImages = true;
  int _currentPage = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchPapunetImages();
  }

  Future<void> _fetchPapunetImages() async {
    setState(() {
      _isLoadingImages = true;
    });
    final encodedWord = Uri.encodeComponent(widget.word);
    final url = Uri.parse('$apiBaseUrl/papunet-images/$encodedWord');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = data['images'] as List;
        setState(() {
          _images = images.length > 4 ? images.sublist(0, 4) : images;
          _isLoadingImages = false;
        });
      } else {
        _showMessage("请求出错: ${response.statusCode}");
        setState(() {
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      _showMessage("网络错误: $e");
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _selectImage() async {
    if (_images.isEmpty) {
      _showMessage("没有图片可供选择");
      return;
    }
    try {
      final image = _images[_currentPage];
      final flashcardBox = await Hive.openBox<Flashcard>('flashcards');
      final updatedFlashcard = Flashcard(
        word: widget.currentFlashcard.word,
        pos: widget.currentFlashcard.pos,
        definition: widget.currentFlashcard.definition,
        example: widget.currentFlashcard.example,
        createdDate: widget.currentFlashcard.createdDate,
        nextReviewDate: widget.currentFlashcard.nextReviewDate,
        isLearned: widget.currentFlashcard.isLearned,
        imageUrl: image['url'],
      );

      await flashcardBox.putAt(widget.currentFlashcardIndex, updatedFlashcard);
      widget.onImageSelected(updatedFlashcard); // Callback to update parent state

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kuva lisätty sanakorttiin'),
          ),
        );
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      _showMessage('Virhe kuvan lisäämisessä: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: _isLoadingImages
          ? SizedBox(
              width: double.maxFinite,
              height: 200,
              child: const Center(child: CircularProgressIndicator()),
            )
          : _images.isEmpty
              ? SizedBox(
                  width: double.maxFinite,
                  height: 150,
                  child: Center(child: Text("没有找到相关图片")),
                )
              : SizedBox(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.width * 0.8 + 50,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final image = _images[index];
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.network(
                                    image['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    color: Colors.black54,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Kuva: Papunet / www.papunet.net",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(width: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == index ? 12 : 8,
                            height: _currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _selectImage,
                              child: const Text('Lisää kuva'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Sulje'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
