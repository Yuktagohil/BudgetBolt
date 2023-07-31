import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import '../Models/user.dart' as app;

class AuthService {
   final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Create User object based on FirebaseUser
  app.User? _userFromFirebaseUser(auth.User? user) {
    return user != null ? app.User(uid: user.uid, email: user.email ?? '') : null;
  }



  // Auth change user stream
  Stream<app.User?> get userStream {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<app.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<app.User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  app.User? getCurrentUser() {
    final auth.User? user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }
}
