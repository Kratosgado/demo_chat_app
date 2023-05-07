import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'conversation_page.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  static const routename = '/signinpage';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future handleSignout() async {}

  void _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
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
        Navigator.pushReplacementNamed(context, ConversationPage.routename);
      }
    } catch (e) {
      Text(e.toString());
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
        child: Card(
          margin:
              const EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "DEMO CHAT APP",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MaterialButton(
                  color: Colors.teal[100],
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/googleimage.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Sign in with Google"),
                    ],
                  ),
                  onPressed: () {
                    _signInWithGoogle(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
