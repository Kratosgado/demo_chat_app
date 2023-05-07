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

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments.otherUserNickname),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(widget.arguments.conversationId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documents = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final doc = documents[index];
                      final sender = doc['sender'] as String;
                      final text = doc['text'] as String;
                      final isCurrentUser = sender == _currentUser!.uid;
                      return ListTile(
                        title: Text(
                          text,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                        tileColor: isCurrentUser ? Colors.blue : Colors.white,
                        subtitle: Text(
                          _currentUser!.displayName!,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
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
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _textEditingController.text.trim();
                      if (text.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection('conversations')
                            .doc(widget.arguments.conversationId)
                            .collection('messages')
                            .add({
                          'text': text,
                          'sender': _currentUser!.uid,
                          'timestamp': Timestamp.now().millisecondsSinceEpoch,
                        });
                        _textEditingController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPageArguments {
  final String conversationId;
  final List<dynamic> users;
  final String otherUserNickname;

  ChatPageArguments({
    required this.conversationId,
    required this.users,
    required this.otherUserNickname,
  });
}
