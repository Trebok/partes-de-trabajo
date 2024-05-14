import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AutenticacionUsuarios {
  final _gooogleSignIn = GoogleSignIn(scopes: ['https://mail.google.com/']);

  Future inicioSesionGoogle() async {
    try {
      final usuarioGoogle = await _gooogleSignIn.signIn();
      if (usuarioGoogle == null) return;

      final autenticacionGoogle = await usuarioGoogle.authentication;
      final credencialesGoogle = GoogleAuthProvider.credential(
        accessToken: autenticacionGoogle.accessToken,
        idToken: autenticacionGoogle.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credencialesGoogle);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String?> getAccessToken() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final googleUser = await _gooogleSignIn.signInSilently();
      final googleAuth = await googleUser?.authentication;
      return googleAuth?.accessToken;
    }
    return null;
  }

  Future cerrarSesionGoogle() async {
    await _gooogleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
