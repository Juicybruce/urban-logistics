import 'package:flutter/material.dart';
class mapMerchant extends StatefulWidget {
  const mapMerchant({Key? key}) : super(key: key);

  @override
  State<mapMerchant> createState() => _mapMerchantState();
}

class _mapMerchantState extends State<mapMerchant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Merchant Map Screen'),
      ),
    );
  }
}
