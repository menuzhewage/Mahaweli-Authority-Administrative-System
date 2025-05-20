import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.more),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat search and filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                      hintText: 'Search messages...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Iconsax.filter, size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Chat list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildChatItem(context, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Iconsax.message_add),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isUnread = index % 3 == 0; // Every 3rd item is unread for demo
    
    return InkWell(
      onTap: () => _openChatDetail(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUnread 
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/$index.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Chat content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        index % 2 == 0 
                            ? 'Dr. ${['Smith', 'Johnson', 'Williams', 'Brown', 'Jones'][index % 5]}' 
                            : '${['Sarah', 'Emily', 'Jessica', 'Amanda', 'Rachel'][index % 5]} ${['K.', 'M.', 'L.', 'P.', 'S.'][index % 5]}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(index % 12) + 1}:${(index % 60).toString().padLeft(2, '0')} ${index % 2 == 0 ? 'AM' : 'PM'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getSampleMessage(index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSampleMessage(int index) {
    final messages = [
      'Hi there! I have a question about the patient case we discussed...',
      'The lab results came in, please review when you get a chance',
      'Are you available for a consultation tomorrow morning?',
      'I sent you the documents you requested',
      'Reminder: Team meeting at 3pm today',
      'Thanks for your help with the case yesterday!',
      'Can we reschedule our appointment?',
      'Please review the treatment plan I shared',
      'Emergency case - need your input ASAP',
      'FYI - Patient follow-up completed',
    ];
    return messages[index % messages.length];
  }

  void _openChatDetail(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chatIndex: index),
      ),
    );
  }
}

class ChatDetailPage extends StatelessWidget {
  final int chatIndex;

  const ChatDetailPage({super.key, required this.chatIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = chatIndex % 2 == 0 
        ? 'Dr. ${['Smith', 'Johnson', 'Williams', 'Brown', 'Jones'][chatIndex % 5]}' 
        : '${['Sarah', 'Emily', 'Jessica', 'Amanda', 'Rachel'][chatIndex % 5]} ${['K.', 'M.', 'L.', 'P.', 'S.'][chatIndex % 5]}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/${chatIndex % 2 == 0 ? 'men' : 'women'}/$chatIndex.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  chatIndex % 3 == 0 ? 'Online' : 'Last seen today at ${(chatIndex % 12) + 1}:00',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.video),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.more),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              reverse: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                final isMe = index % 3 == 0; // Every 3rd message is from "me"
                return _buildMessageBubble(context, isMe, index);
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.add),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.emoji_happy),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Iconsax.microphone_2),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isMe, int index) {
    final theme = Theme.of(context);
    final messages = [
      'Hi there! How are you doing today?',
      'I have a question about the patient case we discussed yesterday',
      'Are you available for a quick call later?',
      'The lab results came back normal',
      'Please review the documents I shared',
      'Can we reschedule our meeting to tomorrow?',
      'Thanks for your help with this case!',
      'I\'ll send you the details shortly',
      'Emergency situation - need your input ASAP',
      'Patient follow-up completed successfully',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://randomuser.me/api/portraits/${chatIndex % 2 == 0 ? 'men' : 'women'}/$chatIndex.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe 
                    ? theme.colorScheme.primary.withOpacity(0.8)
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messages[index % messages.length],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(index % 12) + 1}:${(index % 60).toString().padLeft(2, '0')} ${index % 2 == 0 ? 'AM' : 'PM'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isMe 
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          index % 4 == 0 ? Iconsax.tick_circle : Iconsax.tick_circle,
                          size: 12,
                          color: index % 4 == 0 
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : Colors.blue,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}