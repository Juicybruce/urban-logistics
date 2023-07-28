import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'driver/activeDriver.dart';
import 'driver/changeVehicle.dart';
import 'driver/historyDriver.dart';
import 'driver/listDriver.dart';
import 'driver/mapDriver.dart';
import 'merchant/activeMerchant.dart';
import 'merchant/historyMerchant.dart';
import 'merchant/listMerchant.dart';
import 'merchant/mapMerchant.dart';
import 'merchant/newPost.dart';
import 'dart:async';

import 'pages/splash_page.dart';

class navBar extends StatefulWidget {
  const navBar({Key? key}) : super(key: key);

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  bool isLoading = false;
  bool isMerchant = true; // TODO change this to userprefs or something or get user type from db/ Current accepted userTypes are 'merchant' and 'driver'(well anything but merchant)
  bool driverAvailable = false;
  int currentTab = 0;
  User? user;

  Session? session;
  String? email;
  String? subTitle;
  Future<String>? _username;
  String? uname;

  @override
  void initState() {
    isLoading = true;
    super.initState();
    user = supabase.auth.currentUser;
    session = supabase.auth.currentSession;
    email = user?.email;
    //_username =
    xyz();
  }

  void xyz() async {
  var response = await supabase
      .from('suppliers')
      .select('first_name, last_name, business_name')
      .eq('email', email);
  if (response.length == 0){
    response = await supabase
        .from('drivers')
        .select('first_name, last_name, trucks!drivers_current_vehicle_fkey(license_plate)')
        .eq('email', email);
    var tempString  = response[0]['trucks'].toString();
    tempString = tempString.substring(16, tempString.length-1);
    print(tempString);
    subTitle = tempString;
    setState(() {
      isMerchant = false;
    });
  }else{
    subTitle = response[0]['business_name'].toString();
  }
  final String fname = response[0]['first_name'].toString();
  final String lname = response[0]['last_name'].toString();
  setState(() {
    screens = getScreens(isMerchant);
    currentScreen = screens[currentTab];
  });
  uname = "$fname $lname";
  //await Future.delayed(const Duration(seconds: 3));
  setState(() {
    isLoading = false;
  });
  //return "$fname $lname";
  }

  late List<Widget> screens = getScreens(isMerchant);
  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen = screens[0];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      const String iconPath = 'assets/truck.svg';
      return  Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      colorFilter:
                      ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
                      semanticsLabel: 'Truck Icon',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Urban Logistics',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 20),
                    CircularProgressIndicator()
                  ],
                )),
          ));
    }

    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentTab = 0;
                    currentScreen = screens[currentTab];
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: currentTab == 0 ? Colors.white : Colors.black,
                    ),
                    Text(
                      '   Map   ',
                      style: TextStyle(
                          color: currentTab == 0 ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentTab = 1;
                    currentScreen = screens[currentTab];
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color: currentTab == 1 ? Colors.white : Colors.black,
                    ),
                    Text(
                      '   List  ',
                      style: TextStyle(
                          color: currentTab == 1 ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentTab = 2;
                    currentScreen = screens[currentTab];
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: currentTab == 2 ? Colors.white : Colors.black,
                    ),
                    Text(
                      'Activity',
                      style: TextStyle(
                          color: currentTab == 2 ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentTab = 3;
                    currentScreen = screens[currentTab];
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: currentTab == 3 ? Colors.white : Colors.black,
                    ),
                    Text(
                      'History',
                      style: TextStyle(
                          color: currentTab == 3 ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  AppBar buildAppBar() {
    if (isMerchant == true) {
      print("merchant");
      return AppBar(
        centerTitle: true,
        title: Column(
            children: [
          //buildUsername(),
              //Text(_username, style: TextStyle(fontSize: 13)),
              Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
             Text(subTitle!, style: TextStyle(fontSize: 13)),
           ],
        ),
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              icon: const Icon(Icons.menu),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Sign Out'),
                  ),
                ];
              },
              
              onSelected: (value) {
                if (value == 0) {
                  print('IM LOGGING OUT');
                  supabase.auth.signOut();
                  Navigator.of(context).popAndPushNamed('/login');
                }
              }),
        ],
      );
    } else {
      return buildAppBarDriver();
    }
  }

  AppBar buildAppBarDriver() {
    if (driverAvailable) {
      return AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Column(
          children: [
            Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subTitle!, style: TextStyle(fontSize: 13)),
            //buildUsername(),
            //Text('<vehicle rego number>', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot"
              icon: const Icon(Icons.menu),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Set Available'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Set Unavailable'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Sign Out'),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  setState(() {
                    driverAvailable = true;
                    //TODO: set driver to available in db
                  });
                  print('IM AVAILABLE.');
                } else if (value == 1) {
                  setState(() {
                    driverAvailable = false;
                    //TODO: set driver to unavailable in db
                  });
                  print('IM UNAVAILABLE.');
                } else if (value == 2) {
                  setState(() {
                    driverAvailable = false;
                    //TODO: set driver to unavailable in db
                  });
                  print('IM LOGGING OUT');
                  supabase.auth.signOut();
                  Navigator.of(context).popAndPushNamed('/login');
                }
              }),
        ],
      );
    } else {
      return AppBar(
        centerTitle: true,
        title: Column(
          children:  [
            Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subTitle!, style: TextStyle(fontSize: 13)),
            // buildUsername(),
            // Text('<vehicle rego number>', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              icon: const Icon(Icons.menu),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Set Available'),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Set Unavailable'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Sign Out'),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  setState(() {
                    driverAvailable = true;
                    //TODO: set driver to available in db
                  });
                  print('IM AVAILABLE.');
                } else if (value == 1) {
                  setState(() {
                    driverAvailable = false;
                    //TODO: set driver to unavailable in db
                  });
                  print('IM UNAVAILABLE.');
                } else if (value == 2) {
                  setState(() {
                    driverAvailable = false;
                    //TODO: set driver to unavailable in db
                  });
                  print('IM LOGGING OUT');
                  supabase.auth.signOut();
                  Navigator.of(context).popAndPushNamed('/login');
                }
              }),
        ],
      );
    }
  }
//Obsolete???
  // FutureBuilder<String> buildUsername() {
  //   return FutureBuilder<String>(
  //       future: _username,
  //       builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
  //         List<Widget> children;
  //         if (snapshot.hasData) {
  //           children = <Widget>[
  //             Text(
  //                 snapshot.data.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
  //           ];
  //         } else if (snapshot.hasError){
  //           children = <Widget>[
  //             // Text(
  //             //     "ERROR", style: TextStyle(fontSize: 13)),
  //           ];
  //         }else {
  //           children = const <Widget>[];
  //         }
  //         return Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: children,
  //           ),
  //         );
  //       }
  //   );
  // }

  FloatingActionButton buildFloatingActionButton() {
    if (isMerchant == true) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const newPost()));
        },
        child: const Icon(Icons.post_add),
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const changeVehicle()));
        },
        child: const Icon(Icons.compare_arrows),
      );
    }
  }
}

List<Widget> getScreens(bool isMerchant) {
  if (isMerchant == true) {
    return [
      const mapMerchant(),
      const listMerchant(),
      const activeMerchant(),
      const historyMerchant()
    ];
  } else {
    return [
      const mapDriver(),
      const listDriver(),
      const activeDriver(),
      const historyDriver()
    ];
  }
}
