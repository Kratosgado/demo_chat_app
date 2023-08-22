import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:demo_chat_app/utils/application_state.dart';

class SigninPage extends ConsumerWidget {
  const SigninPage({super.key});

  static const routename = '/signinpage';

  @override
  Widget build(BuildContext context, ref) {
    final appState = ref.read(applicationState.notifier);
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
          margin: const EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
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
                    appState.signInWithGoogle(context);
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
