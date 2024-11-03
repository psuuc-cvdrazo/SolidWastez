import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:capstoneapp/screen/userside/detail.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0;
  int len = encoded.length;
  int lat = 0;
  int lng = 0;

  while (index < len) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    polyline.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
  }
  return polyline;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _currentLocation = const LatLng(15.992436859512932, 120.58248462748088); 
  final LatLng _anotherLocation = const LatLng(15.984517543933535, 120.57538313686358); 
  LatLng? _userLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final double _zoomLevel = 17.0;
  double _distanceToDestination = 0.0; 
String _estimatedTime = ''; 

  bool _showCurrentPolylines = false;
  bool _showAnotherPolylines = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        print('Location permissions are denied.');
        return;
      }
    }

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _addMarker();
        _updateCamera();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<double> _calculateDistance(LatLng origin, LatLng destination) async {
  return Geolocator.distanceBetween(
    origin.latitude,
    origin.longitude,
    destination.latitude,
    destination.longitude,
  ) / 1000;
}

  Future<List<LatLng>> _getRoutePolyline(LatLng origin, LatLng destination) async {
    const apiKey = '5b3ce3597851110001cf6248ecbc6d0f1a8d48b59b0a4a1e43531e2b'; 
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

      final List<LatLng> points = coordinates.map((coord) {
        return LatLng(coord[1], coord[0]);
      }).toList();

      return points;
    } else {
      print('Failed to load route: ${response.statusCode}');
      throw Exception('Failed to load route');
    }
  }

 void _addMarker() async {
  if (mapController != null) {
    var markerIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/img/binz.png');
  
    setState(() {
      
     _markers.add(
  Marker(
    markerId: const MarkerId('current_location'),
    position: _currentLocation,
    icon: markerIcon,
    onTap: () {
      _showMarkerInfo(
        title: 'Brgy. Anonas, Urdaneta City, Pangasinan Trashbin',
        snippet: 'Anonas Road',
        imagePath: 'assets/img/anonas.png',
        onGetPressed: () {
          _togglePolylinesForCurrentLocation();
        },
        onGetPressed2: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CollectionPointsScreen(
                collectionPoint: 'Point 1',
              ),
            ),
          );
        },
        destination: _currentLocation,
      );
    },
  ),
);

      if (_userLocation != null) {
        
  _markers.add(
    Marker(
      markerId: const MarkerId('user_location'),
      position: _userLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () {
        userMarker(
          title: 'Your Location',
          snippet: 'You are here',
          imagePath: 'assets/img/walks.gif',
          onGetPressed: () {},
        onGetPressed2: (){},
      showGotItButton: false
        );
      },
    ),
  );
}


    
   _markers.add(
  Marker(
    markerId: const MarkerId('another_location'),
    position: _anotherLocation,
    icon: markerIcon,
    onTap: () {
      _showMarkerInfo(
        title: 'Brgy. San Vicente, Urdaneta City, Pangasinan Trashbin',
        snippet: 'San Vicente Road',
        imagePath: 'assets/img/anonas.png',
        onGetPressed: () {
          _togglePolylinesForAnotherLocation();
        },
        onGetPressed2: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CollectionPointsScreen(
                collectionPoint: 'Point 2',
              ),
            ),
          );
        },
        destination: _currentLocation,
      );
    },
  ),
);

    });
  }
}




 void _showMarkerInfo({
  required String title,
  required String snippet,
  required String imagePath,
  required Function onGetPressed,
  required Function onGetPressed2,
  required LatLng destination,
  bool showGotItButton = false,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollectionPointsScreen(collectionPoint: ''),
                  ),
                  (route) => false,
                );
                print('Image tapped!');
              },
              child: Image.asset(
                imagePath,
                height: 150,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 40, 59, 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                      // Calculate distance and route polyline for the selected destination
                    double distance = await _calculateDistance(_userLocation!, destination);
                    List<LatLng> polylinePoints = await _getRoutePolyline(_userLocation!, destination);

                    // Update state with calculated values
                    setState(() {
                      _distanceToDestination = distance; // Update distance
                      _estimatedTime = (polylinePoints.length / 100).toStringAsFixed(2) + ' minutes'; // Calculate estimated time
                      
                      // Clear previous polylines and add the new one based on the destination
                      _removePolylines(); // Clear existing polylines

                      // Set Polyline ID based on the destination
                      String polylineId = destination == _currentLocation
                          ? 'route_to_current'
                          : 'route_to_another'; // For San Vicente or Anonas

                      _polylines.add(Polyline(
                        polylineId: PolylineId(polylineId),
                        color: destination == _currentLocation ? Colors.blue : Colors.red, // Different colors for different routes
                        points: polylinePoints,
                        width: 5,
                  ));  });
                   

                    // Update camera to show the route
                    mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(
                        LatLngBounds(
                          southwest: LatLng(
                            math.min(_userLocation!.latitude, destination.latitude),
                            math.min(_userLocation!.longitude, destination.longitude),
                          ),
                          northeast: LatLng(
                            math.max(_userLocation!.latitude, destination.latitude),
                            math.max(_userLocation!.longitude, destination.longitude),
                          ),
                        ),
                        100.0,
                      ),
                    );

                    onGetPressed(); // Continue to "Get Direction" logic
                  },
                  child: const Text('Get Direction', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 40, 59, 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onGetPressed2();
                  },
                  child: const Text('View Details', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}



 void userMarker({
  required String title,
  required String snippet,
  required String imagePath,
  required Function onGetPressed,
  required Function onGetPressed2,
    bool showGotItButton = false, 
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector( 
              onTap: () {
                
 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>CollectionPointsScreen(collectionPoint: '',)), (route) => false);

                print('Image tapped!');
              },
              child: Image.asset(
                imagePath,
                height: 150,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 40, 59, 23), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), 
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                  onPressed: () {
                    Navigator.pop(context); 
                  
                  },
                  child: Text('Okay! Got It',style: TextStyle(color:Colors.white ),),
                  
                ),
                SizedBox(width: 20,),
               
              ],
            ),
          ],
        ),
      );
    },
  );
}




  void _togglePolylinesForCurrentLocation() async {
  
  if (_showAnotherPolylines) {
    _removePolylines();
    _showAnotherPolylines = false; 
  }

  if (_showCurrentPolylines) {
    _removePolylines();
  } else {
    await _addPolylinesToCurrentLocation();
  }
  setState(() {
    _showCurrentPolylines = !_showCurrentPolylines;
  });
}

 void _togglePolylinesForAnotherLocation() async {
  
  if (_showCurrentPolylines) {
    _removePolylines();
    _showCurrentPolylines = false; 
  }

  if (_showAnotherPolylines) {
    _removePolylines();
  } else {
    await _addPolylinesToAnotherLocation();
  }
  setState(() {
    _showAnotherPolylines = !_showAnotherPolylines;
  });
}

  Future<void> _addPolylinesToCurrentLocation() async {
    if (_userLocation != null) {
      try {
        final pointsToCurrent = await _getRoutePolyline(_userLocation!, _currentLocation);
        if (pointsToCurrent.isNotEmpty) {
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route_to_current'),
                points: pointsToCurrent,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        }
      } catch (e) {
        print('Error fetching route: $e');
      }
    }
  }

  Future<void> _addPolylinesToAnotherLocation() async {
    if (_userLocation != null) {
      try {
        final pointsToAnother = await _getRoutePolyline(_userLocation!, _anotherLocation);
        if (pointsToAnother.isNotEmpty) {
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route_to_another'),
                points: pointsToAnother,
                color: Colors.red,
                width: 5,
              ),
            );
          });
        }
      } catch (e) {
        print('Error fetching route: $e');
      }
    }
  }

  void _removePolylines() {
    setState(() {
      _polylines.clear();
    });
  }

  void _updateCamera() {
    if (mapController != null && _userLocation != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          math.min(_userLocation!.latitude, _currentLocation.latitude),
          math.min(_userLocation!.longitude, _currentLocation.longitude),
        ),
        northeast: LatLng(
          math.max(_userLocation!.latitude, _currentLocation.latitude),
          math.max(_userLocation!.longitude, _currentLocation.longitude),
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solid Waste Management Map',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor:Color.fromARGB(255, 47, 61, 2),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: _zoomLevel,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
      ),
      bottomSheet: Container(
  padding: const EdgeInsets.all(16.0),
  color: Colors.white,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Distance: ${_distanceToDestination.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 16)),
      Text('Estimated Time: $_estimatedTime', style: const TextStyle(fontSize: 16)),
    ],
  ),
),

    );
  }
}
