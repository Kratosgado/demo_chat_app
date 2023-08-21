import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_chat_app/chat_page/chat_message.dart'; // Import the ChatMessage class

class ChatPage extends StatelessWidget {
  static const routename = '/chatpage';

  final ChatPageArguments arguments;

  const ChatPage({required this.arguments, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(arguments.peerPhoto),
            ),
            const SizedBox(width: 8.0),
            Text(arguments.otherUserNickname),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.amber, Colors.indigo],
          ),
        ),
        padding: const EdgeInsets.all(1.0),
        child: Card(
          child: Column(
            children: [
              buildMessages(),
              buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessages() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .doc(arguments.conversationId)
            .collection(arguments.conversationId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data!.docs;

          return Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final message = Message.fromJson(documents[index].id, documents[index].data());
                // final sender = doc['sender'] as String;
                // final text = doc['text'] as String;
                final isCurrentUser = message.senderUid == FirebaseAuth.instance.currentUser!.uid;
                // final message = Message(text: text, timestamp: DateTime.now(), senderUid: sender);

                return ChatMessage(
                  message: message,
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildInput() {
    final TextEditingController textEditingController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              // Handle image button press
            },
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                icon: IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {},
                ),
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send_rounded),
            onPressed: () {
              final text = textEditingController.text.trim();
              if (text.isNotEmpty) {
                final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                final message = Message(
                  text: text,
                  senderUid: currentUserUid,
                  timestamp: FieldValue.serverTimestamp(),
                ).toJson();

                FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(arguments.conversationId)
                    .collection(arguments.conversationId)
                    .add(message);
                textEditingController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatPageArguments {
  final String conversationId;
  final List<dynamic> users;
  final String otherUserNickname;
  final String peerPhoto;

  ChatPageArguments({
    required this.conversationId,
    required this.users,
    required this.otherUserNickname,
    required this.peerPhoto,
  });
}
