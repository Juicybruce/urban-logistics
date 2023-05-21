import 'package:flutter/material.dart';
//mapDriver is the screen that shows the driver's location

class mapDriver extends StatefulWidget {
  const mapDriver({Key? key}) : super(key: key);

  @override
  State<mapDriver> createState() => _mapDriverState();
}

class _mapDriverState extends State<mapDriver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Driver Map Screen'),
      ),
    );
  }
}
