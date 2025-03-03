import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLocation;
  LatLng? _destination;
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _errorMessage;
  List<LatLng> _routePoints = [];
  double? _distanceKm;
  double? _timeCar, _timeBike, _timeBus;
  TextEditingController _destinationController = TextEditingController();
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = "Location permission denied.";
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error retrieving location: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _getCoordinatesFromPlace(String placeName) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _destination = LatLng(
                double.parse(data[0]['lat']), double.parse(data[0]['lon']));
          });
          _getRoute();
        } else {
          setState(() {
            _errorMessage = "Place not found.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to fetch location.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching location: $e";
      });
    }
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null || _destination == null) {
      setState(() {
        _errorMessage = "Current location or destination is missing.";
      });
      return;
    }

    final url =
        "https://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=geojson";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];
          final double distanceMeters = data['routes'][0]['distance'];

          setState(() {
            _routePoints =
                coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
            _distanceKm = distanceMeters / 1000;
            _timeCar = _distanceKm! / 60 * 60;
            _timeBike = _distanceKm! / 25 * 60;
            _timeBus = _distanceKm! / 40 * 60;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = "No route found.";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to fetch route data.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching route: $e";
      });
    }
  }

  void _startNavigation() {
    if (_routePoints.isEmpty || _isNavigating) return;

    setState(() {
      _isNavigating = true;
      _currentStep = 0;
    });

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentStep < _routePoints.length - 1) {
        setState(() {
          _currentLocation = _routePoints[_currentStep];
          _currentStep++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isNavigating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navigation Map")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: "Enter Destination (Place Name)",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  _getCoordinatesFromPlace(value).then((_) {
                    setState(() {
                      _isLoading = false;
                    });
                  });
                }
              },
            ),
          ),
          if (_distanceKm != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        "Distance: ${_distanceKm!.toStringAsFixed(2)} km",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text("Estimated Time:"),
                      Text("🚗 Car: ${_timeCar!.toStringAsFixed(1)} mins"),
                      Text("🏍️ Bike: ${_timeBike!.toStringAsFixed(1)} mins"),
                      Text("🚌 Bus: ${_timeBus!.toStringAsFixed(1)} mins"),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red)))
                    : FlutterMap(
                        options: MapOptions(
  initialCenter: _currentLocation ?? LatLng(0, 0), // ✅ Correct
  initialZoom: 13.0,
),

                        children: [
                          TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // ✅ Fixed warning
                          ),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  color: Colors.blue,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (_currentLocation != null)
                                Marker(
                                  point: _currentLocation!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.my_location,
                                      color: Colors.blue, size: 40),
                                ),
                              if (_destination != null)
                                Marker(
                                  point: _destination!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_pin,
                                      color: Colors.red, size: 40),
                                ),
                            ],
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
