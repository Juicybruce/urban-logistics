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
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
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
  List<dynamic> _truckLocations2 = [];

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
    //_truckLocations = await getTruckLocations();
    _truckLocations2 = await getTruckLocations2();
    //final LocationData value = testAddresses() as LocationData;
    final latlng = await GetBisAddress();
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


    return Scaffold(
      //center the map on the user's location button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          heroTag: "btn1",
          onPressed: () async {

            mapController.move(_myLocation, 13);
          },
          child: const Icon(Icons.location_on),
        ),
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              //no zooming
              minZoom: 13,
              maxZoom: 20,
              zoom: 13,
              center: _myLocation,

              interactiveFlags:  ~InteractiveFlag.rotate,
              //close popup when the map is moved

              //onTap: (_, __) => PopupController().hideAllPopups()
            ),
            //close popup when the map is moved
            nonRotatedChildren: [
              TileLayer(

                urlTemplate: 'https://api.mapbox.com/styles/v1/leigh3211/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
                additionalOptions: const {
                  //from ../constants.dart
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },

              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions (
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
                        //no rotation
                        rotate: false,
                      ),
                      //display the addresses on the map
                      for (var i = 0; i < _truckLocations2.length; i++)
                      //get latlng from the driver object
                        DriverMarker(
                          _truckLocations2[i],
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(_truckLocations2[i]['latitude'] as double, _truckLocations2[i]['longitude']as double),
                          builder: (ctx) => const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.purple,
                            size: 25,

                            //on tap display the truck's detail
                          ),
                        ),

                    ],

                    popupController: PopupController(),
                    popupDisplayOptions: PopupDisplayOptions (



                        builder: (_, Marker marker){
                          if (marker is DriverMarker){
                            return DriverMarkerPopup(driver: marker.driver);
                          }
                          return const Card(child: Text('Not a A truck Marker'));
                        }
                    )
                ),
              ),
              //CurrentLocationLayer(),
            ],
          ),
        ],
      ),
    );

  }


  Future<LatLng> GetBisAddress() async {
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

  //get trucks location from database
  Future <List<dynamic>> getTruckLocations2() async {
    //get list of trucks latitudes and longitudes from database
    final response = await supabase.from('drivers').select().eq('available', 'TRUE').execute();
    //list if latlngs
    List<LatLng> truckLocations = [];
    //list if driver objects
    List<dynamic> drivers = [];
    if (response.data == null) {
      //handle no data
      return drivers;
    }
    //dynamic to int
    final num length = response.data.length as num;
    //filter out trucks that are not active
    for (var i = 0; i < length; i++) {
      //get the address from the database
      //if the truck has a location in latitide and longitude
      if (response.data![i]['latitude'] != null && response.data![i]['longitude'] != null){

        //get the latlng from the address
        //add the whole driver object to the list
        drivers.add(response.data![i]);



      }
    }
    //print(drivers);
    return drivers;
  }
//update the user's location on the map`
}
class DriverMarker extends Marker {
  DriverMarker(this.driver, {
    required double width, required double height, required LatLng point, required Icon Function(dynamic ctx) builder,
  }) : super(
    width: width,
    height: height,
    point: point,
    builder: builder,
    //stop from rotating
    //rotateAlignment: AnchorAlign.top.rotationAlignment,
    anchorPos: AnchorPos.align(AnchorAlign.top),

  );
  final dynamic driver;


}
class DriverMarkerPopup extends StatelessWidget {
  const DriverMarkerPopup({Key? key, required this.driver}) : super(key: key);
  final dynamic driver;

  @override
  Widget build(BuildContext context) {
//get the truck's id
    final String truckId = driver['current_vehicle'].toString();
    //get the truck's details from the database
    final response = supabase.from('trucks').select()
        .eq('truck_id', truckId)
        .execute();
    //display the truck's details
    return Container(
        width: 250,
        height: 150,
        child: Card(
          //transparent background
          color: Colors.white.withOpacity(0.7),
          child:
          Column(
            children: [
              Text(
                '${driver['first_name']} ${driver['last_name']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                //company name
                '${driver['company_name']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500
                ),
              ),
//divider
              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              //truck details

              FutureBuilder(
                future: response,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: Column(
                        children: [
                          //Text("licenseplate:${snapshot.data.data![0]['license_plate']}\n capacity:${snapshot.data.data![0]['capacity']}\n type:${snapshot.data.data![0]['truck_type']}");\
                          Text('truck details',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500
                            ),
                          ),
                          Text("licenseplate: ${snapshot.data.data![0]['license_plate']}",
                          ),
                          Text("vehicle type: ${snapshot.data
                              .data![0]['truck_type']}"),
                          Text("capacity: ${snapshot.data.data![0]['space_capacity']}m³"),

                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        )
    );
  }
}