import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationManager {
  static late bool isNew;

  Future<String> logInUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AppStrings.noUserFound;
      } else if (e.code == 'wrong-password') {
        return AppStrings.invalidCredentials;
      } else {
        return AppStrings.invalidCredentials;
      }
    }

    return '';
  }

  Future<Map<String, String>> signUpUser(String email, String password) async {
    String key = '';
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null && credential.user!.email != null) {
        key = credential.user!.uid;
        saveUserData(credential.user!.email!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {'error': AppStrings.passwordTooWeak};
      } else if (e.code == 'email-already-in-use') {
        return {'error': AppStrings.alreadyHaveAccount};
      }
    } catch (e) {
      return {'error': e.toString()};
    }

    return {key: ''};
  }

  static Future<void> signOutUser() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.clear();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  void saveUserData(String email) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('userEmail', email);
  }

  bool isLoggedIn(SharedPreferences sharedPref) {
    return sharedPref.getString('userEmail') != null;
  }
}
