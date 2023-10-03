import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';


class addVehicle extends StatefulWidget {

  const addVehicle({super.key});

  @override
  State<addVehicle> createState() => _addVehicleState();
}

class _addVehicleState extends State<addVehicle> {
  //supabase client
  final SupabaseClient _client = Supabase.instance.client;
  final String? uEmail = supabase.auth.currentUser!.email;
  final _formKey = GlobalKey<FormState>();
  var _licensePlateController = TextEditingController();
  var _truckTypeController = TextEditingController();
  var _truckCapacityController = TextEditingController();
  var _truckWeightController = TextEditingController();
  var _insuranceNumberController = TextEditingController();
  bool _isCooling = false;
  final String? uid = supabase.auth.currentUser!.id;


@override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //final int uid = getDriverId() as int;
    //print(uid);
    //uid to int

    //a dialogue box with a form to add a truck that has a license plate, truck type, truck capacity, truck weight, and cooling drop down
   // final  uid = _client;
    // uid to int PostgrestFilterBuilder<dynamic>


    return AlertDialog(
      title: const Text('Add Truck'),
      //scrollable: true,

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          
          children: [
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(labelText: 'License Plate'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a license plate';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _insuranceNumberController,
              decoration: const InputDecoration(labelText: 'Insurance Number'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a insurance number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _truckTypeController,
              decoration: const InputDecoration(labelText: 'Truck Type'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a truck type';
                }
                return null;
              },
            ),

            TextFormField(
              controller: _truckCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Truck Capacity (m³)'),
              validator: (String? value) {
                // ensure the user enters a number
                if (value == null || value.isEmpty || double.parse(value) <= 0) {
                  return 'Please enter a truck capacity';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _truckWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Truck Weight (KG)'),
              validator: (String? value) {
                if (value == null || value.isEmpty || double.parse(value) <= 0) {
                  return 'Please enter a truck weight';
                }
                return null;
              },
            ),
            DropdownButton(
              value: _isCooling,
              onChanged: (bool? value) {
                setState(() {
                  _isCooling = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: false,
                  child: Text('No Cooling'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Cooling'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final response = await _client.from('trucks').insert([
                  {
                    'license_plate': _licensePlateController.text,
                    'truck_type': _truckTypeController.text,
                    'space_capacity': _truckCapacityController.text,
                    'weight_capacity': _truckWeightController.text,
                    'cooling_capacity': _isCooling,
                    'Insurance_number': _insuranceNumberController.text,
                    'driver_id': uid
                  }
                ]);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
              //refresh change vehicle page
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}