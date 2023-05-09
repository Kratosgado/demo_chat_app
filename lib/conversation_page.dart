import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:demo_chat_app/user_select_page.dart';
import 'package:demo_chat_app/chat_page.dart';
import 'package:demo_chat_app/signin_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ConversationPage extends StatelessWidget {
  static const routename = '/ConversationPage';

  ConversationPage({Key? key}) : super(key: key);

  final auth = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Select'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              GoogleSignIn().signOut();
              GoogleSignIn().disconnect();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  SigninPage.routename, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.amber,
              Colors.indigo,
            ],
          ),
        ),
        child: Card(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversations')
                .where('users',
                    arrayContains: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('No conversations found.'),
                );
              }

              final documents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final conversationId = doc.id;
                  final users = doc['users'] as List<dynamic>;
                  final otherUserUid = users.firstWhere(
                      (uid) => uid != FirebaseAuth.instance.currentUser!);

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserUid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          leading: const CircleAvatar(),
                          title: const Text('Loading...'),
                          subtitle: const Text(''),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return ListTile(
                          leading: const CircleAvatar(),
                          title: const Text('User not found'),
                          subtitle: const Text(''),
                        );
                      }

                      final peerData =
                          snapshot.data!.data()! as Map<String, dynamic>;
                      final peerDP = peerData['photoUrl'];
                      final peerName = peerData['nickname'];

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('conversations')
                            .doc(conversationId)
                            .collection(conversationId)
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(peerDP),
                              ),
                              title: Text(peerName),
                              subtitle: const Text('Loading...'),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(peerDP),
                              ),
                              title: Text(peerName),
                              subtitle: const Text('No messages'),
                            );
                          }
                          final messageDocs = snapshot.data!.docs;
                          final lastMessage = messageDocs[0];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(peerDP),
                            ),
                            title: Text(peerName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lastMessage['text'] as String),
                                Text(
                                  'Sent: ${lastMessage['timestamp'].toString()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ChatPage.routename,
                                arguments: ChatPageArguments(
                                  conversationId: conversationId,
                                  users: users,
                                  otherUserNickname: peerName,
                                  peerPhoto: peerDP,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, UserSelectPage.routename),
        child: const Icon(Icons.message),
      ),
    );
  }
}
