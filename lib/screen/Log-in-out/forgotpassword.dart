import 'package:capstoneapp/screen/Log-in-out/userLogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controller when the widget is removed from the widget tree
    emailController.dispose();
    super.dispose();
  }

  // Function to send password reset email
  Future<void> passReset() async {
    try {
      // Trim spaces from the input email
      String email = emailController.text.trim();

      // Send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // If successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle different error codes
      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'user-not-found') {
        errorMessage = 'Email not found. Please check and try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      }

      // Show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text('Change Your Password',style: TextStyle(color: Colors.white),),
        centerTitle: true,
         leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginScreen(onTap: () {  },)), (route) => false);

          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 15, 63, 20),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
      
              // Lock icon
              const Icon(
                Icons.lock,
                size: 100,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(height: 20),

              // Forgot password title
              const Text(
                'Forgot password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 208, 26),
                ),
              ),
              const SizedBox(height: 10),

              // Instruction text
              const Text(
                'Enter your email address to receive a link to change your pass',
                
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 248, 247, 247)),
              ),
              const SizedBox(height: 30),

              // Email input field
              TextField(
                style: TextStyle(color: Colors.white),
                controller: emailController,
                decoration: InputDecoration(
                  focusColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'E-mail',
                  hoverColor: Colors.white,
                  fillColor: Colors.white,
                  iconColor: Colors.green,
                  suffixIconColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white)
                    
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (value) {
                  emailController.text = value.trim(); // Trim spaces as the user types
                  emailController.selection = TextSelection.fromPosition(
                    TextPosition(offset: emailController.text.length),
                  ); // Maintain cursor position
                },
              ),
              const SizedBox(height: 20),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: passReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color.fromARGB(255, 43, 231, 26),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}