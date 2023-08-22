import 'package:demo_chat_app/chat_page/chat_props';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_chat_app/chat_page/chat_page.dart';

class UserSelectPage extends StatelessWidget {
  const UserSelectPage({super.key});

  static const routename = '/UserSelectPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: Colors.indigo, // Change the app bar color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.amber, Colors.indigo],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: Colors.white,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              final documents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final otherUser = documents[index];
                  final otherUserUid = otherUser.id;
                  final nickname = otherUser['nickname'] as String;
                  final photoUrl = otherUser['photoUrl'] as String;

                  if (otherUserUid == FirebaseAuth.instance.currentUser!.uid) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                      color: Colors.white,
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                          title: Text(
                            nickname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                            final users = [currentUserUid, otherUserUid];

                            // // Create a new conversation and navigate to ChatPage
                            String conversationId;
                            if (currentUserUid.hashCode <= otherUserUid.hashCode) {
                              conversationId = '$currentUserUid - $otherUserUid';
                            } else {
                              conversationId = '$otherUserUid - $currentUserUid';
                            }
                            //create a field for the messages collection
                            //will be used to select users in a conversation
                            FirebaseFirestore.instance
                                .collection('conversations')
                                .doc(conversationId)
                                .set({'users': users}).then((_) {
                              Navigator.pushReplacementNamed(
                                context,
                                ChatPage.routename,
                                arguments: ChatProps(
                                  conversationId: conversationId,
                                  users: users,
                                  otherUserNickname: nickname,
                                  peerPhoto: photoUrl,
                                ),
                              );
                            }).catchError((err) {
                              debugPrint("*********************\nFirebase Error: $err\n********");
                            });
                          }));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
