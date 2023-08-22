import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat_page/chat_page.dart';
import '../chat_page/chat_props';
import '../utils/functions.dart';

Widget buildConversationList(context) {
  final currentUser = FirebaseAuth.instance.currentUser!;

  return StreamBuilder<QuerySnapshot>(
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

                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(peerDP),
                        ),
                        title: Text(peerName),
                        subtitle: const Text('No messages'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ChatPage.routename,
                            arguments: ChatProps(
                              conversationId: conversationId,
                              users: users,
                              otherUserNickname: peerName,
                              peerPhoto: peerDP,
                            ),
                          );
                        },
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
                          arguments: ChatProps(
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
  );
}
