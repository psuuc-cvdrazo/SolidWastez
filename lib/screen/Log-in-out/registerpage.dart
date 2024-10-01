import 'package:capstoneapp/components/customtextfield.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/authservice.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final emailto = TextEditingController();
  final phonenumber = TextEditingController();
  final pass = TextEditingController();
  final confirmpass = TextEditingController();

  
  bool _isAgree = false;

  
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();
    
    firstname.addListener(_checkFormFilled);
    lastname.addListener(_checkFormFilled);
    emailto.addListener(_checkFormFilled);
    phonenumber.addListener(_checkFormFilled);
    pass.addListener(_checkFormFilled);
    confirmpass.addListener(_checkFormFilled);
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    emailto.dispose();
    phonenumber.dispose();
    pass.dispose();
    confirmpass.dispose();
    super.dispose();
  }

  
  void _checkFormFilled() {
    setState(() {
      _isFormFilled = firstname.text.isNotEmpty &&
          lastname.text.isNotEmpty &&
          emailto.text.isNotEmpty &&
          phonenumber.text.isNotEmpty &&
          pass.text.isNotEmpty &&
          confirmpass.text.isNotEmpty;
    });
  }

  void signUp() async {
    if (!_isAgree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must agree to the Terms and Conditions."),
        ),
      );
      return;
    }

    if (pass.text != confirmpass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailPassword(
        emailto.text,
        pass.text,
        firstName: firstname.text,
        lastName: lastname.text,
        phonenumber: phonenumber.text,
        firstPassword: confirmpass.text,
      );
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    bool isButtonEnabled = _isFormFilled && _isAgree;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF587F38),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            'Create Account!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),

                    
                    const Text(
                      "First Name:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your first name",
                      tago: false,
                      controller: firstname,
                      types: TextInputType.name,
                    ),
                    const SizedBox(height: 20),

                    
                    const Text(
                      "Last Name:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your last name",
                      tago: false,
                      controller: lastname,
                      types: TextInputType.text,
                    ),
                    const SizedBox(height: 24),

                    
                    const Text(
                      "Contact Number:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your contact number",
                      tago: false,
                      controller: phonenumber,
                      types: TextInputType.text,
                    ),
                    const SizedBox(height: 24),

                    
                    const Text(
                      "Email:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your email",
                      tago: false,
                      controller: emailto,
                      types: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    
                    const Text(
                      "Password:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your password",
                      tago: true,
                      controller: pass,
                      types: TextInputType.text,
                    ),
                    const SizedBox(height: 24),

                    
                    const Text(
                      "Confirm Password:",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextField(
                      hintText: "Enter your confirm password",
                      tago: true,
                      controller: confirmpass,
                      types: TextInputType.text,
                    ),
                    const SizedBox(height: 24),

                    
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgree,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAgree = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: const Color(0xFF587F38),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              
                            },
                            child: const Text(
                              "I agree to the Terms and Conditions",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    
                     ElevatedButton(
                      onPressed: () {
                       signUp();
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
                        'CREATE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
