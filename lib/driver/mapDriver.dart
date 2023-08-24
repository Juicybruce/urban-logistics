import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// //location
// import 'package:location/location.dart';

import '../constants.dart';

class mapDriver extends StatefulWidget {
  const mapDriver({Key? key}) : super(key: key);

  @override
  State<mapDriver> createState() => _mapDriverState();
}

class _mapDriverState extends State<mapDriver> {
  @override
  void initState() {
    super.initState();
  }

  final mapController = MapController();
  @override
  Widget build(BuildContext context) {
    //set the map to GPS location
    // LatLng myLocation = LatLng(0, 0);

    ////update the user's location before building the map
    updateLocation();

    return Scaffold(
      //center the map on the user's location button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // final LocationData value = await Location().getLocation();
          // mapController.move(LatLng(value.latitude!, value.longitude!), 13);
        },
        child: const Icon(Icons.location_on),
      ),

      body: Stack(
        children: [
          // FlutterMap(
          //   mapController: mapController,
          //   options: MapOptions(
          //     minZoom: 5,
          //     maxZoom: 18,
          //     zoom: 13,
          //     center: myLocation,

          //   ),
          //   nonRotatedChildren: [
          //     TileLayer(

          //         urlTemplate: 'https://api.mapbox.com/styles/v1/leigh3211/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
          //         additionalOptions: const {
          //           //from ../constants.dart
          //           'mapStyleId': AppConstants.mapBoxStyleId,
          //           'accessToken': AppConstants.mapBoxAccessToken,
          //         },
          //       ),
          //   ],

          // ),
        ],
      ),
    );
  }

  //update the user's location on the map`
  void updateLocation() {
    setState(() {
      //get the user's location using the location package
      // Location().getLocation().then((LocationData value) {
      //   mapController.move(LatLng(value.latitude!, value.longitude!), 13);
      //   //AppConstants.myLocation = LatLng(value.latitude!, value.longitude!);
      // });
    });
  }
}
