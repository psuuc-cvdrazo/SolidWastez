import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



//sign in
Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // DocumentSnapshot userDoc = await _firestore.collection("Users").doc(userCredential.user!.uid).get();
      // Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // // Set user data in Firestore document
      // _firestore
      //     .collection("Users")
      //     .doc(userCredential.user!.uid)
      //     .set({
      //       'uid': userCredential.user!.uid,
      //       'email': email,
      //       'firstName': userData['firstName'],
      //       'middleName': userData['middleName'],
      //       'lastName': userData['lastName'],
      //     });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }


//signup
  Future<UserCredential> signUpWithEmailPassword(
  String email, 
  String password, 
  {
    required String firstName,
    required String lastName,
    required String phonenumber,
    required String firstPassword,
  
  }) async {
  try {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection("Users").doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'ContactNumber': phonenumber,
      'password': password,
      'FirstPassword': firstPassword,
    });

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw Exception(e.code);
  }
}


  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
 