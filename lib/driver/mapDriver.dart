import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart' as loc;
import 'package:location/location.dart';

class mapDriver extends StatefulWidget {
  const mapDriver({Key? key}) : super(key: key);

  @override
  State<mapDriver> createState() => _mapDriverState();
}

class _mapDriverState extends State<mapDriver> {
  late bool _serviceEnabled;
  final bool _visible = true;
  late String latitude;
  late String longitude;
  LatLng? _lastMapPosition;
  LatLng? _destination;

  @override
  void initState() {
    _checkGps();
    super.initState();
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late LatLng currentLocation;
  late LatLng destinationLocation;

  MapType _currentMapType = MapType.normal;

  Future<void> _checkGps() async {
    loc.Location location = loc.Location();

    var _permissionGranted = await location.hasPermission();
    _serviceEnabled = await location.serviceEnabled();

    if (_permissionGranted != PermissionStatus.granted || !_serviceEnabled) {
      _permissionGranted = await location.requestPermission();

      _serviceEnabled = await location.requestService();

      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      setState(() {
        _lastMapPosition = LatLng(position.latitude, position.longitude);
      });

      latitude = '${position.latitude}';
      longitude = '${position.longitude}';

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      location.onLocationChanged.listen((event) {
        _lastMapPosition = LatLng(event.latitude!, event.longitude!);

        const MarkerId markerId = MarkerId("currentP");

        final Marker marker = Marker(
            markerId: markerId,
            position: _lastMapPosition!,
            infoWindow:
                InfoWindow(title: "You are here, $address", onTap: () {}),
            onTap: () {
              _locationInfo();
            },
            icon: BitmapDescriptor.defaultMarker);

        _removeMarker(marker, markerId);
      });
    } else {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);

      _lastMapPosition = LatLng(position.latitude, position.longitude);
      latitude = '${position.latitude}';
      longitude = '${position.longitude}';

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

      location.onLocationChanged.listen((event) {
        _lastMapPosition = LatLng(event.latitude!, event.longitude!);

        const MarkerId markerId = MarkerId("currentP");

        final Marker marker = Marker(
            markerId: markerId,
            position: _lastMapPosition!,
            infoWindow:
                InfoWindow(title: "You are here, $address", onTap: () {}),
            onTap: () {
              _locationInfo();
            },
            icon: BitmapDescriptor.defaultMarker);

        _removeMarker(marker, markerId);
      });
    }
  }

  final Completer<GoogleMapController> _controller = Completer();

  _onMapCreated(GoogleMapController controllers) {
    setState(() {
      _controller.complete(controllers);
    });
  }

  _onCameraMove(CameraPosition position) {
    setState(() {
      _lastMapPosition = position.target;
    });
  }

  _removeMarker(Marker marker, MarkerId markerId) {
    setState(() {
      markers.remove(markerId);
      markers[markerId] = marker;
    });
  }

  _locationInfo() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //
            // this right here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // setState(() {
                          //   _isSearchVisible = true;
                          // });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: SizedBox(
                        width: 200.0,
                        child: Center(
                          child: Text(
                            'Ad Title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Distance Away',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Pickup Address',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Distance From Pickup',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Location',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Job Requirement',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Accept',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> showMarker() async {
    markers.clear();

    setState(() {
      final MarkerId markerDestId = MarkerId(_destination.toString());
      final Marker markerDest = Marker(
          markerId: markerDestId,
          position: _destination!,
          infoWindow: const InfoWindow(title: "Destination"),
          icon: BitmapDescriptor.defaultMarker);
      markers[markerDestId] = markerDest;
    });
  }

  Widget NoLoader() {
    return SizedBox(
      height: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _lastMapPosition == null
                  ? Center(
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Please wait loading map...',
                                style: TextStyle(
                                    fontFamily: 'Avenir-Medium',
                                    color: Colors.blue,
                                    fontSize: 16.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        color: Colors.grey[200],
                        child: Stack(children: <Widget>[
                          GoogleMap(
                            markers: Set<Marker>.of(markers.values),
                            mapType: _currentMapType,
                            initialCameraPosition: CameraPosition(
                              target: _lastMapPosition!,
                              zoom: 14.4746,
                            ),
                            onMapCreated: _onMapCreated,
                            zoomGesturesEnabled: true,
                            onCameraMove: _onCameraMove,
                            myLocationEnabled: true,
                            compassEnabled: true,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: true,
                          ),
                        ]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Beacon {
  String address;
  String locationName;
  String latitude;
  String Longitud;
  String status;
  String shopNumber;
  String description;

  Beacon(
      {required this.address,
      required this.latitude,
      required this.Longitud,
      required this.locationName,
      required this.status,
      required this.shopNumber,
      required this.description});
}

class LocationAddress {
  String address;
  String location;
  String latitude;
  String Longitude;

  LocationAddress(
      {required this.address,
      required this.location,
      required this.latitude,
      required this.Longitude});
}
