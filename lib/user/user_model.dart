import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

class User {
  final String id;
  final String nickname;
  final String photoUrl;

  User({
    required this.id,
    required this.nickname,
    required this.photoUrl,
  });

  // Firebase Firestore conversion methods
  factory User.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      id: snapshot.id,
      nickname: data['nickname'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'photoUrl': photoUrl,
    };
  }

  // SQLite conversion methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nickname: map['nickname'],
      photoUrl: map['photoUrl'],
    );
  }
}
