import 'package:flutter/material.dart';

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
        child: Text('Driver Change Vehicle Screen'),
      ),
    );
  }
}
