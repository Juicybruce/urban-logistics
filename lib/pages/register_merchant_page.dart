import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class RegisterMerchant extends StatefulWidget {
  @override
  _RegisterMerchantState createState() => _RegisterMerchantState();
}

class _RegisterMerchantState extends State<RegisterMerchant> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _businessNameController = TextEditingController();
  TextEditingController _ABNController = TextEditingController();
  TextEditingController _bankAccountNumberController = TextEditingController();
  TextEditingController _businessAddressController = TextEditingController();
  TextEditingController _yearEstablishedController = TextEditingController();
  TextEditingController _productTypeController = TextEditingController();
  TextEditingController _businessTypeController = TextEditingController();


  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _ABNController.dispose();
    _bankAccountNumberController.dispose();
    _businessAddressController.dispose();
    _yearEstablishedController.dispose();
    _productTypeController.dispose();
    _businessTypeController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text(
                  'Profile Details',
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    }
                    // Email pattern validation
                    final emailRegex =
                        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password.';
                    }
                    if (value.length < 10) {
                      return 'Password should be at least 10 characters long.';
                    }
                    if (!value.contains(RegExp(r'\d'))) {
                      return 'Password should contain at least one number.';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password should contain at least one uppercase letter.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password.';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                const Text(
                  'Personal Details',
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                const Text(
                  'Business Details',
                  style: TextStyle(fontSize: 20),
                ),
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(labelText: 'Business Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ABNController,
                  decoration: InputDecoration(labelText: 'ABN'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ABN.';
                    }
                    RegExp phoneNumberPattern = RegExp(
                        r'^\d{10}$'); //TODO make this 11 digits once the database has changed to not be an int 4 for this field
                    if (!phoneNumberPattern.hasMatch(value)) {
                      return 'Invalid ABN. Please enter 10 digits.';
                    }
                    return null;
                  },
                ),
                // fields for business_address year_established product_type business_type
                TextFormField(
                  controller: _businessAddressController,
                  decoration: InputDecoration(labelText: 'Business Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business address.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearEstablishedController,
                  decoration: InputDecoration(labelText: 'Year Established'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the year your business was established.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _productTypeController,
                  decoration: InputDecoration(labelText: 'Product Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your product type.';
                    }
                    return null;
                  },
                ),
                // make this a dropdown
                DropdownButtonFormField(
                //'Business to Business', 'Business to Consumer' , 'Consumer to Consumer' , 'Business to Business/Consumer'
                items: ['Business to Business', 'Business to Consumer' , 'Business to Business/Consumer'].map((String businessType) {
                  return DropdownMenuItem(
                      value: businessType,
                      child: new Text(businessType)
                  );
                }).toList(),
                hint: Text('Business Type'),
                onChanged: (String? value) {
                  setState(() {
                    _businessTypeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business type.';
                  }
                  return null;
                },
                  //old code
               /* TextFormField(
                  controller: _businessTypeController,
                  decoration: InputDecoration(labelText: 'Business Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business type.';
                    }
                    return null;
                  },
                ),*/
                ),


                TextFormField(
                  controller: _bankAccountNumberController,
                  decoration: InputDecoration(labelText: 'Bank Account Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bank account number.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Back')),
                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );

                        final email = _emailController.text;
                        final password = _passwordController.text;
                        final firstName = _firstNameController.text;
                        final lastName = _lastNameController.text;
                        final contactNumber = _contactNumberController.text;
                        final businessName = _businessNameController.text;
                        final ABN = _ABNController.text;
                        final bankAccountNumber =
                            _bankAccountNumberController.text;
                        final businessAddress = _businessAddressController.text;
                        final yearEstablished = _yearEstablishedController.text;
                        final productType = _productTypeController.text;
                        final businessType = _businessTypeController.text;

                        final response = await supabase.auth
                            .signUp(email: email, password: password);

                        if (response.user != null) {
                          final userId = response.user!.id;
                          await supabase.from('suppliers').upsert([
                            {
                              'supplier_id': userId,
                              'email': email,
                              'first_name': firstName,
                              'last_name': lastName,
                              'contact_phone': contactNumber,
                              'business_name': businessName,
                              'business_registration': ABN,
                              'billing_details': bankAccountNumber,
                              'business_address': businessAddress,
                              'year_established': yearEstablished,
                              'product_type': productType,
                              'business_type': businessType,
                            }
                          ]);
                        } else {
                          print("Sign-up error: User creation failed.");
                        }
                      }
                    },
                    child: Text('Submit'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
