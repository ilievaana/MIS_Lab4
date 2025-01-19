import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final List<Marker> markers;
  final LatLng currentLocation;

  MapWidget({required this.markers, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: currentLocation, zoom: 15),
      markers: Set.from(markers),
    );
  }
}
