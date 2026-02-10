import 'package:flutter/material.dart';
import '../widgets/clickable_words_text.dart';

class ArticleContentDisplay extends StatelessWidget {
  final String date;
  final Map<String, dynamic>? image;
  final List<Map<String, dynamic>> structuredContent;

  const ArticleContentDisplay({
    super.key,
    required this.date,
    this.image,
    required this.structuredContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          if (image != null && (image?['url'] ?? '') != '')
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  image?['url'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          if (image != null && (image?['caption'] ?? '') != '')
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                image?['caption'] ?? '',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ...structuredContent.map<Widget>((item) {
            final text = item['text'] as String? ?? '';
            if (text.trim().isEmpty) return Container(); // Skip empty text
            
            final isHeader = item['type'] == 'h1' || item['type'] == 'h2';
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: isHeader ? 22 : 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                  height: 1.5,
                ),
                child: ClickableWordsText(text: text.trim()),
              ),
            );
          }),
        ],
      ),
    );
  }
}
