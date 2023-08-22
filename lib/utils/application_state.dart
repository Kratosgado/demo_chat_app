import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:demo_chat_app/conversation/conversation_view.dart';

final applicationState = StateNotifierProvider<ApplicationState, dynamic>((ref) {
  final appState = ApplicationState(false);
  appState.loadState();
  return appState;
});

class ApplicationState extends StateNotifier<dynamic> {
  ApplicationState(state) : super(state);

  bool? isLoggedIn;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    state = isLoggedIn;
    debugPrint("loaded: $isLoggedIn ***************");
  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', state);
    debugPrint("saved: $state *************");
  }

  Future handleSignout() async {
    await auth.signOut();
    await googleSignIn.signOut();
    await googleSignIn.disconnect();
    state = false;
    saveState();
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      debugPrint("checking credentials");
      if (user != null) {
        //check is already sign up
        debugPrint("getting info from database");
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection("users")
            .where('id', isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          //update data to server if new user
          FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {
              'nickname': user.displayName,
              'photoUrl': user.photoURL,
              'id': user.uid,
            },
          );
        }
        state = true;
        saveState();
        Navigator.pushReplacementNamed(context, ConversationPage.routename);
      }
    } catch (e) {
      Text(e.toString());
      debugPrint(e.toString());
    }
  }
}
