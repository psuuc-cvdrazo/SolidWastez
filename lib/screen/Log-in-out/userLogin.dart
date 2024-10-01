import 'package:capstoneapp/components/customtextfield.dart';
import 'package:capstoneapp/screen/Log-in-out/forgotpassword.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/Log-in-out/registerpage.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:capstoneapp/services/auth/authservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
    final void Function()? onTap;

  const LoginScreen({super.key,required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async{
    final authService = Provider.of<AuthService>(context, listen:false);

    try{
      await authService.signInWithEmailPassword(emailController.text, passwordController.text);
     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>const UserHomeScreen()), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed In successfully")),
    );
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/blank.png'), 
            fit: BoxFit.cover, 
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/img/boxcol.png'), 
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF587F38), 
                        borderRadius: BorderRadius.circular(20), 
                      ),
                      child: const Text(
                        'Welcome User!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),
                  
                    
                    const SizedBox(height: 20),
                  
                   CustomTextField(hintText: "Email", tago: false, controller: emailController,types: TextInputType.emailAddress, ),
                    const SizedBox(height: 24),
                    
                   CustomTextField(hintText: "Password", tago: true, controller: passwordController, types: TextInputType.text,),
                    const SizedBox(height: 24),
                  
                   ElevatedButton(
                      onPressed: () {
                       signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF587F38), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), 
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                     const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>RegisterScreen(onTap: () {  },)), (route) => false);

                          },
                          child: const Text(
                            'Create New Account',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>ForgotPasswordScreen()), (route) => false);

                          },
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
