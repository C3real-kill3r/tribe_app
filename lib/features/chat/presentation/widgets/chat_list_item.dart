import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final bool isUnread;
  final VoidCallback onTap;
  final String? typingUserName;

  const ChatListItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    this.isUnread = false,
    required this.onTap,
    this.typingUserName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: typingUserName != null
                  ? Theme.of(context).colorScheme.primary
                  : (isUnread ? Colors.white : Colors.grey),
              fontWeight: typingUserName != null || isUnread
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: typingUserName != null ? FontStyle.italic : FontStyle.normal,
            ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnread ? Theme.of(context).colorScheme.primary : Colors.grey,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          if (isUnread) ...[
            const SizedBox(height: 8),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
