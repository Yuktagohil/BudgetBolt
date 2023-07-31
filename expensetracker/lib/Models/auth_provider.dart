import 'package:flutter/material.dart';
import 'package:expensetracker/Models/authservice.dart';
import 'package:expensetracker/Models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  late User _user;

  User get user => _user;

  AuthProvider() {
    _authService.userStream.listen((user) {
      if (user != null) {
        _user = user; // No need for explicit casting
        notifyListeners();
      }
    });
  }

  String getCurrentUserId() {
    final User? user = _authService.getCurrentUser();
    return user?.uid ?? ''; // Return an empty string if the user is not logged in
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    return await _authService.registerWithEmailAndPassword(email, password);
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
