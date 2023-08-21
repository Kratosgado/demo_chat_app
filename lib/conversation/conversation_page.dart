import 'package:demo_chat_app/application_state.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';

import 'package:demo_chat_app/user_select_page.dart';
import 'package:demo_chat_app/chat_page/chat_page.dart';
import 'package:demo_chat_app/signin_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationPage extends ConsumerWidget {
  static const routename = '/ConversationPage';

  ConversationPage({Key? key}) : super(key: key);

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context, ref) {
    final appState = ref.read(applicationState.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Select'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              appState.handleSignout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(SigninPage.routename, (Route<dynamic> route) => false);
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
                .where('users', arrayContains: currentUser.uid)
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
                  // get other user's uid
                  final otherUserUid = users.firstWhere((uid) => uid != currentUser.uid);

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(otherUserUid).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          elevation: 10,
                          child: ListTile(
                            leading: CircleAvatar(),
                            title: Text('Loading...'),
                            subtitle: Text(''),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Card(
                          elevation: 10,
                          child: ListTile(
                            leading: CircleAvatar(),
                            title: Text('User not found'),
                            subtitle: Text(''),
                          ),
                        );
                      }

                      final peerData = snapshot.data!.data()! as Map<String, dynamic>;
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
                          if (snapshot.connectionState == ConnectionState.waiting) {
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
                            return Card(
                              elevation: 10,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(peerDP),
                                ),
                                title: Text(peerName),
                                subtitle: const Text('No messages'),
                              ),
                            );
                          }
                          final messageDocs = snapshot.data!.docs;
                          final lastMessage = messageDocs[0];
                          Timestamp serverTimestamp = lastMessage['timestamp']!;

                          String elapse = calculateTimeDifference(serverTimestamp);

                          return Card(
                            elevation: 10,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(peerDP),
                              ),
                              title: Text(peerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lastMessage['text'] as String),
                                  Text(
                                    'Sent: $elapse',
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
                            ),
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

  String calculateTimeDifference(Timestamp serverTimestamp) {
    DateTime servertime = serverTimestamp.toDate();
    DateTime currentDateTime = DateTime.now();
    Duration difference = currentDateTime.difference(servertime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      int hours = difference.inHours;
      int minutes = difference.inMinutes.remainder(60);
      return '$hours hours $minutes minutes ago';
    } else {
      int days = difference.inDays;
      return '$days days ago';
    }
  }
}
