import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      SheetsApi.spreadsheetsScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print('Sign in failed: \$error');
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.disconnect();
}
