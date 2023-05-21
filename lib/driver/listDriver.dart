import 'package:flutter/material.dart';

class listDriver extends StatefulWidget {
  const listDriver({Key? key}) : super(key: key);

  @override
  State<listDriver> createState() => _listDriverState();
}

class _listDriverState extends State<listDriver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Driver List Screen'),
      ),
    );
  }
}
