import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  static const routename = '/chatpage';

  final ChatPageArguments arguments;

  const ChatPage({required this.arguments, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textEditingController = TextEditingController();
  var peerName, peerDP, peerUid, conversationId, users;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Get and store passed arguments from the user select page
    // Will be used to create conversation
    peerName = widget.arguments.otherUserNickname;
    peerDP = widget.arguments.peerPhoto;
    peerUid = widget.arguments.users[1];
    conversationId = widget.arguments.conversationId;
    users = widget.arguments.users;
  }

  // Get the current user id
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(peerDP!),
            ),
            const SizedBox(width: 8.0),
            Text(peerName!),
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

  //a widget to display already sent messages
  Widget buildMessages() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .collection(conversationId)
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
                final doc = documents[index];
                final sender = doc['sender'] as String;
                final text = doc['text'] as String;
                final isCurrentUser = sender == currentUser.uid;

                return Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? Colors.indigo : Colors.amber,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  //a widget to that will be used to enter messages
  Widget buildInput() {
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
              controller: _textEditingController,
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
              final text = _textEditingController.text.trim();
              if (text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationId)
                    .collection(conversationId)
                    .add({
                  'text': text,
                  'sender': currentUser.uid,
                  'timestamp': Timestamp.now().millisecondsSinceEpoch,
                });
                _textEditingController.clear();
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
