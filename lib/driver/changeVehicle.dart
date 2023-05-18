import 'package:flutter/material.dart';
import 'package:supabase/src/supabase_stream_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import'addVehicle.dart';


class changeVehicle extends StatefulWidget {
  const changeVehicle({Key? key}) : super(key: key);

  @override
  State<changeVehicle> createState() => _changeVehicleState();
}

class _changeVehicleState extends State<changeVehicle> {
  final SupabaseClient _client = Supabase.instance.client;
  //get the data from the database real time

  var currentVehicle;
  bool isSelectionMode = false;
  final int listLength = 30;

  late List<bool> _selected;



  @override
  void initState() {
    super.initState();
    _selected = List<bool>.generate(listLength, (int index) => false);
    currentVehicle = readData();

  }

  @override
  Widget build(BuildContext context) {

    PostgrestResponse newRecord;
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
              stream: Supabase.instance.client
                  .from('trucks')
                  .select()
                  .execute()
                  .asStream(),
              builder: (BuildContext context, AsyncSnapshot<PostgrestResponse> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  final List<dynamic> data = snapshot.data!.data as List<dynamic>;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> vehicle = data[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(vehicle['license_plate'].toString()),
                        subtitle: Text(vehicle['truck_type'].toString()),





                        trailing: test (vehicle,currentVehicle[0]),

                        //delete the vehicle





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
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: const <Widget>[
                                                      Text('Are you sure you want to delete this vehicle?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () async {
                                                      if (vehicle['truck_id'] == currentVehicle[0]['current_vehicle']) {
                                                        final update = await _client.from('drivers').update({'current_vehicle': vehicle[null]}).eq('driver_id', 1);
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

    print(currentVehicle['current_vehicle']);
    print(vehicle['truck_id']);



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
