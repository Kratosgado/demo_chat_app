import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_chat_app/chat_page.dart'; // Import the ChatPage

class UserSelectPage extends StatelessWidget {
  const UserSelectPage({super.key});

  static const routename = '/UserSelectPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red, Colors.blue],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final documents = snapshot.data!.docs;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                final userId = doc.id;
                final nickname = doc['nickname'] as String;
                final photoUrl = doc['photoUrl'] as String;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  title: Text(nickname),
                  onTap: () {
                    final currentUserUid =
                        FirebaseAuth.instance.currentUser!.uid;
                    final users = [currentUserUid, userId];
                    final otherUserNickname = nickname;

                    // Create a new conversation and navigate to ChatPage
                    FirebaseFirestore.instance.collection('conversations').add({
                      'users': users,
                      'otherUserNickname': otherUserNickname,
                    }).then((docRef) {
                      final conversationId = docRef.id;
                      Navigator.pushNamed(
                        context,
                        ChatPage.routename,
                        arguments: ChatPageArguments(
                          conversationId: conversationId,
                          users: users,
                          otherUserNickname: otherUserNickname,
                        ),
                      );
                    }).catchError((error) {
                      // Handle error if conversation creation fails
                      debugPrint('Error creating conversation: $error');
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
