import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserLocationScreen extends StatefulWidget {
  final int userId;

  UserLocationScreen({required this.userId});

  @override
  _UserLocationScreenState createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Polyline? _polyline;
  Polyline? _routePolyline;
  LatLngBounds? _bounds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Usuario'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          _fetchUserLocations();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 10,
        ),
        markers: _markers,
        polylines: {
          if (_polyline != null) _polyline!,
          if (_routePolyline != null) _routePolyline!,
        },
      ),
    );
  }

  Future<void> _fetchUserLocations() async {
    final response = await http.get(
        Uri.parse('https://hcperuaqp.com/api/locations/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> locations = json.decode(response.body);
      if (locations.isNotEmpty) {
        final List<LatLng> latLngs = locations.map((loc) {
          final latitude = double.tryParse(loc['latitude'].toString()) ?? 0.0;
          final longitude = double.tryParse(loc['longitude'].toString()) ?? 0.0;
          return LatLng(latitude, longitude);
        }).toList();

        setState(() {
          _markers = latLngs.asMap().entries.map((entry) {
            int index = entry.key;
            LatLng latLng = entry.value;
            return Marker(
              markerId: MarkerId('$index'),
              position: latLng,
              infoWindow: InfoWindow(
                title: 'Ubicación $index',
                snippet: 'Lat: ${latLng.latitude}, Lon: ${latLng.longitude}',
              ),
            );
          }).toSet();

          _polyline = Polyline(
            polylineId: PolylineId('user_path'),
            points: latLngs,
            color: Colors.blue,
            width: 5,
          );

          if (latLngs.length > 1) {
            _fetchRoute(latLngs.first, latLngs.last);
          }

          _bounds = _calculateBounds(latLngs);
        });

        if (_bounds != null) {
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(_bounds!, 50),
          );
        }
      }
    } else {
      print('Error al obtener la ubicación del usuario');
    }
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyCNyXwPQWWL2_ZAURCsVuX92VrdjdUmh8Q';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> routes = data['routes'];
      if (routes.isNotEmpty) {
        final polylinePoints = routes[0]['overview_polyline']['points'];
        final decodedPoints = _decodePolyline(polylinePoints);

        setState(() {
          _routePolyline = Polyline(
            polylineId: PolylineId('route'),
            points: decodedPoints,
            color: Colors.red,
            width: 5,
          );
        });
      }
    } else {
      print('Error al obtener la ruta');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return points;
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double south = points[0].latitude;
    double north = points[0].latitude;
    double east = points[0].longitude;
    double west = points[0].longitude;

    for (var point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }
}
