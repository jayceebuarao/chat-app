import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages yet...'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final loadedMessages = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();

              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userID'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userID'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userimage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            },
          ),
        );
      },
    );
  }
}
