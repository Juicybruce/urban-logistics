import 'package:flutter/material.dart';

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

  @override
  State<navBar> createState() => _navBarState();

}

class _navBarState extends State<navBar> {

  int currentTab = 0;

  String userType = "yy"; // TODO change this to userprefs or something or get user type from db/ Current accepted userTypes are 'merchant' and 'driver'(well anything but merchant)

  late List<Widget> screens = getScreens(userType);

  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen = screens[0];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
        appBar :buildAppBar(),
      floatingActionButton: buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.pinkAccent,
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
                    Icon(Icons.map,
                      color: currentTab == 0 ? Colors.white : Colors.black,),
                    Text("   Map   ",
                      style: TextStyle(color: currentTab == 0 ? Colors.white : Colors.black),
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
                    Icon(Icons.list,
                    color: currentTab == 1 ? Colors.white : Colors.black,),
                    Text("   List  ",
                      style: TextStyle(color: currentTab == 1 ? Colors.white : Colors.black),
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
                    Icon(Icons.directions_car,
                      color: currentTab == 2 ? Colors.white : Colors.black,),
                    Text("Activity",
                      style: TextStyle(color: currentTab == 2 ? Colors.white : Colors.black),
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
                    Icon(Icons.history,
                      color: currentTab == 3 ? Colors.white : Colors.black,),
                    Text("History",
                    style: TextStyle(color: currentTab == 3 ? Colors.white : Colors.black),
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
    if (userType == "merchant") {
      return AppBar(
        centerTitle: true,
        title: Column( children: [
          Text("MERCHANT NAME",style: TextStyle(fontWeight: FontWeight.bold),),
          Text("<mechant business name>", style: TextStyle(fontSize: 13)),
        ],),
        backgroundColor: Colors.pinkAccent,
        actions: [
          PopupMenuButton(
            // add icon, by default "3 dot" icon
            //icon: Icon(Icons.book),
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Sign Out"),
                  ),
                ];
              },
              onSelected:(value){
              if(value == 0){
                  print("IM LOGGING OUT");
                }
              }
          ),
        ],
      );
    } else  {
      return AppBar(
        centerTitle: true,
        title: Column( children: [
          Text("DRIVER NAME",style: TextStyle(fontWeight: FontWeight.bold),),
          Text("<vehicle rego number>", style: TextStyle(fontSize: 13)),
        ],),
        backgroundColor: Colors.pinkAccent,
        actions: [
          PopupMenuButton(
            // add icon, by default "3 dot" icon
            //icon: Icon(Icons.book),
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("Set Available"),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Set Unavailable"),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text("Sign Out"),
                  ),
                ];
              },
              onSelected:(value){
                if(value == 0){
                  print("IM AVAILABLE.");
                }else if(value == 1){
                  print("IM UNAVAILABLE.");
                }else if(value == 2){
                  print("IM LOGGING OUT");
                }
              }
          ),
        ],
      );
    }
  }

  FloatingActionButton buildFloatingActionButton() {
    if(userType == "merchant"){
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => newPost()));
        },
        child: const Icon(Icons.post_add),
        backgroundColor: Colors.purple,
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => changeVehicle()));
        },
        child: const Icon(Icons.compare_arrows),
        backgroundColor: Colors.purple,
      );
    }

  }
}

List<Widget> getScreens(String userType) {
  if (userType == "merchant") {
    return [
      mapMerchant(),
      listMerchant(),
      activeMerchant(),
      historyMerchant()

    ];
  } else  {
    return [
      mapDriver(),
      listDriver(),
      activeDriver(),
      historyDriver()
    ];
  }
}
