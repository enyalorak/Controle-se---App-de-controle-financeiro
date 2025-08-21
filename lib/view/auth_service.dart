import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:controlese/models/user_app.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> createUser({required UserApp user}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
      await userCredential.user!.updateDisplayName(user.username);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'O e-mail já está em uso';
      } else if (e.code == 'invalid-email') {
        return 'O e-mail inserido não é válido';
      }
      return null;
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'E-mail ou senha inválidos';
      } else if (e.code == 'user-disabled') {
        return 'O usuário está desabilitado.';
      } else if (e.code == 'invalid-email') {
        return 'O e-mail é inválido.';
      }
      return null;
    }
  }

  Future<String?> loginGoogle() async {
    try {
      await _googleSignIn.signOut();
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
      }
      return null; // <- Adicionado para indicar sucesso
    } on Exception catch (e) {
      //print(e);
      return 'Erro ao logar com a conta Google.';
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
