import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeline_tile/timeline_tile.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: LogsScreen()));
}


class Event {
  final String date;
  final String time;
  final String sentiment;
  final String title;
  final String by;
  final String category;
  final String status; 

  Event({
    required this.date,
    required this.time,
    required this.sentiment,
    required this.title,
    required this.by,
    required this.category,
    required this.status,
  });
}

class LogsScreen extends StatefulWidget {
  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String selectedFilter = 'All';
  final CollectionReference logsCollection = FirebaseFirestore.instance.collection('LogsInfo');

 
  List<Event> allEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchLogsFromFirestore();
  }


  Future<void> _fetchLogsFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await logsCollection.get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      
      setState(() {
        allEvents = documents.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Event(
            date: data['dateTimez'].toDate().toString().split(' ')[0],
            time: data['dateTimez'].toDate().toString().split(' ')[1],
            sentiment: data['status'],
            title: data['location'],
            by: data['collectionPoint'], 
            category: 'View', 
            status: data['status'], 
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/blank.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              _buildFilterSelection(),
              Expanded(
                child: allEvents.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _getFilteredEvents().length,
                        itemBuilder: (context, index) {
                          Event event = _getFilteredEvents()[index];
                          return TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.2,
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              color: _getIndicatorColor(event.sentiment),
                            ),
                            beforeLineStyle: const LineStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              thickness: 2,
                            ),
                            startChild: _buildDateTime(event.date, event.time),
                            endChild: _buildCard(event),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildFilterSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton('All'),
          const SizedBox(width: 8),
          _buildFilterButton('Emptied'),
          const SizedBox(width: 8),
          _buildFilterButton('Full'),
        ],
      ),
    );
  }

  
  Widget _buildFilterButton(String filter) {
    bool isSelected = selectedFilter == filter;
    return ChoiceChip(
      label: Text(filter),
      selected: isSelected,
      selectedColor: Colors.blue,
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = filter;
        });
      },
    );
  }

  
  List<Event> _getFilteredEvents() {
    if (selectedFilter == 'All') {
      return allEvents;
    } else {
      return allEvents.where((event) => event.status == selectedFilter).toList();
    }
  }

  
  Color _getIndicatorColor(String sentiment) {
    switch (sentiment) {
      case 'Emptied':
        return Colors.green;
      case 'Full':
        return Colors.red;
      case 'Half':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  
  Widget _buildCard(Event event) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSentimentTag(event.sentiment),
              const SizedBox(height: 10),
              Text(
                event.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.restore_from_trash_rounded, size: 16),
                  const SizedBox(width: 5),
                  Text('${event.by}'),
                ],
              ),
              const SizedBox(height: 5),
              _buildTappableCategoryChip(event.category),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildSentimentTag(String sentiment) {
    Color color = _getIndicatorColor(sentiment);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sentiment,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  
  Widget _buildDateTime(String date, String time) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    );
  }

  
  Widget _buildTappableCategoryChip(String category) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Category Tapped'),
              content: Text('You tapped on the "$category" chip!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Chip(
        label: Text(category),
        backgroundColor: Colors.blue.withOpacity(0.2),
      ),
    );
  }
}
