class NewsItem {
  final String date;
  final String title;
  final List<Map<String, String>> content;
  final Map<String, String>? image;

  NewsItem({
    required this.date,
    required this.title,
    required this.content,
    this.image,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> parsedContent = [];
    for (var block in json['content']) {
      parsedContent.add({'type': block['type'], 'text': block['text']});
    }

    return NewsItem(
      date: json['date'],
      title: json['title'],
      content: parsedContent,
      image: json['image'] != null
          ? {
              'url': json['image']['url'] ?? '',
              'caption': json['image']['caption'] ?? '',
            }
          : null,
    );
  }
}
