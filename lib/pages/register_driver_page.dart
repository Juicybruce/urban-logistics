import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class RegisterDriver extends StatefulWidget {
  @override
  _RegisterDriverState createState() => _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  //date of birth
  final TextEditingController _dobController = TextEditingController();
  //driver license number
  final TextEditingController _driverLicenseNumberController =
      TextEditingController();
  //emergency contact name, relation and number
  final TextEditingController _emergencyContactNameController =
      TextEditingController();
  final TextEditingController _emergencyContactRelationController =
      TextEditingController();
  final TextEditingController _emergencyContactNumberController =
      TextEditingController();

  // company name
  final TextEditingController _companyNameController = TextEditingController();

  // delivery experience
  final TextEditingController _deliveryExperienceController =
      TextEditingController();

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
    _bankAccountNumberController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _driverLicenseNumberController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactRelationController.dispose();
    _emergencyContactNumberController.dispose();
    _companyNameController.dispose();
    _deliveryExperienceController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Profile details section
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
                // driver details section with padding above
                SizedBox(height: 16.0),
                const Text(
                  'Driver Details',
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
                // date of birth
                TextFormField(
                  controller: _dobController,
                  decoration:
                      InputDecoration(labelText: 'Date of Birth - DD/MM/YYYY'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth .';
                    }
                    return null;
                  },
                ),
                // delivery experience
                TextFormField(
                  controller: _deliveryExperienceController,
                  decoration: InputDecoration(
                      labelText: 'Years of Delivery Experience'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your delivery experience in years.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _driverLicenseNumberController,
                  decoration: InputDecoration(labelText: 'License Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your drivers license number.';
                    }
                    return null;
                  },
                ),
                // company name
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(labelText: 'Company Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your company name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                  validator: (value) {
                    RegExp phoneNumberPattern = RegExp(r'^\d{10}$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number.';
                    }
                    if (!phoneNumberPattern.hasMatch(value)) {
                      return 'Invalid phone number. Please enter 10 digits.';
                    }
                    return null;
                  },
                ),
                // three input fields ffor emergency contact details
                SizedBox(height: 28.0),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Emergency Contact Details:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),

                TextFormField(
                  controller: _emergencyContactNameController,
                  decoration: const InputDecoration(
                      labelText: 'Emergency Contact Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your emergency contact name.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emergencyContactRelationController,
                  decoration: const InputDecoration(
                      labelText: 'Emergency Contact Relation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your emergency contact relation.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emergencyContactNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Emergency Contact Number'),
                  validator: (value) {
                    RegExp phoneNumberPattern = RegExp(r'^\d{10}$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your emergency contact number.';
                    }
                    if (!phoneNumberPattern.hasMatch(value)) {
                      return 'Invalid phone number. Please enter 10 digits.';
                    }
                    return null;
                  },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          final bankAccountNumber =
                              _bankAccountNumberController.text;
                          final address = _addressController.text;
                          final dob = _dobController.text;
                          final driverLicenseNumber =
                              _driverLicenseNumberController.text;
                          final emergencyContactName =
                              _emergencyContactNameController.text;
                          final emergencyContactRelation =
                              _emergencyContactRelationController.text;
                          final emergencyContactNumber =
                              _emergencyContactNumberController.text;
                          final companyName = _companyNameController.text;
                          final deliveryExperience =
                              _deliveryExperienceController.text;

                          final response = await supabase.auth
                              .signUp(email: email, password: password);

                          if (response.user != null) {
                            final userId = response.user!.id;
                            await supabase.from('drivers').upsert([
                              {
                                'driver_id': userId,
                                'email': email,
                                'first_name': firstName,
                                'last_name': lastName,
                                'contactnumber': contactNumber,
                                'payment_details': bankAccountNumber,
                                'driver_address': address,
                                'DOB': dob,
                                'license_number': driverLicenseNumber,
                                'emergency_contact_name': emergencyContactName,
                                'emergency_contact_relation':
                                    emergencyContactRelation,
                                'emergency_contact_number':
                                    emergencyContactNumber,
                                'company_name': companyName,
                                'delivery_experience': deliveryExperience,
                                'license_number': driverLicenseNumber,
                              }
                            ]);
                          } else {
                            print("Sign-up error: User creation failed.");
                          }
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
