import 'package:flutter/material.dart';

class activeMerchant extends StatefulWidget {
  const activeMerchant({Key? key}) : super(key: key);

  @override
  State<activeMerchant> createState() => _activeMerchantState();
}

class _activeMerchantState extends State<activeMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Merchant Active Screen'),
      ),
    );
  }
}
