import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';

class activeDriver extends StatefulWidget {
  const activeDriver({Key? key}) : super(key: key);

  @override
  State<activeDriver> createState() => _activeDriverState();
}

class _activeDriverState extends State<activeDriver> {
  bool startDelivery = false;
  final textEditingController = TextEditingController();
  final bool _visible = true;
  late bool _serviceEnabled;
  late String latitude;
  late String longitude;

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

  LatLng? _lastMapPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

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
            onTap: () {},
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
            onTap: () {},
            icon: BitmapDescriptor.defaultMarker);

        _removeMarker(marker, markerId);
      });
    }
  }

  startDel() {
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
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: SizedBox(
                        child: Center(
                          child: Text(
                            'The Merchant Has \n Started The Delivery',
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 20,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Please Confirm the \n Start of Delivery',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
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
                                'START DELIVERY',
                                style: TextStyle(color: Colors.white),
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

  _selectTruck() {
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
                            'Select Truck',
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text(
                                'TRUCK REGISTRATION',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.arrow_drop_down_sharp),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'TRUCK DETAILS',
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blueGrey),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'SELECT TRUCK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blueGrey),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _addTruck();
                              },
                              child: const Text(
                                'ADD NEW TRUCK',
                                style: TextStyle(color: Colors.white),
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

  _addTruck() {
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
                            'Select Truck',
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text(
                                'TRUCK DETAILS',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  suffixIcon: Icon(Icons.arrow_drop_down_sharp),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blueGrey),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'ADD TRUCK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                "Ad Title",
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
                        children: const [
                          Text(
                            'Distance Away',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Job Address',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Job Requirement',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    if (startDelivery == false)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                              ),
                              onPressed: () {
                                setState(() {
                                  startDelivery = true;
                                });
                                _selectTruck();
                              },
                              child: const Text(
                                'CONFIRM DELIVERY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    if (startDelivery == true)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                              ),
                              onPressed: () {
                                setState(() {
                                  startDelivery = false;
                                });
                                startDel();
                              },
                              child: const Text(
                                'START DELIVERY',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
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
