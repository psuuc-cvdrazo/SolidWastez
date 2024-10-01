import 'dart:math';

import 'package:capstoneapp/screen/map.dart';
import 'package:capstoneapp/screen/userside/form.dart';
import 'package:capstoneapp/screen/userside/profile.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CollectionPointsScreen extends StatefulWidget {
  final String location;

  CollectionPointsScreen({required this.location});
  _CollectionPointsScreenState createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends State<CollectionPointsScreen> {
  Future<List<Map<String, dynamic>>> _fetchCollectionData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('LogsInfo')
        .where('location', isEqualTo: widget.location)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, String>>> _fetchFeedbackData() async {
    try {
      // Fetch all feedback documents
      QuerySnapshot feedbackSnapshot = await FirebaseFirestore.instance
          .collection('ReportForm')
          .get();

      List<Map<String, String>> feedbackList = [];

      for (var feedbackDoc in feedbackSnapshot.docs) {
        String userEmail = feedbackDoc['email'] ?? '';
        String feedback = feedbackDoc['feedback'] ?? '';

        // Fetch user data based on email
        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (usersSnapshot.docs.isNotEmpty) {
          var userDoc = usersSnapshot.docs.first; // Get the first user doc
          var userData = userDoc.data() as Map<String, dynamic>;
          var userName = userData['firstname'] ?? 'Unknown'; // Handle potential null

          feedbackList.add({
            'name': userName,
            'feedback': feedback,
          });
        } else {
          // If no user found, you can choose to add the feedback with an unknown name
          feedbackList.add({
            'name': 'Unknown',
            'feedback': feedback,
          });
        }
      }

      return feedbackList;
    } catch (e) {
      print('Error fetching feedback data: $e');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Collection Points', style: TextStyle(color: Colors.white),),
       
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 26, 57, 28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder<List<List<Map<String, dynamic>>>>(
                future: Future.wait([_fetchCollectionData(), _fetchFeedbackData()]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching data"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No data available"));
                  }

                  // Get the data from the Future
                  List<Map<String, dynamic>> logsData = snapshot.data![0]; // Logs data
                  List<Map<String, String>> feedbackData = (snapshot.data![1] as List<Map<String, dynamic>>)
    .map((feedback) => feedback.map((key, value) => MapEntry(key, value.toString())))
    .toList();

                  // Display the first log data for now (can be updated to display all data)
                  var log = logsData.first;
                  String formattedDateTime = '';
                  if (log['dateTimez'] is Timestamp) {
                    Timestamp timestamp = log['dateTimez'];
                    DateTime dateTime = timestamp.toDate(); // Convert to DateTime
                    formattedDateTime = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
                  } else {
                    formattedDateTime = log['dateTimez'] ?? 'Unknown';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row with image and status
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white, // White border color
                                width: 4.0, // Border width
                              ),
                            ),
                            child: Image.network(
                              log['imageSource'] ?? 'https://via.placeholder.com/150', // Display fetched image
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error); // Error placeholder
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Garbage Status: ${log['status'] ?? 'Unknown'}', // Display fetched status
                                  style: TextStyle(
                                    color: log['status'] == 'Full' ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  log['status'] == 'Full'
                                      ? 'Needs to be emptied'
                                      : 'Garbage bin is not full',
                                  style: TextStyle(
                                    color: log['status'] == 'Full' ? Colors.red : Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Date and Time\n$formattedDateTime', // Display formatted date and time
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Logs Notification section
                      Text(
                        'Logs Notification',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('2024-05-28 8:53:15'),
                                TextButton(onPressed: () {}, child: Text('View')),
                                Text('Emptied'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('2024-05-28 8:53:15'),
                                TextButton(onPressed: () {}, child: Text('View')),
                                Text('Emptied'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // User Report section
                      Text(
                        'User Report',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: feedbackData.map((data) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raymart Villasis, Pangasinan:\nAng dumi ng city animal ${data['name']}:\n${data['feedback']}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                     Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Raymart Villasis, Pangasinan:\nAng dumi ng city animal',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      'Judge Villasis, Pangasinan:\nYung basurahan puno na.',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
                      SizedBox(height: 16),

                      // Buttons for feedback and request
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Add your feedback action here
                            },
                            child: Text('Give Feedback'),
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Add your request empty action here
                            },
                            child: Text('Request Empty'),
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
