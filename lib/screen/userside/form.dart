import 'dart:io'; // To work with File class
import 'package:capstoneapp/main.dart';
import 'package:image_picker/image_picker.dart'; // Image picker package
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:path/path.dart'; // To get file name
import 'package:capstoneapp/components/customtextfield.dart';
import 'package:capstoneapp/components/readonly.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String email = "";
  String firstname = "";
 
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final collectionPointController = TextEditingController();
  final feedbackController = TextEditingController();
  String? selectedCollectionPoint;
  


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ImagePicker _picker = ImagePicker(); // Image picker instance
  File? _imageFile; // To store the selected image

  @override
  void initState() {
    super.initState();
    fetchProf();
  }

  @override
  void dispose() {
  
    emailController.dispose();
    collectionPointController.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  void fetchProf() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      try {
        final userData = await _firestore.collection("Users").doc(uid).get();
        if (userData.exists) {
          setState(() {
            email = userData.data()?['email'] ?? '';
            emailController.text = email;
            firstname = userData.data()?['firstName'] ?? '';
            firstnameController.text = firstname;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> submitForm() async {
    String firstnameto = firstnameController.text.trim();
    String userEmail = emailController.text.trim();
    String collectionPoint = selectedCollectionPoint ?? '';
    String userFeedback = feedbackController.text.trim();

    if (userEmail.isEmpty || collectionPoint.isEmpty || userFeedback.isEmpty) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: const Text("Please fill in all fields."), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      String? imageUrl;

      // Upload image if one is selected
      if (_imageFile != null) {
        imageUrl = await uploadImageToFirebase(_imageFile!);
      }

      await _firestore.collection("ReportForm").add({
        "username":firstnameto,
        "email": userEmail,
        "collection_point": collectionPoint,
        "feedback": userFeedback,
        "image_url": imageUrl, // Include image URL in the form
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: const Text("Report submitted successfully!"), backgroundColor: Colors.green),
      );

    
      feedbackController.clear();
      setState(() {
        selectedCollectionPoint = null;
        _imageFile = null; // Reset image selection
      });
    } catch (e) {
ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
  SnackBar(content: Text("Failed to submit report: $e"), backgroundColor: Colors.red),
);

    }
  }

  // Method to capture image from camera
  Future<void> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to upload image to Firebase Storage
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = basename(imageFile.path); // Extract the file name
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('report_images/$fileName');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Report Form!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),

                    
                    const SizedBox(height: 24),

                    const Text(
                      "EMAIL",
                      style: TextStyle(color: Colors.white),
                    ),
                    ReadOnlyTo(
                      hintText: email,
                      tago: false,
                      controller: emailController,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "COLLECTION POINT",
                      style: TextStyle(color: Colors.white),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'COLLECTION POINT',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(color: Colors.teal),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      items: ['Point 1', 'Point 2', 'Point 3']
                          .map((point) => DropdownMenuItem(
                                value: point,
                                child: Text(
                                  point,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                      value: selectedCollectionPoint,
                      onChanged: (value) {
                        setState(() {
                          selectedCollectionPoint = value;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "FEEDBACK",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextField(
                      controller: feedbackController,
                      decoration: InputDecoration(
                        labelText: 'FEEDBACK',
                        labelStyle: const TextStyle(color: Colors.black),
                        hintText: 'Type here...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 4,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 24),

                    // const Text(
                    //   "Upload Image",
                    //   style: TextStyle(color: Colors.white),
                    // ),
                    // const SizedBox(height: 10),
                    // ElevatedButton.icon(
                    //   onPressed: pickImageFromCamera,
                    //   icon: const Icon(Icons.camera_alt),
                    //   label: const Text("Capture Image"),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xFF587F38),
                    //   ),
                    // ),
                    const SizedBox(height: 10),

                    // Preview the selected image
                    // if (_imageFile != null)
                    //   Image.file(_imageFile!, height: 200, width: 200, fit: BoxFit.cover),

                    const SizedBox(height: 24),

                    Center(
                      child: ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF587F38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
