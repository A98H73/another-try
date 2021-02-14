import 'dart:collection';
import 'package:flutter_app/authentication_service.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:math' show cos, sqrt, asin;

class Testing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Presenting Google map ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoMap(),
    );
  }
}

class DemoMap extends StatefulWidget {
  @override
  _ShowMapState createState() => _ShowMapState();
}

class _ShowMapState extends State<DemoMap> {
  // Initial location of the Map view
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

  double width = 2;
// For controlling the view of the Map
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  Position _currentPosition, _destinationPosition;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  PolylinePoints polylinePoints = PolylinePoints();

  Set<Marker> markers = {};

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting
// two points
  Map<PolylineId, Polyline> polylines = {};

  String _placeDistance;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _currentAddress;
  String _destinationAddress;

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
      });

      List<Placemark> pf = await _geolocator.placemarkFromCoordinates(
          _destinationPosition.latitude, _destinationPosition.longitude);

      Placemark placer = pf[0];

      setState(() {
        _destinationAddress =
            "${placer.name}, ${placer.locality}, ${placer.postalCode}, ${placer.country}";
        destinationAddressController.text = _destinationAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _destinationPosition =
        Position(latitude: 37.414210, longitude: -122.093150);
    _getCurrentLocation();
  }

  Future<bool> _calculateDistance() async {
    try {
      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId('$_currentPosition'),
        position: LatLng(
          _currentPosition.latitude,
          _currentPosition.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Start',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId('$_destinationPosition'),
        position: LatLng(
          _destinationPosition.latitude,
          _destinationPosition.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Destination',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers.add(startMarker);
      markers.add(destinationMarker);

      print('START COORDINATES: $_currentPosition');
      print('DESTINATION COORDINATES: $_destinationPosition');

      Position _northeastCoordinates;
      Position _southwestCoordinates;

      // Calculating to check that
      // southwest coordinate <= northeast coordinate
      if (_currentPosition.latitude <= _destinationPosition.latitude) {
        _southwestCoordinates = _currentPosition;
        _northeastCoordinates = _destinationPosition;
      } else {
        _southwestCoordinates = _destinationPosition;
        _northeastCoordinates = _currentPosition;
      }

      // Accomodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(
              _northeastCoordinates.latitude,
              _northeastCoordinates.longitude,
            ),
            southwest: LatLng(
              _southwestCoordinates.latitude,
              _southwestCoordinates.longitude,
            ),
          ),
          100.0,
        ),
      );

      await _createPolylines(_currentPosition, _destinationPosition);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _createPolylines(Position start, Position destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyA09FqkJmh_zozrwTYYykeyVDOYGPYhM2A", // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      visible: true,
      color: Colors.red,
      points: polylineCoordinates,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.buttCap,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
    //_polylines.add(polyline);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(true);
      },
      // child: WillPopScope(
      //   onWillPop: () {},
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "My Map",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black45,
          ),
          body: Stack(
            children: <Widget>[
              // Replace the "TODO" with this widget
              GoogleMap(
                markers: markers != null ? Set<Marker>.from(markers) : null,
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                polylines: Set<Polyline>.of(polylines.values),
                // polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),

              SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.amber[100], // button color
                        child: InkWell(
                          splashColor: Colors.amber, // inkwell color
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.zoom_in),
                          ),
                          onTap: () {
                            // Zoom In action
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.amber[100], // button color
                        child: InkWell(
                          splashColor: Colors.amber, // inkwell color
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.zoom_out),
                          ),
                          onTap: () {
                            // Zoom Out action
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )),

              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height / 8,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  "SOURCE: " + _currentAddress.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Raleway',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "DESTINATION: " +
                                      _destinationAddress.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Raleway',
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Visibility(
                                visible: _placeDistance == null ? false : true,
                                child: Text(
                                  'DISTANCE: $_placeDistance km',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  RaisedButton(
                                    onPressed: (_currentPosition != null &&
                                            _destinationPosition != null)
                                        ? () async {
                                            setState(() {
                                              if (markers.isNotEmpty)
                                                markers.clear();
                                              if (polylines.isNotEmpty)
                                                polylines.clear();
                                              if (polylineCoordinates
                                                  .isNotEmpty)
                                                polylineCoordinates.clear();
                                              _placeDistance = null;
                                            });
                                            print(
                                                "working...........................");
                                            _calculateDistance()
                                                .then((isCalculated) {
                                              if (isCalculated) {
                                                _scaffoldKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Distance Calculated Sucessfully'),
                                                  ),
                                                );
                                              } else {
                                                _scaffoldKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Error Calculating Distance'),
                                                  ),
                                                );
                                              }
                                            });
                                          }
                                        : null,
                                    color: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Show Route'.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  RaisedButton(
                                    child: Text("Sign Out"),
                                    onPressed: () => context
                                        .read<AuthenticationService>()
                                        .signOut(),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              ClipOval(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Material(
                    color: Colors.orange[100], // button color
                    child: InkWell(
                      splashColor: Colors.orange, // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location),
                      ),
                      onTap: () {
                        // Move camera to the specified latitude & longitude
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                // Will be fetching in the next step
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                              ),
                              zoom: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //),
    );
  }
}
