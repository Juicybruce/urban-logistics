import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class newPost extends StatefulWidget {
  const newPost({Key? key}) : super(key: key);

  @override
  State<newPost> createState() => _newPostState();
}

// TODO - add validation for time, add calulation for distance and price

class _newPostState extends State<newPost> {
  final _formKey = GlobalKey<FormState>();
  final _goodsTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _addressPickupController = TextEditingController();
  final _addressDeliveryController = TextEditingController();
  final _goodsQuantityController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _pickupTimeController = TextEditingController();
  bool needsFridge = false;

  @override
  Widget build(BuildContext context) {
    //a dialogue box with a form to add a post
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Job'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 16.0),
                const Text(
                  'Package Details',
                  style: TextStyle(fontSize: 20),
                ),
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
                      labelText: 'Total Weight in grams (g)'),
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
                  decoration: const InputDecoration(
                      labelText: 'Approximate total size (M³)'),
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
                SizedBox(height: 16.0),
                const Text(
                  'Delivery Details',
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _addressPickupController,
                  decoration:
                      const InputDecoration(labelText: 'Pickup Address'),
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
                //controller for contact_name, contact_number and pickup time
                TextFormField(
                  controller: _contactNameController,
                  decoration: const InputDecoration(labelText: 'Contact Name'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactNumberController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pickupTimeController,
                  decoration:
                      const InputDecoration(labelText: 'Pickup Time (24hr)'),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a pickup time';
                    }
                    //additional validation for time in the correct format for time without time zone as stored in a postgresql database
                    if (DateTime.parse(value) == null) {
                      return 'Please enter a valid time';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final currentUser = await supabase.auth.currentUser;
                        if (currentUser != null) {
                          final userID = currentUser.id;
                          final response =
                              await supabase.from('advertisments').insert([
                            {
                              'goods_type': _goodsTypeController.text,
                              'weight': _weightController.text,
                              'size': _sizeController.text,
                              'pickup_address': _addressPickupController.text,
                              'dropoff_address':
                                  _addressDeliveryController.text,
                              'quantity': _goodsQuantityController.text,
                              'supplier_id': userID,
                              'cooling_required': needsFridge,
                              'job_status': 'POSTED',
                              'contact_name': _contactNameController.text,
                              'contact_number': _contactNumberController.text,
                              'pickup_time': _pickupTimeController.text,
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
            ),
          ),
        ),
      ),
    );
  }
}
