import 'package:flutter/material.dart';
import'addVehicle.dart';

class changeVehicle extends StatefulWidget {
  const changeVehicle({Key? key}) : super(key: key);

  @override
  State<changeVehicle> createState() => _changeVehicleState();
}

class _changeVehicleState extends State<changeVehicle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Change Vehicle"),
        centerTitle: true,),

      body: Center(
        child: //add vehicle button that shows dialog box to add vehicle
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addVehicle()),
            );
          },
          child: Text('Add Vehicle'),

        ),

      ),
    );
  }
}
