// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class CloudAuthService {
//   static FirebaseAuth get _auth => FirebaseAuth.instance;

//   static User? get currentUser => _auth.currentUser;
//   static bool get isLoggedIn => _auth.currentUser != null;
//   static Future<UserCredential> signInWithGoogle() async {
//     final googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) {
//       throw Exception('تم إلغاء تسجيل الدخول بجوجل');
//     }

//     final googleAuth = await googleUser.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     return _auth.signInWithCredential(credential);
//   }

//   static Future<void> signOut() async {
//     await GoogleSignIn().signOut();
//     await _auth.signOut();
//   }
// }
