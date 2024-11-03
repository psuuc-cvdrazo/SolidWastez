import 'dart:io';
import 'package:path/path.dart';
import 'package:capstoneapp/main.dart';
import 'package:capstoneapp/screen/userside/form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectorPointDetails extends StatefulWidget {
  final String collectionPoint;


  CollectorPointDetails({Key? key, required this.collectionPoint,required}) : super(key: key);

  @override
  _CollectorPointDetailsState createState() => _CollectorPointDetailsState();
}

class _CollectorPointDetailsState extends State<CollectorPointDetails> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> feedbackList = [];
  List<dynamic> fbl = [];
  
  
  final collectionPointController = TextEditingController();
    File? _imageFile;
      final ImagePicker _picker = ImagePicker();
       bool showImage = false;
       bool isLoading = false;


  @override
  void initState() {
    super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCollectorDetailsDialog();
    });

    fetchFeedback().then((data) {
      setState(() {
        feedbackList = data;
        fbl = data;
      });
    }).catchError((e) {
      print('Failed to load feedback: $e');
    });
  }


    Widget _buildImage() {
    if (feedbackList.isEmpty) {
      return Column(
        children: [
          Image.asset(
            'assets/img/def.jpg', 
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
          ),
        ],
      );
    }

    
   return ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: isLoading
        ? Image.asset(
            'assets/images/logspin.gif', 
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          )
        : feedbackList.isNotEmpty && feedbackList[0]['img_fb'] != null && feedbackList[0]['img_fb'].isNotEmpty
            ? Image.network(
                feedbackList[0]['img_fb'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_image.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                'assets/images/default_image.png', 
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
  );
}

   Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      } else {
        
        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.info,
          title: "No Image Captured",
          text: "Please click the camera icon to capture an image.",
          confirmBtnText: "OK",
          barrierDismissible: false,
        );
      }
    } catch (e) {
      
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.error,
        title: "Error",
        text: "Failed to pick image: $e",
        confirmBtnText: "OK",
        barrierDismissible: false,
      );
    }
  }

 bool _isUploading = false; 

Future<void> uploadImage(File file, {VoidCallback? onSuccess}) async {
  try {
    if (!(file.path.endsWith('.jpg') || file.path.endsWith('.png'))) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.error,
        title: "Invalid Image",
        text: "Please select a JPG or PNG image.",
        confirmBtnText: "OK",
        barrierDismissible: false, 
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final fileName = basename(file.path);
    final fileBytes = await file.readAsBytes();

   
    _isUploading = true; 
    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.loading,
      text: "Uploading image...",
      barrierDismissible: false, 
    );

    await supabase.storage.from('img').uploadBinary('feedback_img/$fileName', fileBytes);

    
    _isUploading = false;
    Navigator.pop(navigatorKey.currentContext!); 

    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.success,
      title: "Upload Successful",
      text: "Image uploaded successfully!",
      confirmBtnText: "OK",
      barrierDismissible: false, 
      onConfirmBtnTap: () {
        Navigator.pop(navigatorKey.currentContext!); 
        if (onSuccess != null) {
          onSuccess(); 
        }
      },
    );
  } catch (e) {
    
    if (_isUploading) {
      _isUploading = false;
      Navigator.pop(navigatorKey.currentContext!);
    }

    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.error,
      title: "Upload Failed",
      text: "Failed to upload image: $e",
      confirmBtnText: "OK",
      barrierDismissible: false, 
    );
  }
}


Future<void> submitForm() async {

  if ( _imageFile == null) {
    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.warning,
      title: "Incomplete Form",
      text: "Please fill in all fields and upload an image.",
      confirmBtnText: "OK",
      barrierDismissible: false,
    );
    return;
  }

  
  if (_imageFile != null) {
    await uploadImage(_imageFile!, onSuccess: () async {
      try {
        final supabase = Supabase.instance.client;
        final fileName = basename(_imageFile!.path);
        String? imageUrl = supabase.storage.from('img').getPublicUrl('feedback_img/$fileName');

        // await supabase.from('user_feedback').insert({
        //   "username": firstnameto,
        //   "email": userEmail,
        //   "collection_point": collectionPoint, 
        //   "feedback": userFeedback,
        //   "img_fb": imageUrl,
        //   "created_at": DateTime.now().toIso8601String(),
        // });

       QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.success,
      title: "Feedback Submitted",
      text: "Feedback submitted successfully!",
      confirmBtnText: "OK",
      barrierDismissible: false,
      onConfirmBtnTap: () {
        Navigator.pop(navigatorKey.currentContext!); 

       
       
        _imageFile = null; 
        setState(() {}); 
      },
    );
      } catch (e) {
        QuickAlert.show(
          context: navigatorKey.currentContext!,
          type: QuickAlertType.error,
          title: "Submission Failed",
          text: "Failed to submit feedback: $e",
          confirmBtnText: "OK",
          barrierDismissible: false,
        );
      }
    });
  } else {
    
    QuickAlert.show(
      context: navigatorKey.currentContext!,
      type: QuickAlertType.warning,
      title: "No Image",
      text: "Please upload an image first.",
      confirmBtnText: "OK",
      barrierDismissible: true,
    );
  }
}


  void viewImage() {
    if (_imageFile == null) {
      QuickAlert.show(
        context: navigatorKey.currentContext!,
        type: QuickAlertType.info,
        title: "No Image",
        text: "Please capture an image first.",
        confirmBtnText: "OK",
      );
    } else {
      
      Navigator.push( 
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(imageFile: _imageFile!),
        ),
      );
    }
  }



  Future<List<dynamic>> fetchFeedback() async {
    try {
      final response = await supabase
          .from('user_feedback')
          .select()
          .eq('collection_point', widget.collectionPoint)
          .order('created_at', ascending: false);

      if (response != null) {
        return response as List<dynamic>;
      } else {
        throw Exception('No feedback found.');
      }
    } catch (e) {
      print('Error fetching feedback: $e');
      return [];
    }
  }

  String mapCollectionPoint(String point) {
    switch (point) {
      case 'Point 1':
        return 'Point 1';
      case 'Point 2':
        return 'Point 2';
      default:
        return 'Unknown';
    }
  }

   void _emptyNow() {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0),
          child: _buildReportForm(),
        );
      },
    );
  }

 Widget _buildReportForm() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: Text(
          'REQUEST',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 36),
      const Text("COLLECTION POINT", style: TextStyle(color: Colors.black)),
      
      TextField(
        readOnly: true,
        controller: collectionPointController,
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.black),
          hintText: '${mapCollectionPoint(widget.collectionPoint)}',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      const SizedBox(height: 24),
      
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: _imageFile != null
            ? Image.file(
                _imageFile!,
                width: 400,
                height: 320,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/img/def.jpg', 
                width: 400,
                height: 320,
                fit: BoxFit.cover,
              ),
      ),
      
      Center(
        child: IconButton(
          icon: const Icon(Icons.camera_alt),
          onPressed: pickImage,
        ),
      ),
      
      SizedBox(height: 30),
      
      Center(
        child: ElevatedButton(
          onPressed: _submitForm,
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
  );
}


   void _submitForm() {
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(style: TextStyle(color: Colors.white),'Collection ${mapCollectionPoint(widget.collectionPoint)}'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 47, 61, 2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1B3313),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
  children: [
    Row(
  children: [
    if (showImage) 
      _buildImage() 
    else 
      Text("No image to display"), 
    SizedBox(width: 16.0),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Garbage Status:',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            feedbackList.isNotEmpty
                ? (feedbackList[0]['status'] ?? 'Unknown status')
                : 'Unknown status',
            style: TextStyle(
              fontSize: 22.0,
              color: feedbackList.isNotEmpty && feedbackList[0]['status'] == 'FULL'
                  ? Colors.red
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            feedbackList.isNotEmpty && feedbackList[0]['status'] == 'FULL'
                ? 'Needs to be emptied'
                : 'No immediate action required',
            style: TextStyle(
              fontSize: 14.0,
              color: feedbackList.isNotEmpty && feedbackList[0]['status'] == 'FULL' 
                  ? Colors.redAccent 
                  : Colors.green,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Date and Time:',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            feedbackList.isNotEmpty
                ? _formatDateTime(feedbackList[0]['created_at'])
                : 'No date available',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 15,),
        ],
      ),
    ),
  ],
),
ElevatedButton(
  onPressed: _emptyNow,
  child: Text('               Empty Now!               '),
),

  ],
)

                
              ),
              SizedBox(height: 24.0),
              Text(
                'Logs Notification',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEDF0DC),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'DATE AND TIME',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'IMAGE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'STATUS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: feedbackList.map((feedback) {
                        return _buildLogRow(
                          feedback['created_at'] ?? 'Unknown date',
                          'View',
                          feedback['status'] ?? 'Unknown status',
                          feedback['is_full'] ?? false,
                          feedback,
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImagePath(String collectionPoint) {
    switch (collectionPoint) {
      case 'Point 1':
        return 'assets/img/anonas.png';
      case 'Point 2':
        return 'assets/img/vicente.png';
      default:
        return 'assets/img/default.png';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Widget _buildLogRow(String dateTime, String imageSource, String status, bool isFull, Map<String, dynamic> feedback) {
    IconData icon;
    Color iconColor;

    if (status == 'FULL') {
      icon = Icons.warning;
      iconColor = Colors.red;
    } else if (status == 'EMPTIED') {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      icon = Icons.error;
      iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _formatDateTime(dateTime),
              style: TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (context) => _buildFeedbackDialog(feedback),
                );
              },
              child: Text(
                imageSource,
                style: TextStyle(fontSize: 14.0, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 15.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  status,
                  style: TextStyle(fontSize: 9.0, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 void _showCollectorDetailsDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Collector Point Details"),
          content: Text("This is collector point details."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  showImage = true; 
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackDialog(Map<String, dynamic> feedback) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feedback['img_fb'] != null)
                  Image.network(
                    feedback['img_fb'],
                    fit: BoxFit.cover,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Image.asset(
                          'assets/img/logspin.gif',
                          height: 300,
                          width: 300,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/img/logspin.gif',
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Text(
                  feedback['feedback'] ?? 'No feedback provided',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Reported by: ${feedback['username'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Email: ${feedback['email'] ?? 'No email provided'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(navigatorKey.currentContext!),
          child: Text('Close'),
        ),
      ],
    );
  }
}


class ImageViewerScreen extends StatelessWidget {
  final File imageFile;

  const ImageViewerScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
