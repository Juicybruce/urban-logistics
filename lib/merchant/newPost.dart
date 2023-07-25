import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class newPost extends StatefulWidget {
  const newPost({Key? key}) : super(key: key);

  @override
  State<newPost> createState() => _newPostState();

}


class _newPostState extends State<newPost> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient _client = Supabase.instance.client;
  late TextEditingController _goodsTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _weightController;
  late TextEditingController _sizeController;
  late TextEditingController _pickupAddressController;
  late TextEditingController _dropoffAddressController;
  late TextEditingController _coolingRequiredController;
  late TextEditingController _jobStatusController;
  late TextEditingController _driverIdController;
  late TextEditingController _supplierIdController;

  Future<void> addPost(String jobStatus, String goodsType, int quantity,
      int weight, int size, bool coolingRequired, String pickupAddress,
      String dropoffAddress, int supplierId, int driverId) async {
    final response = await _client.from('advertisements').insert([
      {
        'job_status': jobStatus,
        'goods_type': goodsType,
        'quantity': quantity,
        'weight': weight,
        'size': size,
        'cooling_required': coolingRequired,
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'supplier_id': supplierId,
        'driver_id': driverId,
      }
    ]).execute();
  }

  @override
  void initState() {
    _goodsTypeController = TextEditingController();
    _quantityController = TextEditingController();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Merchant New Post"),
      ),
      body: ListView (
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          children: [
            const SizedBox(height: 18),
            TextFormField(
              controller: _goodsTypeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Goods Type',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter goods type';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
            ),
          ]
    )
    );
  }

  postForm() {

  }


}