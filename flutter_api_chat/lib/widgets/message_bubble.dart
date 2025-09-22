// lib/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: isError
                  ? Colors.red
                  : Theme.of(context).colorScheme.secondary,
              child: Icon(
                isError ? Icons.error : Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => onCopy(message.text),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : isError
                          ? Colors.red.shade100
                          : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : isError
                                ? Colors.red.shade800
                                : Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isUser
                            ? Colors.white70
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}