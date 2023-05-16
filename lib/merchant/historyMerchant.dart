import 'package:flutter/material.dart';

class historyMerchant extends StatefulWidget {
  const historyMerchant({Key? key}) : super(key: key);

  @override
  State<historyMerchant> createState() => _historyMerchantState();
}

class _historyMerchantState extends State<historyMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Merchant History Screen'),
      ),
    );
  }
}
