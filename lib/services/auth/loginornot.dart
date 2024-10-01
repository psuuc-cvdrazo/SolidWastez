import 'package:capstoneapp/screen/Log-in-out/firstscreen.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginNaba extends StatelessWidget {
  const LoginNaba({super.key});

  Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
     
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return 'user';  
      }

      
      DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
          .collection('Collector')
          .doc(user.uid)
          .get();

      if (collectorDoc.exists) {
        return 'collector';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
              future: getUserRole(),
              builder: (context, AsyncSnapshot<String?> roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasData) {
                  String role = roleSnapshot.data!;
                  if (role == 'collector') {
                    return const HomeScreen();  
                  } else if (role == 'user') {
                    return const UserHomeScreen();  
                  } else {
                    return const Center(child: Text('Role not recognized'));
                  }
                } else {
                  return const Center(child: Text('Error fetching role'));
                }
              },
            );
          } else {
            return const FirstScreen();  
          }
        },
      ),
    );
  }
}
