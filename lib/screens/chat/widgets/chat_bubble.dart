import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mycgmapp/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Alignment alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor =
        message.isUser ? Colors.blue : Colors.grey.shade100;
    final Color textColor = message.isUser ? Colors.white : Colors.black87;
    final double leftMargin = message.isUser ? 64.0 : 0.0;
    final double rightMargin = message.isUser ? 0.0 : 64.0;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(message.isUser ? 16.0 : 0.0),
            bottomRight: Radius.circular(message.isUser ? 0.0 : 16.0),
          ),
          boxShadow: [
            if (!message.isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15.0, height: 1.3),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: TextStyle(
                  color: message.isUser ? Colors.white70 : Colors.grey.shade500,
                  fontSize: 10.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
