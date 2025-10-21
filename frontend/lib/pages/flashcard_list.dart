import 'package:flutter/material.dart';
import 'package:frontend/models/flashcard.dart';
import 'package:hive/hive.dart';
import 'flashcard_detail.dart';

class FlashcardListPage extends StatefulWidget {
  const FlashcardListPage({super.key});

  @override
  State<FlashcardListPage> createState() => _FlashcardListPageState();
}

class _FlashcardListPageState extends State<FlashcardListPage> {
  late Box<Flashcard> _flashcardBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _flashcardBox = await Hive.openBox<Flashcard>('flashcards');
    // 监听数据库变化
    _flashcardBox.watch().listen((event) {
      // 当数据库发生变化时刷新UI
      setState(() {});
    });
    setState(() {}); // Refresh
  }

  @override
  void dispose() {
    // 关闭监听流
    _flashcardBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_flashcardBox.isOpen) {
      return const Center(child: CircularProgressIndicator());
    }

    final flashcards = _flashcardBox.values.toList();

    if (flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Ei sanakortteja',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Luo sanakortteja sanakirjan sanoista',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 分类显示：未学会的和已学会的
    final unlearnedCards = flashcards.where((card) => !card.isLearned).toList();
    final learnedCards = flashcards.where((card) => card.isLearned).toList();

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (unlearnedCards.isNotEmpty) ...[
            SectionHeader(title: 'Opiskeltavat (${unlearnedCards.length})'),
            const SizedBox(height: 8),
            ...unlearnedCards.map((card) => _buildFlashcardTile(card, false)),
            const SizedBox(height: 24),
          ],
          if (learnedCards.isNotEmpty) ...[
            SectionHeader(title: 'Opitut (${learnedCards.length})'),
            const SizedBox(height: 8),
            ...learnedCards.map((card) => _buildFlashcardTile(card, true)),
          ],
          if (unlearnedCards.isEmpty && learnedCards.isEmpty) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.style_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ei sanakortteja',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Luo sanakortteja sanakirjan sanoista',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlashcardTile(Flashcard card, bool isLearned) {
    return Dismissible(
      key: Key(card.word + card.pos), // 使用唯一键
      direction: DismissDirection.endToStart, // 只允许从右向左滑动
      onDismissed: (direction) async {
        try {
          final flashcardBox = await Hive.openBox<Flashcard>('flashcards');
          // 查找要删除的卡片在box中的索引
          final boxList = flashcardBox.values.toList();
          int deleteIndex = -1;
          for (int i = 0; i < boxList.length; i++) {
            if (boxList[i].word == card.word && boxList[i].pos == card.pos) {
              deleteIndex = i;
              break;
            }
          }

          if (deleteIndex != -1) {
            await flashcardBox.deleteAt(deleteIndex);
            // 刷新UI
            setState(() {});

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sanakortti poistettu')),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Virhe kortin poistamisessa')),
            );
          }
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            card.word,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                card.pos,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.definition,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${card.createdDate.day}.${card.createdDate.month}.${card.createdDate.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Icon(
            isLearned ? Icons.check_circle : Icons.circle_outlined,
            color: isLearned ? Colors.green : Colors.orange,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlashcardDetailPage(flashcard: card),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
