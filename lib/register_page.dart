import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter/material.dart';
import '/components/my_button.dart';
import '/components/my_textfield.dart';
import '/components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =TextEditingController();

  // sign user Up method
  void signUserUp() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Try  creating  the user
    try {
      //check if password is confirmed 
      if(passwordController.text == confirmPasswordController.text){
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      }
      else{
        //show error message
        showErrorMessage("password don't match");
      }
      // Pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
     //show error message
     showErrorMessage(e.code);
    }
  }

  // Wrong email pop-up message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
          child: Text(
            message,
            style:const TextStyle(color:Colors.white),)));
      },
    );
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView( // 🔹 Fix overflow issue
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                // Logo
                const Icon(Icons.lock, size: 50),

                const SizedBox(height: 25),

                // Welcome message
                Text(
                  'Lets create an account for you!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                // Email text field
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password text field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),
                // confirm Password text field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),


                // Sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: signUserUp),

                const SizedBox(height: 50),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                 // Google & Apple sign-in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap:() => AuthService().signInWithGoogle(), 
                      imagePath: 'lib/assets/images/google.png'),
                    const SizedBox(width: 25),
                    SquareTile(
                      onTap: () => {},
                      imagePath: 'lib/assets/images/apple.png'),
                  ],
                ),
                const SizedBox(height: 50),

                // Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child :const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                  ],
                ),

                const SizedBox(height: 20), // 🔹 Prevents bottom overflow
              ],
            ),
          ),
        ),
      ),
    );
  }
}
