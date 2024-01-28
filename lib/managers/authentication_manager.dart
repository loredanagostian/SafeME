import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationManager {
  static late bool isNew;
  static String verifyId = "";

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

  static Future sendOtp(
      {required String phoneNumber,
      required Function errorStep,
      required Function nextStep}) async {
    await FirebaseAuth.instance
        .verifyPhoneNumber(
          timeout: const Duration(seconds: 10),
          phoneNumber: "+4${phoneNumber.trim()}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            return;
          },
          verificationFailed: (FirebaseAuthException e) async {
            return;
          },
          codeSent: (String verificationId, int? resendToken) async {
            verifyId = verificationId;
            nextStep();
          },
          codeAutoRetrievalTimeout: (String verificationId) async {
            return;
          },
        )
        .onError((error, stackTrace) => errorStep());
  }

  static Future<String> loginWithOtp({required String otp}) async {
    final credential =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);

      if (userCredential != null) {
        return "";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          return "The provider has already been linked to the user.";
        case "invalid-credential":
          return "The provider's credential is not valid.";

        case "credential-already-in-use":
          return "The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.";

        // See the API reference for the full list of error codes.
        default:
          return "Unknown error.";
      }
    }

    return "Unknown error.";
  }

  static Future<String> sendForgotPasswordEmail(String email) async {
    String _result = "Unknown error.";

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) => _result = "");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          _result = "The email address is not valid.";
          break;
        case "user-not-found":
          _result = "There is no user corresponding to the email address.";
          break;

        default:
          _result = "Unknown error.";
          break;
      }
    } catch (e) {
      _result = e.toString();
    }

    return _result;
  }
}
