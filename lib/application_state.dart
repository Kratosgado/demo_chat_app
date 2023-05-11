import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final applicationState = StateNotifierProvider<ApplicationState, dynamic>((ref) {
  final appState = ApplicationState(false);
  appState.loadState();
  return appState;
});

class ApplicationState extends StateNotifier<dynamic> {
  ApplicationState(state) : super(state);

  bool isLoggedIn = false;

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
