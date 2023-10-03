import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

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
  final _dropoffTimeController = TextEditingController();
  DateTime? _pickupDateTime;
  DateTime? _dropoffDateTime;
  bool needsFridge = false;

  Future<void> _selectPickupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickupDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      _selectPickupTime(context, picked);
    }
  }

  Future<void> _selectPickupTime(
      BuildContext context, DateTime initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (picked != null) {
      final DateTime selectedPickupDateTime = DateTime(
        initialTime.year,
        initialTime.month,
        initialTime.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        _pickupDateTime = selectedPickupDateTime.toLocal();
        _pickupTimeController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedPickupDateTime);
      });
    }
  }

  Future<void> _selectDropoffDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dropoffDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      _selectDropoffTime(context, picked);
    }
  }

  Future<void> _selectDropoffTime(
      BuildContext context, DateTime initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (picked != null) {
      final DateTime selectedDropoffDateTime = DateTime(
        initialTime.year,
        initialTime.month,
        initialTime.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        _dropoffDateTime = selectedDropoffDateTime.toLocal();
        _dropoffTimeController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(selectedDropoffDateTime);
      });
    }
  }

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
                  decoration:
                      const InputDecoration(labelText: 'Total weight (kg)'),
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
                      return 'Please enter a approximate size';
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
                  decoration: InputDecoration(
                    labelText: 'Enter Pickup Date and Time',
                    suffixIcon: InkWell(
                      onTap: () {
                        _selectPickupDate(context);
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectPickupDate(
                        context); // Show date picker on text field tap as well
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date and time';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dropoffTimeController,
                  decoration: InputDecoration(
                    labelText: 'Enter a delivery date and time',
                    suffixIcon: InkWell(
                      onTap: () {
                        _selectDropoffDate(context);
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDropoffDate(
                        context); // Show date picker on text field tap as well
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a date and time';
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
                          final wieght =
                              double.tryParse(_weightController.text)?.toInt();
                          final formattedPickupTime =
                              _pickupDateTime?.toIso8601String();
                          final formattedDeliveryTime =
                              _dropoffDateTime?.toIso8601String();
                          final response =
                              await supabase.from('advertisments').insert([
                            {
                              'goods_type': _goodsTypeController.text,
                              'weight': wieght,
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
                              'pickup_time': formattedPickupTime,
                              'delivery_time': formattedDeliveryTime,
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
