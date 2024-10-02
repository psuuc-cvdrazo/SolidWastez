import 'package:capstoneapp/services/auth/loginornot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String contactNumber = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;
      final userData =
          await FirebaseFirestore.instance.collection("Users").doc(uid).get();

      if (userData.exists) {
        setState(() {
          firstName = userData.data()?['firstName'] ?? '';
          lastName = userData.data()?['lastName'] ?? '';
          email = userData.data()?['email'] ?? '';
          contactNumber = userData.data()?['ContactNumber'] ?? '';
          password = userData.data()?['password'] ?? '';
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
      backgroundColor: Colors.white, // Set background to white
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Title
                Center(
                  child: Text(
                    'PROFILE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Change text color to black
                    ),
                  ),
                ),
                const SizedBox(height: 46),

                // First Name Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: const Text("First Name"),
                    subtitle: Text(firstName),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: const Text("Last Name"),
                    subtitle: Text(lastName),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: const Text("Phone Number"),
                    subtitle: Text(contactNumber),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: const Text("Email"),
                    subtitle: Text(email),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: const Text("Password"),
                    subtitle: Text(maskPassword(password)),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Out Button
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
                  icon: const Icon(Icons.logout_outlined, color: Colors.white),
                  label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red sign-out button for clarity
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
