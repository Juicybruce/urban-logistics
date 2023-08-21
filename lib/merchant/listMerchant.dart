import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class listMerchant extends StatefulWidget {
  const listMerchant({Key? key}) : super(key: key);

  @override
  State<listMerchant> createState() => _listMerchantState();
}

class _listMerchantState extends State<listMerchant> {
  bool isLoading = false;
  late List<bool> expanded;
  String? userID;
  User? user;
  late List<dynamic>? dbdata;

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    //email = user?.email;
    userID = user?.id;

    getDrivers();
    super.initState();
  }

  Future<void> getDrivers() async {
    await Future.delayed(const Duration(seconds: 1));
    var response = await supabase
        .from('drivers')
        .select('*, trucks!drivers_current_vehicle_fkey(*)')
        .eq('available', true);
    //.order('job_id', ascending: false); //TODO: Order by closest or something like
    print(response);
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    //print("TEST1  ${dbdata?[0]['job_status']}");
    //print("TEST1  ${dbdata?[1]}");
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }
  OverlayEntry? overlay;

  void loadingOverlay(){
    const String iconPath = 'assets/truck.svg';
    overlay = OverlayEntry(
        builder: (BuildContext context){
          return Scaffold(
              backgroundColor: Colors.white.withOpacity(0.7),
              body: Padding(
                padding: const EdgeInsets.all(0),

                child: Container(
                  //color: Colors.green.withOpacity(0.5),
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

  void removeLoadingOverlay() {
    overlay?.remove();
    overlay = null;
  }

  @override
  void dispose() {
    // Make sure to remove OverlayEntry when the widget is disposed.
    removeLoadingOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
            return Future.delayed(Duration(seconds: 0),() {
            });
          },
        ),
      ),
    );

  }

  Card buildCard(int index, List<bool> expanded, dynamic data) {
    //String subtitleText = "NOT EXPANDED";
    print(data[index]['job_status']);
    Color? cardColor = Colors.lightBlue[100];
    return Card(
      child: ListTile(
        //leading: Icon(Icons.fire_truck_outlined, size: 50,),
        title: Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
          child: Column(
            children : [
              Text('${data[index]['first_name']} ${data[index]['last_name']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 25 ,fontWeight: FontWeight.bold),),
              buildDriverLicense_plate(data, index),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8.0, top: 4.0),
          child: buildSubstring(index, data),
        ),
        onTap: () {
          print("TAPPED ${index}");
          setState(() {
            expanded[index] = !expanded[index];
            //expanded[index]  == true ?  print("EXPANDED") : print("NOT EXPANDED");
          });
        },
        tileColor: cardColor,
      ),
    );
  }

  Text buildDriverLicense_plate(data, int index) {
    if (data[index]['trucks'] != null) {
      return Text(
        '${data[index]['trucks']['license_plate']}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),);
    } else {
      return Text(
        'No Vehicle Selected', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),);
    }
  }


  Column buildSubstring(int index, dynamic data) {
    if (expanded[index]  != true){
      return Column(
        children: [
          // Text("..."),
        ],
      );
    } else {
      return Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            //mainAxisAlignment: MainAxisAlignment.,
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child : Text('Distance', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('DISTACNCE FROM MERCHANT', style: TextStyle( fontSize: 15),), //todo: when location services are active
                      )
                  )
              ),
            ],
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.,
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child : Text('Contact Number', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['contactnumber']}', style: TextStyle( fontSize: 15)),
                      )
                  )
              ),
            ],
          ),
          Row(
            //mainAxisAlignment: MainAxisAlignment.,
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child : Text('Rating', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['average_rating']}', style: TextStyle( fontSize: 15)),
                      )
                  )
              ),
            ],
          ),
          if(data[index]['trucks'] != null) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  top: 8.0, bottom: 4.0),
              child: Text('Vehicle Details', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.,
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child : Text('Type of Truck', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child :  Text('${data[index]['trucks']['truck_type']}', style: TextStyle( fontSize: 15)),
                        )
                    )
                ),
              ],
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.,
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child : Text('Maximum Capacity (L)', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child :  Text('${data[index]['trucks']['space_capacity']}', style: TextStyle( fontSize: 15)),
                        )
                    )
                ),
              ],
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.,
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child : Text('Maximum Weight (KG)', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child :  Text('${data[index]['trucks']['weight_capacity']}', style: TextStyle( fontSize: 15)),
                        )
                    )
                ),
              ],
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.,
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child : Text('Cooling Available', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                        )
                    )
                ),

                if(data[index]['trucks']['cooling_capacity'] == true) ...[
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child : Text('Yes', style: TextStyle( fontSize: 15)),
                          )
                      )
                  ),
                ] else ...[
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child : Text('No', style: TextStyle( fontSize: 15)),
                          )
                      )
                  ),
                ],

              ],
            ),
          ],
        ],
      );
    }
  }
}
