import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'constants.dart';
import 'navBar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, //REMOVES THE DEBUG BANNER

      home: const navBar(),
    );
  }
}


// add truck page that has a form to add a truck in a diloge box with a button to add a truck to the database

class AddTruck extends StatefulWidget {

  const AddTruck({super.key});

  @override
  State<AddTruck> createState() => _AddTruckState();
}

class _AddTruckState extends State<AddTruck> {
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
    //a dialogue box with a form to add a truck that has a license plate, truck type, truck capacity, truck weight, and cooling drop down
    return AlertDialog(
      title: const Text('Add Truck'),
      content: Form(
        key: _formKey,
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
              decoration: const InputDecoration(labelText: 'Truck Capacity'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a truck capacity';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _truckWeightController,
              decoration: const InputDecoration(labelText: 'Truck Weight'),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
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
                    'driver_id': '1',
                  }
                ]);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}







