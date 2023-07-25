import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class newPost extends StatefulWidget {
  const newPost({Key? key}) : super(key: key);

  @override
  State<newPost> createState() => _newPostState();

}


class _newPostState extends State<newPost> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SupabaseClient _client = Supabase.instance.client;
  late TextEditingController _goodsTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _weightController;
  late TextEditingController _sizeController;
  late TextEditingController _pickupAddressController;
  late TextEditingController _dropoffAddressController;
  late bool _coolingRequiredController;
  late TextEditingController _jobStatusController;
  late TextEditingController _driverIdController;
  late TextEditingController _supplierIdController;

  Future<void> addPost(String jobStatus, String goodsType, int quantity,
      int weight, int size, bool coolingRequired, String pickupAddress,
      String dropoffAddress, int supplierId, int driverId) async {
    final PostgrestResponse response = await _client.from('advertisements').insert([
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
    _weightController = TextEditingController();
    _sizeController = TextEditingController();
    _pickupAddressController = TextEditingController();
    _dropoffAddressController = TextEditingController();
    _coolingRequiredController = false;
    _jobStatusController = TextEditingController();
    _driverIdController = TextEditingController();
    _supplierIdController = TextEditingController();
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
              validator: (String? value) {
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
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Weight',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Size',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter size';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _pickupAddressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pickup Address',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pickup address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _dropoffAddressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dropoff Address',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dropoff address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _supplierIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Supplier ID',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter supplier ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            // cooling required dropdown
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Cooling Required',
              ),
              value: _coolingRequiredController,
              onChanged: (bool? newValue) {
                setState(() {
                  _coolingRequiredController = newValue!;
                });
              },
              items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                return DropdownMenuItem<bool>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addPost(
                      _jobStatusController.text,
                      _goodsTypeController.text,
                      int.tryParse(_quantityController.text)!,
                      int.tryParse(_weightController.text)!,
                      int.tryParse(_sizeController.text)!,
                      _coolingRequiredController,
                      _pickupAddressController.text,
                      _dropoffAddressController.text,
                      int.tryParse(_supplierIdController.text)!,
                      int.tryParse(_driverIdController.text)!);
                  Navigator.of(context).pushNamed('/home');
                }
              },
              child: const Text('Submit'),
            ),

          ]
    )
    );
  }

  postForm() {

  }


}