import 'package:flutter/material.dart';

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
