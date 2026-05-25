import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  final Function(String) onSuggestionSelected;

  const ChatEmptyState({Key? key, required this.onSuggestionSelected})
    : super(key: key);

  static const List<String> _suggestions = [
    "How did my sleep and recovery impact my glucose today?",
    "How are my recent Garmin activities affecting my blood sugar?",
    "Given the last few days, should I adjust my insulin ratio up or down?",
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, size: 64, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can I help you today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask me questions about your current glucose levels, food metrics, exercise trends, and general lifestyle inquiries.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUGGESTED QUESTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _suggestions.map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => onSuggestionSelected(suggestion),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
