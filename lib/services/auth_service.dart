import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthService{
  //google sign in 
  signInWithGoogle()async{
    //begin interactive sign in process
  final GoogleSignInAccount? gUser =await GoogleSignIn().signIn();

    //obtain auth details from requets
  final GoogleSignInAuthentication gAuth =await gUser!.authentication;
    //create new credential for user
  final credential =GoogleAuthProvider.credential(
    accessToken: gAuth.accessToken,
    idToken:gAuth.idToken,
  );
    //finally,lets sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}