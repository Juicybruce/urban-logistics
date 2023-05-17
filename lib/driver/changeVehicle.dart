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

  //update the list when there is a change in the database

  bool isSelectionMode = false;
  final int listLength = 30;
  late List<bool> _selected;


  @override
  void initState() {
    super.initState();
    _selected = List<bool>.generate(listLength, (int index) => false);
  }

  @override
  Widget build(BuildContext context) {
    PostgrestResponse newRecord;
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Vehicle'),
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
                        //button to make set the drivers active vehicle to the selected vehicle
                          trailing: ElevatedButton(
                          onPressed: () async {
                            //update the driver's active vehicle
                            newRecord = await _client.from('drivers').update({'current_vehicle': vehicle['truck_id']}).eq('driver_id', 1).execute();
                            //update the
                            setState(() {});
                          },
                          child: Text('Select'),
                        ),



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
}
