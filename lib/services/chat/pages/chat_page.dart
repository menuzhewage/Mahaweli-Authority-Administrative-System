import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/chat_bubble.dart';
import '../components/my_textfield.dart';
import '../services/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String recieverID;
  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.recieverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _authService = FirebaseAuth.instance;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 300),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 300),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatServices.sendMessage(
          widget.recieverID, _messageController.text);

      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.more, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.95),
              colorScheme.surface.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.currentUser!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(widget.recieverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.warning_2, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.message, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send your first message to start the conversation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.currentUser!.uid;
    final theme = Theme.of(context);

    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                widget.receiverEmail,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            userId: data["senderID"],
            messageId: doc.id,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
            child: Text(
              _chatServices.formatTimestamp(data["timestamp"]),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              hintText: "Type a message...",
              obscureText: false,
              controller: _messageController,
              focusNode: _focusNode,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Iconsax.send_1,
                color: theme.colorScheme.onPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}