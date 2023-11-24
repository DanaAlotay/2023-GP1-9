import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //google sign in
  Future<void> SignInWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      if (await _googleSignIn.isSignedIn()) {
        // User is already signed in, handle accordingly
        return;
      }
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        // User canceled the sign-in process
        return;
      }

      // obtaiin auth details from request
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      // create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // finally, lets sign in
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      // Handle the error (e.g., show a snackbar or display an error message)
    }
  }

  bool signdIn() {
    return FirebaseAuth.instance.currentUser == null ? false : true;
  }
}
