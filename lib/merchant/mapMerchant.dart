/*import 'package:flutter/material.dart';
class mapMerchant extends StatefulWidget {
  const mapMerchant({Key? key}) : super(key: key);

  @override
  State<mapMerchant> createState() => _mapMerchantState();
}

class _mapMerchantState extends State<mapMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Merchant Map Screen'),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
//location
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:geocoding_platform_interface/src/models/location.dart' as geo;

import '../constants.dart';

class mapMerchant extends StatefulWidget {


  const mapMerchant({Key? key}) : super(key: key);

  @override
  State<mapMerchant> createState() => _mapMerchantState();
}

class _mapMerchantState extends State<mapMerchant> {
  //final latlng = LatLng(latitude, longitude)
  final User? user = supabase.auth.currentUser;
  List<LatLng> _addresses = [];
  LatLng _myLocation = LatLng(0, 0);
  bool isLoading = false;
  @override
  void initState() {
    isLoading = true;
    super.initState();
    loadInitialData();

  }

  OverlayEntry? overlay;

  void loadingOverlay(){
    const String iconPath = 'assets/truck.svg';
    overlay = OverlayEntry(
        builder: (BuildContext context){
          return Scaffold(
              backgroundColor: Colors.white.withOpacity(0.7),
              body: Padding(
                padding: const EdgeInsets.all(0),

                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          iconPath,
                          colorFilter:
                          ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
                          semanticsLabel: 'Truck Icon',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Urban Logistics',
                          style: TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 20),
                        CircularProgressIndicator()
                      ],
                    )),
              ));
        });
    Overlay.of(context, debugRequiredFor: widget).insert(overlay!);
  }

  void removeLoadingOverlay() {
    overlay?.remove();
    overlay = null;
  }
  void loadInitialData() async {
    _addresses = await getAddresses();
    //final LocationData value = testAddresses() as LocationData;
    final latlng = await testAddresses();
    _myLocation = LatLng(latlng.latitude, latlng.longitude);
    setState(() {});
  }
  final mapController = MapController();
  @override
  Widget build(BuildContext context)  {
    if (_addresses.isEmpty){
      if (isLoading) {
        const String iconPath = 'assets/truck.svg';
        return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                //color: Colors.green.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        colorFilter:
                        ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
                        semanticsLabel: 'Truck Icon',
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Urban Logistics',
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 20),
                      CircularProgressIndicator()
                    ],
                  )),
            ));
      }
    }
    else{
      removeLoadingOverlay();
    }
    //set the map to GPS location
    final LatLng myLocation = LatLng(0, 0);

    ////update the user's location before building the map
   // updateLocation();
    //get the list of addresses from acceepted jobs and display them on the map
    //temp static list of addresses
    /*String address = "1 Main Street, Hobart, Tasmania, Australia";
    Future<List<geo.Location>> test = geo.GeocodingPlatform.instance.locationFromAddress(address);
    //when the list of addresses is returned, print them to the console
    //test first latlng
    final List<LatLng> addresses;
    addresses = [(LatLng(-41.199775,146.816293)), (LatLng(-41.206620,146.823149))];
    //add test to addresses
    //addresses.add(test.latitude, test.longitude);
    test.then((value) => addresses.add(LatLng(value.first.latitude , value.first.longitude)));
    test.then((value) =>print(addresses));*/

    return Scaffold(
      //center the map on the user's location button
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
        onPressed: () async {

          mapController.move(_myLocation, 13);
        },
        child: const Icon(Icons.location_on),
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              minZoom: 5,
              maxZoom: 18,
              zoom: 13,
              center: _myLocation,
            ),
            nonRotatedChildren: [
              TileLayer(

                urlTemplate: 'https://api.mapbox.com/styles/v1/leigh3211/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
                additionalOptions: const {
                  //from ../constants.dart
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },

              ),
              MarkerLayer(

                markers: [
                  //display the user's location on the map
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _myLocation,
                    builder: (ctx) => const Icon(
                      Icons.store_rounded,
                      color: Colors.pinkAccent,
                      size: 30,
                    ),
                  ),
                  //display the addresses on the map
                  for (var i = 0; i < _addresses.length; i++)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _addresses[i],
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),

             //CurrentLocationLayer(),
            ],
          ),
        ],
      ),
    );
  }
  Future<LatLng> testAddresses() async {
    //final String address = "1 Main Street, Hobart, Tasmania, Australia";
    //get the address from the database
    final response = await supabase.from('suppliers').select().eq('supplier_id', user!.id).execute();
    final address = response.data![0]['business_address'].toString();
    //get the latlng from the address
    final latlng = await geo.locationFromAddress(address);
    //test first latlng

    print(latlng);
    return LatLng(latlng[0].latitude, latlng[0].longitude);
  }

  //get list of addresses from acceepted jobs and display them on the map
  Future<List<LatLng>> getAddresses() async {
    //get the list of accepted jobs from the database

    final response = await supabase.from('advertisments').select().eq('driver_id', user!.id) .neq ('job_status', 'COMPLETE')
        .neq ('job_status', 'CANCELLED').execute();
    //list if latlngs corresponding to the addresses
    List<LatLng> addresses = [];
    if (response.data == null) {
      //handle no data
      return addresses;
    }
    //dynamic to int
    final num length = response.data.length as num;

    //get the list of addresses from the accepted jobs
    for (var i = 0; i < length; i++) {
      //get the address from the database
      final address = response.data![i]['pickup_address'].toString();
      print(address);
      //get the latlng from the address
      final latlng = await geo.locationFromAddress(address);
      //add the latlng to the list
      if (latlng.isNotEmpty){
        addresses.add(LatLng(latlng[0].latitude, latlng[0].longitude));

      }
      else {
        print("no latlng");
        addresses.add(LatLng(0,0));

      }

      //addresses.add(LatLng(latlng[0].latitude, latlng[0].longitude));
    }
    if (addresses.isEmpty){
      print("no latlng");
      addresses.add(LatLng(0,0));
    }
    //display the addresses on the map
    return addresses;
  }

  //update the user's location on the map`
  void updateLocation(LatLng latlng) {
    setState(() {
      //get the user's location using the location package
        mapController.move(latlng, 13);
        //AppConstants.myLocation = LatLng(value.latitude!, value.longitude!);
        //update the user's location in the database driver table latitide and longitude
        //if driver i active

    });
  }
}
