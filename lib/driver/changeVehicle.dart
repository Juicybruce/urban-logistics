import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import'addVehicle.dart';

class changeVehicle extends StatefulWidget {
  const changeVehicle({Key? key}) : super(key: key);

  @override
  State<changeVehicle> createState() => _changeVehicleState();
}

class _changeVehicleState extends State<changeVehicle> {
  //supabase client
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  var _licensePlateController = TextEditingController();
  var _truckTypeController = TextEditingController();
  var _truckCapacityController = TextEditingController();
  var _truckWeightController = TextEditingController();
  bool _isCooling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Change Vehicle"),
        centerTitle: true,),
      //a button to show a dialogue box to add a truck
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return addVehicle();
                });
          },
          child: const Text('Add Truck'),
        ),
      ),
    );
  }
}
