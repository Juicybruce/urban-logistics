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

class mapDriver extends StatefulWidget {

  const mapDriver({Key? key}) : super(key: key);

  @override
  State<mapDriver> createState() => _mapDriverState();
}

class _mapDriverState extends State<mapDriver> {
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
    final LocationData value = await Location().getLocation();
    _myLocation = LatLng(value.latitude!, value.longitude!);
    isLoading = false;
    setState(() {});
  }
  final mapController = MapController();
  @override
 Widget build(BuildContext context)  {
    //if (_addresses.isEmpty){
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
    else{
      removeLoadingOverlay();
    }
    //set the map to GPS location
    final LatLng myLocation = LatLng(0, 0);

    ////update the user's location before building the map
    updateLocation();
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
          final LocationData value = await Location().getLocation();
          mapController.move(LatLng(value.latitude!, value.longitude!), 13);
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
              center: myLocation,
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

              CurrentLocationLayer(),
            ],
          ),
        ],
      ),
    );
  }
  Future<List<LatLng>> testAddresses() async {
    final String address = "1 Main Street, Hobart, Tasmania, Australia";
    Future<List<geo.Location>> test = geo.GeocodingPlatform.instance.locationFromAddress(address);
    //when the list of addresses is returned, print them to the console
    //test first latlng
    final List<LatLng> addresses;
    addresses = [(LatLng(-41.199775,146.816293)), (LatLng(-41.206620,146.823149))];
    //add test to addresses
    //addresses.add(test.latitude, test.longitude);
    test.then((value) => addresses.add(LatLng(value.first.latitude , value.first.longitude)));
    test.then((value) =>print(addresses));
    print(addresses);
    return addresses;
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


      final latlng = await geo.locationFromAddress(address) //as List<geo.Location>;
          .catchError((dynamic e) async {
            //set the latlng to 0,0 if the address is not found Location({required double latitude, required double longitude, required DateTime timestamp})
            return [geo.Location(latitude: 0, longitude: 0, timestamp: DateTime.now())];


        print(e);
      });


      //add the latlng to the list
      if (latlng.isNotEmpty){
        addresses.add(LatLng(latlng[0].latitude, latlng[0].longitude));

      }
      else {
        print("no latlng");
        //addresses.add(LatLng(latlng[0].latitude, latlng[0].longitude));

      }
      //addresses.add(LatLng(latlng[0].latitude, latlng[0].longitude));
    }
    //display the addresses on the map
    return addresses;
    }

  //update the user's location on the map`
  void updateLocation() {
    setState(() {
      //get the user's location using the location package
      Location().getLocation().then((LocationData value) {
        mapController.move(LatLng(value.latitude!, value.longitude!), 13);
        //AppConstants.myLocation = LatLng(value.latitude!, value.longitude!);
        //update the user's location in the database driver table latitide and longitude
        //if driver i active
        supabase.from('drivers').update({'latitude': value.latitude, 'longitude': value.longitude}).eq('driver_id', user!.id).execute();

        });
    });
  }
}
