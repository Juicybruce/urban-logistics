import 'package:flutter/material.dart';

class listMerchant extends StatefulWidget {
  const listMerchant({Key? key}) : super(key: key);

  @override
  State<listMerchant> createState() => _listMerchantState();
}

class _listMerchantState extends State<listMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Merchant List Screen'),
      ),
    );
  }
}
