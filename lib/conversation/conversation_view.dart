import 'package:demo_chat_app/utils/application_state.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:demo_chat_app/user_select_page.dart';
import 'package:demo_chat_app/signin_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conversation_list.dart';

class ConversationPage extends ConsumerWidget {
  static const routename = '/ConversationPage';

  const ConversationPage({Key? key}) : super(key: key);

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
          child: buildConversationList(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, UserSelectPage.routename),
        child: const Icon(Icons.message),
      ),
    );
  }
}
