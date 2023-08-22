import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_chat_app/chat_page/chat_message.dart';

import 'package:image_picker/image_picker.dart';

import '../utils/functions.dart';
import 'chat_props.dart'; // Import the ChatMessage class

class ChatView extends StatefulWidget {
  static const routename = '/ChatView';

  final ChatProps chatprops;

  const ChatView({required this.chatprops, super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  File? selectedImage;

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
              backgroundImage: NetworkImage(widget.chatprops.peerPhoto),
            ),
            const SizedBox(width: 8.0),
            Text(widget.chatprops.otherUserNickname),
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

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
    }
  }

  Widget buildMessages() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.chatprops.conversationId)
            .collection(widget.chatprops.conversationId)
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
      child: Column(
        children: [
          if (selectedImage != null) ...[
            Container(
              height: 150, // Set the desired height of the image preview
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Image.file(selectedImage!),
            ),
            const SizedBox(height: 8.0),
          ],
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  selectImage();
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
                onPressed: () async {
                  final text = textEditingController.text.trim();

                  if (text.isNotEmpty || selectedImage != null) {
                    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

                    // Upload the image to Firebase Storage if selected
                    String? imageUrl;
                    if (selectedImage != null) {
                      imageUrl = await uploadImage(selectedImage!);
                    }

                    final message = Message(
                      text: text,
                      senderUid: currentUserUid,
                      timestamp: Timestamp.now(),
                      imageUrl: imageUrl,
                    ).toJson();

                    FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(widget.chatprops.conversationId)
                        .collection(widget.chatprops.conversationId)
                        .add(message);

                    // Clear the selected image and text input
                    selectedImage = null;
                    textEditingController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
