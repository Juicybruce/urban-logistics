import 'dart:async';

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


//creates the navbars and the appbars as well as the navigation between screens
class navBar extends StatefulWidget {
  const navBar({Key? key}) : super(key: key);
  static String regoNumber = '';


  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  bool isLoading = false; //show loading screen
  bool isMerchant = true; //if merchant or driver
  bool driverAvailable = false; //if driver is available
  int currentTab = 0; //current tab on screen
  User? user;

  Session? session; //session details
  String? userID; //user ID
  String? uname; //user name

  @override
  void initState() {
    isLoading = true;
    super.initState();
    user = supabase.auth.currentUser;
    session = supabase.auth.currentSession;
    userID = user?.id;
    getUserDetails();
  }

  FutureOr popChangeVehicle(dynamic value){
    setState(() {
      getUserDetails();
    });
  }

  //set driver as available
  Future<void> setAvailable() async{
    await supabase
        .from('drivers')
        .update({ 'available': true})
        .eq('driver_id', userID);
  }

  //set driver as unaavailable
  Future<void> setUnavailable() async{
    await supabase
        .from('drivers')
        .update({ 'available': false})
        .eq('driver_id', userID);
  }

  //get the details of the user
  Future<void> getUserDetails() async {
    //get supplier details
    var response = await supabase
        .from('suppliers')
        .select('first_name, last_name, business_name')
        .eq('supplier_id', userID);
    if (response.length == 0){ //if not a supplier
      response = await supabase
          .from('drivers')
          .select('first_name, last_name, trucks!drivers_current_vehicle_fkey(license_plate)')
          .eq('driver_id', userID);
      print(response[0].length);
      if(response[0]["trucks"] != null) {
        var tempString  = response[0]['trucks']['license_plate'].toString();
        navBar.regoNumber = tempString;
      } else {
        navBar.regoNumber = "";
      }
      setState(() {
        isMerchant = false;
      });
    }else{
      navBar.regoNumber = response[0]['business_name'].toString();
    }
    final String fname = response[0]['first_name'].toString();
    final String lname = response[0]['last_name'].toString();
    setState(() {
      screens = getScreens(isMerchant);
      currentScreen = screens[currentTab];
    });
    uname = "$fname $lname";
    setState(() {
      isLoading = false;
    });
  }

  late List<Widget> screens = getScreens(isMerchant);
  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen = screens[0];

  @override
  Widget build(BuildContext context) {
    if (isLoading) { //display loading overlay
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
          )
      );
    }

    return Scaffold(
      extendBody: true,
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      appBar: buildAppBar(),
      floatingActionButton: buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar( //create bottom navbar
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      currentTab = 0;
                      currentScreen = screens[currentTab];
                    });
                  },
                  child: Column( //first button MAP
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        color: currentTab == 0 ? Colors.white : Colors.black,
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'MAP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: currentTab == 0 ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      currentTab = 1;
                      currentScreen = screens[currentTab];
                    });
                  },
                  child: Column( //Second button Drivers or Joblist
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color: currentTab == 1 ? Colors.white : Colors.black,
                      ),
                      if (isMerchant) ...[
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'DRIVERS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: currentTab == 1 ? Colors.white : Colors.black),
                          ),
                        ),
                      ] else ...[
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'JOB LIST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: currentTab == 1 ? Colors.white : Colors.black),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      currentTab = 2;
                      currentScreen = screens[currentTab];
                    });
                  },
                  child: Column( //Third button My jobs
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: currentTab == 2 ? Colors.white : Colors.black,
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'MY JOBS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: currentTab == 2 ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: MaterialButton(
                  minWidth: 40,
                  onPressed: () {
                    setState(() {
                      currentTab = 3;
                      currentScreen = screens[currentTab];
                    });
                  },
                  child: Column( //Fourth button History
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: currentTab == 3 ? Colors.white : Colors.black,
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'HISTORY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: currentTab == 3 ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//create top appbar for merchants
  AppBar buildAppBar() {
    if (isMerchant == true) {
      // print("merchant");
      return AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(navBar.regoNumber, style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          PopupMenuButton(
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

  //create top appbar for drivers
  AppBar buildAppBarDriver() {
    return AppBar(
      backgroundColor: driverAvailable ?  Colors.green : null,
      centerTitle: true,
      title: Column(
        children:  [
          Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(navBar.regoNumber, style: TextStyle(fontSize: 13)),
        ],
      ),
      actions: [
        PopupMenuButton(
          // add icon, by default "3 dot" icon
            icon: const Icon(Icons.menu),
            itemBuilder: (context) {
              return [
                if(driverAvailable) ...[ //if driver is available, show set unavailable option
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Set as Unavailable'),
                  ),
                ] else ...[ //else do the opposite
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text('Set as Available'),
                  )
                ],
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Sign Out'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                if(driverAvailable){
                  setState(() {
                    driverAvailable = false;
                    setUnavailable();
                  });
                  print('IM UNAVAILABLE.');
                } else {
                  setState(() {
                    driverAvailable = true;
                    setAvailable();
                    print('IM AVAILABLE.');
                  });
                }
              } else if (value == 1) {
                setState(() {
                  driverAvailable = false;
                  setUnavailable();
                });
                print('IM LOGGING OUT');
                supabase.auth.signOut();
                Navigator.of(context).popAndPushNamed('/login');
              }
            }),
      ],
    );
  }

  //Create the center of navbar FAB
  FloatingActionButton buildFloatingActionButton() {
    if (isMerchant == true) { //if merchant, button takes user to create new post
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const newPost()));
        },
        child: const Icon(Icons.post_add),
      );
    } else { //if driver, button takes user to change vehicle
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const changeVehicle())).then(popChangeVehicle);
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


