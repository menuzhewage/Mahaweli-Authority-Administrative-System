import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/services/chat/pages/chat_page.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app_layout/app_layout.dart';
import '../services/chat/chat_services.dart';

class ChatHome extends StatelessWidget {
  ChatHome({super.key});

  final ChatServices _chatServices = ChatServices();
  final FirebaseAuth _authService = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {
              // Implement search functionality here
              
            },
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUsersStreamExcludedBlocked(),
      builder: (context, snapshot) {
        // Error State
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Failed to load chats",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _buildUserList(),
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading chats..."),
              ],
            ),
          );
        }

        // Empty State
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.message,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No chats available",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Start a conversation with other users",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        // Data State
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final userData = snapshot.data![index];
            return _buildUserListItem(userData, context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] == _authService.currentUser!.email) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.profile_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          userData["name"],
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          "Tap to start chatting",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppLayout(
                child: ChatPage(
                  receiverEmail: userData["name"],
                  recieverID: userData["uid"],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}