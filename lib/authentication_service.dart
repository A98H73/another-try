import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);
  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn({String email, String pass}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: pass);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      print("MESSAGE ERROR");
      print(e.message);
      print(e.code);

      // if (e.code == 'invalid-credential') {
      //   setState(() {
      //     errorString = "Email address appears to be malformed/expired";
      //   });
      // } else if (e.code == 'wrong-password') {
      //   setState(() {
      //     errorString = "Password associated with this email is wrong";
      //   });
      // } else if (e.code == 'user-not-found') {
      //   setState(() {
      //     errorString = "Email has not been registered, please sign up :)";
      //   });
      // } else if (e.code == 'user-disabled') {
      //   setState(() {
      //     errorString = "User with this email has been disabled :(";
      //   });
      // } else if (e.code == 'too-many-requests') {
      //   setState(() {
      //     errorString = "Too many requests, please try again later.";
      //   });
      // } else if (e.code == 'operation-not-allowed') {
      //   setState(() {
      //     errorString = "Signing in with email and password is not enabled";
      //   });
      // } else if (e.code == 'account-exists-with-different-credential') {
      //   setState(() {
      //     errorString =
      //         "Email has already been registered. Reset your password.";
      //   });
      // }
      return e.message;
    }
  }
}
