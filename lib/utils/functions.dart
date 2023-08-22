import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> uploadImage(File imageFile) async {
  final storageRef =
      FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  final uploadTask = storageRef.putFile(imageFile);

  final snapshot = await uploadTask;
  if (snapshot.state == TaskState.success) {
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }
  return null;
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
