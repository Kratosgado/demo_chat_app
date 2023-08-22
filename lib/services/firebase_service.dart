import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/user_model.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addUserToFirestore(User user) async {
    await firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<List<User>> getAllUsersFromFirestore() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('users').get();

    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<void> updateUserInFirestore(User user) async {
    await firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUserFromFirestore(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }
}
