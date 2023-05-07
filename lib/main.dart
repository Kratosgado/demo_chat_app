import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'user_select_page.dart';
import 'signin_page.dart';
import 'conversation_page.dart';
import 'chat_page.dart';

import 'settings/settings_service.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;
  const MyApp({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: '/mainpage',
          title: "Demo Chat App",
          debugShowCheckedModeBanner: false,

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case UserSelectPage.routename:
                    return const UserSelectPage();
                  case ChatPage.routename:
                    final ChatPageArguments args =
                        routeSettings.arguments as ChatPageArguments;
                    return ChatPage(
                      arguments: args,
                    );
                  case ConversationPage.routename:
                    return ConversationPage();
                  default:
                    return SigninPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
