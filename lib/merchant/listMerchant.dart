import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

//display a list of active drivers for the merchants
class listMerchant extends StatefulWidget {
  const listMerchant({Key? key}) : super(key: key);

  @override
  State<listMerchant> createState() => _listMerchantState();
}

class _listMerchantState extends State<listMerchant> {
  bool isLoading = false; //for the loading screen
  late List<bool> expanded; //list of bools, for displaying expanded information, or not
  String? userID; //user ID
  User? user; //user details
  late List<dynamic>? dbdata; //data from the database

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    userID = user?.id;
    getDrivers();
    super.initState();
  }

  //get a list of active drivers
  Future<void> getDrivers() async {
    await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('drivers')
        .select('*, trucks!drivers_current_vehicle_fkey(*)')
        .eq('available', true);
    //.order('job_id', ascending: false); //TODO: Order by closest or something like
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }

  OverlayEntry? overlay;

  //display loading overlay
  void loadingOverlay() {
    const String iconPath = 'assets/truck.svg';
    overlay = OverlayEntry(builder: (BuildContext context) {
      return Scaffold(
          backgroundColor: Colors.white.withOpacity(0.7),
          body: Padding(
            padding: const EdgeInsets.all(0),
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
    });
    Overlay.of(context, debugRequiredFor: widget).insert(overlay!);
  }

  //remove loading overlay
  void removeLoadingOverlay() {
    overlay?.remove();
    overlay = null;
  }

  //dispose of overlay
  @override
  void dispose() {
    removeLoadingOverlay();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) { //show the loading screen
      const String iconPath = 'assets/truck.svg';
      return Scaffold(
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

    //build the list of drivers
    return Scaffold(
      body: Center(
        child: RefreshIndicator(
          edgeOffset: -100,
          displacement: 50,
          child: ListView.builder(
            itemCount: dbdata?.length,
            itemBuilder: (BuildContext context, int index) {
              return buildCard(index, expanded, dbdata);
            },
            physics: const AlwaysScrollableScrollPhysics(),
          ),
          onRefresh: () async {
            loadingOverlay();
            setState(() {
              getDrivers();
            });
            print("REFRESHED");
            return Future.delayed(Duration(seconds: 0), () {});
          },
        ),
      ),
    );
  }

  //create each card on the list
  Card buildCard(int index, List<bool> expanded, dynamic data) {
    print(data[index]['job_status']);
    Color? cardColor = ColorConstants.merchantListColor;
    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsetsDirectional.only(top: 2.0),
          child: Column(
            children: [
              Text(
                '${data[index]['first_name']} ${data[index]['last_name']}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              buildDriverLicense_plate(data, index),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8.0, top: 2.0),
          child: buildSubstring(index, data),
        ),
        onTap: () {
          print("TAPPED ${index}");
          setState(() { //expand the list tile
            expanded[index] = !expanded[index];
          });
        },
        tileColor: cardColor,
      ),
    );
  }

  //get the license plate details
  Text buildDriverLicense_plate(data, int index) {
    if (data[index]['trucks'] != null) {
      return Text(
        '${data[index]['trucks']['license_plate']}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      );
    } else {
      return Text(
        'No Vehicle Selected',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      );
    }
  }

  //build the details of the expended list
  Column buildSubstring(int index, dynamic data) {
    if (expanded[index] != true) {
      return Column(
        children: [
        ],
      );
    } else { //if expanded show details
      Color? textColor =
      data[index]['job_status'] == 'POSTED' ? Colors.white : Colors.black;
      return Column(
        children: [
          Divider( thickness: 1, color: textColor,),
          buildExpandedRow(data, index, 'Distance',
              "${data[index]['distance']} Km", textColor),
          buildExpandedRow(data, index, 'Contact Number',
              data[index]['contactnumber'].toString(), textColor),
          buildExpandedRow(data, index, 'Experience',
              '${data[index]['delivery_experience']} Years', textColor),
          if (data[index]['company_name'] != null) ...[
            buildExpandedRow(data, index, 'Pickup Company',
                data[index]['company_name'].toString(), textColor),
          ],
          if (data[index]['trucks'] != null) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
              child: Text('Vehicle Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),
            buildExpandedRow(data, index, 'Vehicle Registration Number',
                data[index]['trucks']['license_plate'].toString(), textColor),
            buildExpandedRow(data, index, 'Type of Truck',
                data[index]['trucks']['truck_type'].toString(), textColor),
            buildExpandedRow(data, index, 'Maximum Capacity',
                '${data[index]['trucks']['space_capacity']} M³', textColor),
            buildExpandedRow(data, index, 'Maximum Weight',
                '${data[index]['trucks']['weight_capacity']} Kg', textColor),
            if (data[index]['trucks']['cooling_capacity'] == true) ...[
              buildExpandedRow(
                  data, index, 'Cooling Available', 'Yes', textColor)
            ] else ...[
              buildExpandedRow(
                  data, index, 'Cooling Available', 'No', textColor)
            ]
          ],
        ],
      );
    }
  }

  //build each element on the extended list
  Row buildExpandedRow(
      data, int index, String leftText, String rightText, Color textColor) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    leftText,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ))),
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(rightText,
                      style: TextStyle(color: textColor, fontSize: 15)),
                ))),
      ],
    );
  }
}
