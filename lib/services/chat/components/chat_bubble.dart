import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../services/chat/chat_services.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String userId;
  final String messageId;
  

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.userId,
    required this.messageId,
  });

  void showOptions(BuildContext context, String messageID, String userID) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.flag),
                title: const Text('Report Message'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userId);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.profile_remove),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Message', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to report this message? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ChatServices().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Message reported successfully'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Block User', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to block this user? You will no longer receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ChatServices().blockUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('User blocked successfully'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Colors for current user vs other user
    final bubbleColor = isCurrentUser 
        ? colorScheme.primary 
        : colorScheme.surfaceVariant;
    
    final textColor = isCurrentUser 
        ? colorScheme.onPrimary 
        : colorScheme.onSurface;

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          showOptions(context, messageId, userId);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser 
                ? const Radius.circular(16) 
                : const Radius.circular(4),
            bottomRight: isCurrentUser 
                ? const Radius.circular(4) 
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeFormat.format(DateTime.now()), // Placeholder for actual timestamp
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Iconsax.tick_circle,
                    size: 12,
                    color: colorScheme.onPrimary.withOpacity(0.6),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}