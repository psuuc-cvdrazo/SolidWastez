import 'package:capstoneapp/services/auth/loginornot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CollectorProfileScreen extends StatefulWidget {
  const CollectorProfileScreen({super.key});

  @override
  State<CollectorProfileScreen> createState() => _CollectorProfileScreenState();
}

class _CollectorProfileScreenState extends State<CollectorProfileScreen> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String contactNumber = "";
  String password = "";
  String schedule = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser; 

    if (user != null) {
      final uid = user.uid;
      final userData = await FirebaseFirestore.instance.collection("Collector").doc(uid).get();

      if (userData.exists) {
        setState(() {
        
          lastName = userData.data()?['lastname'] ?? '';
          email = userData.data()?['email'] ?? '';
          contactNumber = userData.data()?['ContactNumber'] ?? '';
          password = userData.data()?['password'] ?? '';
          schedule = userData.data()?['schedule'] ?? '';
          firstName = userData.data()?['firstname'] ?? '';
        });
      }
    }
  }

  void signout() async {
  try {
    await FirebaseAuth.instance.signOut();
    

   
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginNaba()),
      (Route<dynamic> route) => false,
    );

   
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully")),
    );
  } catch (e) {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error signing out: $e")),
    );
  }
}


  String maskPassword(String password) {
    return '*' * password.length; 
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF587F38),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Profile!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),
                    Text(
                      "FIRSTNAME: $firstName",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "LASTNAME: $lastName",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "PHONE NUMBER: $contactNumber",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "EMAIL: $email",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "PASSWORD: ${maskPassword(password)}", 
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Schedule: $schedule", 
                      style: const TextStyle(color: Colors.white),
                    ),
                   ElevatedButton.icon(
  onPressed: () async {
    
    bool? confirmSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmSignOut == true) {
      signout();
    }
  },
  icon: const Icon(Icons.logout_outlined),
  label: const Text('Sign Out'),
  style: ElevatedButton.styleFrom(
   
  ),
)

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
