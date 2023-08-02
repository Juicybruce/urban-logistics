import 'dart:async';
import 'package:flutter/material.dart';

class activeDriver extends StatefulWidget {
  const activeDriver({Key? key}) : super(key: key);

  @override
  State<activeDriver> createState() => _activeDriverState();
}

class _activeDriverState extends State<activeDriver> {

  @override
  void initState() { }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Driver Activity Screen'),
      ),
    );
  }
}
