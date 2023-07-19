import 'package:flutter/material.dart';
import 'package:supabase/src/supabase_stream_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import'addVehicle.dart';


class changeVehicle extends StatefulWidget {
  const changeVehicle({Key? key}) : super(key: key);

  @override
  State<changeVehicle> createState() => _changeVehicleState();
}

class _changeVehicleState extends State<changeVehicle> {
  //get current user's vehicle
  final User? user = supabase.auth.currentUser;
  //final String? uid = supabase.auth.currentUser!.id;
  final String? uEmail = supabase.auth.currentUser!.email;
  final SupabaseClient _client = Supabase.instance.client;

  final _future = Supabase.instance.client
      .from('trucks')
  //select the data from the database
      .select()
    .asStream();
  //get the data from the database real time
//print uid to check if it is correct

  var currentVehicle;
  bool isSelectionMode = false;
  final int listLength = 30;
  int? uid;

// Get the user id from the database
  Future<void> getDriverId() async {
    final response = await _client
        .from('drivers')
        .select('driver_id')
        .eq('email', uEmail)
        .execute();
    final driverId = response.data[0]['driver_id'];
    setState(() {
      uid = int.tryParse(driverId.toString());
    });
  }
  @override
  void initState() {
    super.initState();
    //_selected = List<bool>.generate(listLength, (int index) => false);
    currentVehicle = readData();
    //print(uid);
    print(currentVehicle);
    print(uEmail);
    getDriverId();



  }

  @override
  Widget build(BuildContext context) {
    //retrieve driver id from the driver table using user's email
    //final uid = _client.from('drivers').select('id').eq('email',uEmail);

    //final uid =  getDriverId();
    //print(uid);
    //filter the truck table using the driver id
    //PostgrestResponse newRecord;
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Vehicle'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {showDialog(
                context: context,
                builder: (BuildContext context) {
                  return addVehicle();
                  //after adding a vehicle, refresh the truck list
                }).then((value) => setState(() {}));



            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              //use future builder to get the data from the database
              stream: _future,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  final List<dynamic> data = snapshot.data as List<dynamic>;
                  //filter the data using the driver id
                  final List<dynamic> filteredData = data.where((element) => element['driver_id'] == uid).toList();
                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> vehicle = filteredData[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(vehicle['license_plate'].toString()),
                        subtitle: Text(vehicle['truck_type'].toString()),

                        trailing: test (vehicle,currentVehicle[0]),

                        //show details on onTap
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(vehicle['license_plate'].toString()),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      Text('Truck Type: ' + vehicle['truck_type'].toString()),
                                      Text('Truck Capacity: ' + vehicle['space_capacity'].toString()),
                                      Text('Truck Weight Capacity: ' + vehicle['weight_capacity'].toString()),
                                      Text('Cooling: ' + vehicle['cooling_capacity'].toString()),
                                      Text('Insurance Number: ' + vehicle['Insurance_number'].toString()),
                                      //delete the vehicle
                                      ElevatedButton(
                                        onPressed: () {
                                          //if the vehicle is the driver's active vehicle show a warning
                                          //else delete the vehicle
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Delete Vehicle'),
                                                content: const SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text('Are you sure you want to delete this vehicle?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () async {
                                                      if (vehicle['truck_id'] == currentVehicle[0]['current_vehicle']) {
                                                        final update = await _client.from('drivers').update({'current_vehicle': vehicle[null]}).eq('driver_id', uid);
                                                        if (update == null) {
                                                          print('Driver active vehicle set to null');
                                                        } else {
                                                          print('Could not set driver active vehicle to null');
                                                          print(update.message);
                                                        }
                                                        final response = await _client.from('trucks').delete().match({'truck_id': vehicle['truck_id']});
                                                        if (response == null) {
                                                          print('Vehicle deleted successfully');
                                                        } else {
                                                          print('Could not delete vehicle');
                                                          print(response.error!.message);
                                                        }

                                                      } else {
                                                        print('Driver active vehicle not set to null');
                                                        final response = await _client.from('trucks').delete().match({'truck_id': vehicle['truck_id']});
                                                        if (response == null) {
                                                          print('Vehicle deleted successfully');
                                                        } else {
                                                          print('Could not delete vehicle');
                                                          print(response.error!.message);
                                                        }
                                                      }
                                                      //if the vehicle is the driver's active vehicle set the driver's active vehicle to null



                                                      Navigator.of(context).pop();
                                                      //close the dialog
                                                      Navigator.of(context).pop();
                                                      //refresh the list
                                                      setState(() {});
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('No'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          setState(() {});
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget test(Map<String, dynamic> vehicle, currentVehicle) {

    //get the driver's active vehicle from

    // print(currentVehicle['current_vehicle']);
    // print(vehicle['truck_id']);



    //if the vehicle is the driver's active vehicle from database
    //print the vehicle id from database


    if (currentVehicle['current_vehicle'] == vehicle['truck_id']) {
      // show a active vehicle icon
      return Icon(Icons.check);
    }
    else {
      return ElevatedButton(
        onPressed: () async {
          //update the driver's active vehicle
          //     newRecord = await _client.from('drivers').update({'current_vehicle': vehicle['truck_id']}).eq('driver_id', 1).execute();

          final newRecord = await _client.from('drivers').update({'current_vehicle': vehicle['truck_id']}).eq('driver_id', 1).execute();
          //update the
          setState(() {});
          //update currentVehicle variable
          currentVehicle = readData();

        },
        child: Text('Select'),
      );
    }
  }
  Future<void> readData() async {
    var response = await _client
        .from('drivers')
        .select('current_vehicle')
        .eq('driver_id', 1)
        .execute();
    setState(() {
      currentVehicle = response.data.toList();
    });
  }

}

//get the driver's active vehicle from database
