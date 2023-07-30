import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class addPost extends StatefulWidget {
  const addPost({super.key});

  @override
  State<addPost> createState() => _addPostState();
}

class _addPostState extends State<addPost> {
  //supabase client
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  var _goodsTypeController = TextEditingController();
  var _weightController = TextEditingController();
  var _sizeController = TextEditingController();
  var _addressPickupController = TextEditingController();
  var _addressDeliveryController = TextEditingController();
  var _goodsQuantityController = TextEditingController();
  bool needsFridge = false;

  @override
  Widget build(BuildContext context) {
    //a dialogue box with a form to add a post
    return AlertDialog(
      title: const Text('Add Job'),
      //scrollable: true,

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextFormField(
                controller: _goodsTypeController,
                decoration: const InputDecoration(labelText: 'Goods Type'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type of goods';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _goodsQuantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantity of Items'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Weight in kilograms (each item)'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Approximate total size'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a approximate size ';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Needs Refridgeration?'),
                    Switch(
                      value: needsFridge,
                      activeColor: Colors.pinkAccent,
                      activeTrackColor: Color.fromARGB(255, 228, 142, 171),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            needsFridge = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _addressPickupController,
                decoration: const InputDecoration(labelText: 'Pickup Address'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressDeliveryController,
                decoration:
                    const InputDecoration(labelText: 'Delivery Address'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                final currentUser = await supabase.auth.currentUser;
                if (currentUser != null) {
                  final userID = currentUser.id;
                  final response = await _client.from('advertisments').insert([
                    {
                      'goods_type': _goodsTypeController.text,
                      'weight': _weightController.text,
                      'size': _sizeController.text,
                      'pickup_address': _addressPickupController.text,
                      'dropoff_address': _addressDeliveryController.text,
                      'quantity': _goodsQuantityController.text,
                      'supplier_id': userID,
                      'cooling_required': needsFridge,
                    }
                  ]);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
              //refresh change vehicle page

              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
