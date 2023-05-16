import 'package:flutter/material.dart';

class historyDriver extends StatefulWidget {
  const historyDriver({Key? key}) : super(key: key);

  @override
  State<historyDriver> createState() => _historyDriverState();
}

class _historyDriverState extends State<historyDriver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Driver History Screen'),
      ),
    );
  }
}
