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
      final userData = await FirebaseFirestore.instance
          .collection("Collector")
          .doc(uid)
          .get();

      if (userData.exists) {
        setState(() {
          firstName = userData.data()?['firstname'] ?? '';
          lastName = userData.data()?['lastname'] ?? '';
          email = userData.data()?['email'] ?? '';
          contactNumber = userData.data()?['ContactNumber'] ?? '';
          password = userData.data()?['password'] ?? '';
          schedule = userData.data()?['schedule'] ?? '';
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Title
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Profile Fields
                        _buildProfileInputField("First Name", firstName),
                        const SizedBox(height: 16),
                        _buildProfileInputField("Last Name", lastName),
                        const SizedBox(height: 16),
                        _buildProfileInputField("Phone Number", contactNumber),
                        const SizedBox(height: 16),
                        _buildProfileInputField("Email", email),
                        const SizedBox(height: 16),
                        _buildProfileInputField("Password", maskPassword(password)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInputField(String label, String value) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      controller: TextEditingController(text: value),
    );
  }
}
