import 'package:flutter/material.dart';

class SentenceActionDialog extends StatelessWidget {
  final String sentence;

  const SentenceActionDialog({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sentence Actions'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              sentence,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Google Translation API call
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Käännä button pressed! (Translation not yet implemented)')),
                );
              },
              child: const Text('Käännä (Translate)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement LLM Analysis API call
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tekoälyanalyysi button pressed! (AI Analysis not yet implemented)')),
                );
              },
              child: const Text('Tekoälyanalyysi (AI Analysis)'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
