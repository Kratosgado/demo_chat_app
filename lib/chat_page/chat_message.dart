import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String? id;
  final String text;
  final FieldValue timestamp;
  final String senderUid;
  final String? imageUrl; // Optional property for image URL
  final String? emoji; // Optional property for emoji

  Message({
    this.id,
    required this.text,
    required this.timestamp,
    required this.senderUid,
    this.imageUrl,
    this.emoji,
  });

  factory Message.fromJson(String id, Map<String, dynamic> json) {
    return Message(
      id: id,
      text: json['text'],
      timestamp: json['timestamp'],
      senderUid: json['senderUid'],
      imageUrl: json['imageUrl'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp,
      'senderUid': senderUid,
      'imageUrl': imageUrl,
      'emoji': emoji,
    };
  }
}

class ChatMessage extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.indigo : Colors.amber,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              calculateTimeDifference(message.timestamp as Timestamp),
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
