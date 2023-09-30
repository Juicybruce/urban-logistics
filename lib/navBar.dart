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


class navBar extends StatefulWidget {
  const navBar({Key? key}) : super(key: key);
  static String regoNumber = '';


  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  bool isLoading = false;
  bool isMerchant = true;
  bool driverAvailable = false;
  int currentTab = 0;
  User? user;

  Session? session;
  String? userID;
  String? uname;

  @override
  void initState() {
    isLoading = true;
    super.initState();
    user = supabase.auth.currentUser;
    session = supabase.auth.currentSession;
    userID = user?.id;
    getUserDetails();
  }

void setSubscribe(){
  if (isMerchant) {
    supabase.channel('public:advertisments').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'UPDATE',
          schema: 'public',
          table: 'advertisments',
          filter: 'supplier_id=eq.$userID'),
          (payload, [ref]) {
        //print('Change received: ${payload.toString()}');
        doNotificationStuff(payload['new']['job_id']);
      },
    ).subscribe();
    //print ("merch");
  } else {
    supabase.channel('public:advertisments').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'UPDATE',
          schema: 'public',
          table: 'advertisments',
          filter: 'driver_id=eq.$userID'),
          (payload, [ref]) {
        //print('Change received: ${payload.toString()}');
        doNotificationStuff(payload['new']['job_id']);
      },
    ).subscribe();
    //print ("not merch");
  }
}

  void doNotificationStuff(jobID) async {
  if(isMerchant){
    var response = await supabase
        .from('advertisments')
        .select('job_id, drivers:driver_id(driver_id, first_name, last_name, contactnumber)')
        .eq('job_id', jobID);
    String temp = 'Your Advertisment has been progressed via ${response[0]['drivers']['first_name']} ${response[0]['drivers']['last_name']}';
    print(temp);
  }else{
    var response = await supabase
        .from('advertisments')
        .select('*, suppliers:supplier_id(first_name, last_name, business_name, contact_phone)')
        .eq('job_id', jobID);
    String temp = 'Your current job has been updated by ${response[0]['suppliers']['first_name']} ${response[0]['suppliers']['last_name']}';
    print(temp);
  }


  }

  FutureOr popChangeVehicle(dynamic value){
    setState(() {
      getUserDetails();
    });
  }

  Future<void> setAvailable() async{
 await supabase
    .from('drivers')
    .update({ 'available': true})
    .eq('driver_id', userID);
  }

  Future<void> setUnavailable() async{
 await supabase
    .from('drivers')
    .update({ 'available': false})
    .eq('driver_id', userID);
  }

  Future<void> getUserDetails() async {
  var response = await supabase
      .from('suppliers')
      .select('first_name, last_name, business_name')
      .eq('supplier_id', userID);
  if (response.length == 0){
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
  //await Future.delayed(const Duration(seconds: 3));
  setState(() {
    setSubscribe();
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
                  child: Column(
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
                  child: Column(
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
                  child: Column(
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
                  child: Column(
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


  AppBar buildAppBar() {
    if (isMerchant == true) {
     // print("merchant");
      return AppBar(
        centerTitle: true,
        title: Column(
            children: [
          //buildUsername(),
              //Text(_username, style: TextStyle(fontSize: 13)),
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
      return AppBar(
        backgroundColor: driverAvailable ?  Colors.green : null,
        centerTitle: true,
        title: Column(
          children:  [
            Text(uname!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(navBar.regoNumber, style: TextStyle(fontSize: 13)),
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
                  if(driverAvailable) ...[
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('Set as Unavailable'),
                    ),
                  ] else ...[
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


