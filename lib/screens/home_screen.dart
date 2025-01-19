import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/calendar_widget.dart';
import 'event_form_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  Location _location = Location();
  LatLng _currentLocation = LatLng(41.9981, 21.4254); // Default: Скопје

  List<Marker> _markers = [];
  List<String> _distances = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await _location.getLocation();
    setState(() {
      _currentLocation = LatLng(
        _locationData.latitude!,
        _locationData.longitude!,
      );
      _addMarker(_currentLocation, "My Location");
    });
  }

  void _addMarker(LatLng location, String title) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: InfoWindow(title: title),
      ));
    });
    _calculateDistances();
  }

  Future<void> _calculateDistances() async {
    List<String> distances = [];
    for (var marker in _markers) {

      if (marker.infoWindow.title == "My Location") {
        continue;
      }

      final distance = await Geolocator.distanceBetween(
        _currentLocation.latitude,
        _currentLocation.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );
      String eventTitle = marker.infoWindow.title ?? "Event";
      distances.add('"$eventTitle" - ${(distance / 1000).toStringAsFixed(2)} km away from your current location!');
    }
    setState(() {
      _distances = distances;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exam scheduler'),
            Text(
              'Add an event by clicking on a date in the calendar!',
              style: TextStyle(fontSize: 14, color: Colors.red[200]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          CalendarWidget(
            onDateSelected: (date) {
              _showEventForm(context, date);
            },
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          if (_distances.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _distances
                    .map((distance) => Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      distance,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showEventForm(BuildContext context, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      builder: (_) => EventFormScreen(
        selectedDate: selectedDate,
        onEventAdded: (LatLng location, String title, TimeOfDay time) {
          _addMarker(location, '$title at ${time.format(context)}');
        },
      ),
    );
  }
}


