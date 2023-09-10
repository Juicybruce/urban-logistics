import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class historyMerchant extends StatefulWidget {
  const historyMerchant({Key? key}) : super(key: key);

  @override
  State<historyMerchant> createState() => _historyMerchantState();
}

class _historyMerchantState extends State<historyMerchant> {
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

    getHistory();
    super.initState();
  }

  Future<void> getHistory() async {
    await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('advertisments')
    //.select('*, drivers!leftouter(first_name, last_name, contactnumber)')
        .select('*, drivers:driver_id(driver_id, first_name, last_name, contactnumber)')
    //.eq('drivers.driver_id', 'driver_id')
        .eq('supplier_id', userID)
        .eq('merchant_archived', false)
        .or ('job_status.eq.COMPLETE, job_status.eq.CANCELLED')
        .order('pickup_time', ascending: true); //TODO: Order by job date or something like
    //print(response[0]["drivers"]["first_name"]);
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    //print("TEST1  ${dbdata?[0]['job_status']}");
    //print("TEST1  ${dbdata?[1]}");
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }

  Future<void> removeFromHistory(String jobID) async {
    //await Future.delayed(const Duration(seconds: 0));
    await supabase
        .from('advertisments')
        .update({'merchant_archived':  true})
        .match({'job_id': jobID});
    getHistory();
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
    }

    return Scaffold(
      body: Center(
        child: RefreshIndicator(
          edgeOffset: -100,
          displacement: 50,
          child: ListView.builder(
            //padding: const EdgeInsets.all(8),

            itemCount: dbdata?.length,
            itemBuilder: (BuildContext context, int index) {
              return buildCard(index, expanded, dbdata);
            },
            physics: const AlwaysScrollableScrollPhysics(),
            //separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
          onRefresh: () async {
            loadingOverlay();
            setState(() {
              getHistory();
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
    Color? cardColor;
    data[index]['job_status']  == 'COMPLETE' ? cardColor = ColorConstants.completeColor: cardColor = ColorConstants.cancelledColor;
    return Card(
      child: ListTile(
        // leading: Text('${data[index]['pickup_time']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 18 ),),
        //trailing: Text('${data[index]['job_status']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 18 ),),
        title: Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(
                    children : [
                      //Text('${data[index]['pickup_time']}', textAlign: TextAlign.start, style: TextStyle( fontSize: 14 ),),
                      Text('DD/MM/YYYY\nHH:MM AA', textAlign: TextAlign.start, style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  children : [
                    Text('${data[index]['goods_type']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 20 ,fontWeight: FontWeight.bold),),
                    Text('${data[index]['pickup_address']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 16 ),),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(
                    children : [
                      Text('${data[index]['job_status']}', textAlign: TextAlign.end, style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 2.0, top: 2.0),
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

  Column buildSubstring(int index, dynamic data) {
    if (expanded[index]  != true){
      return Column(
        children: [
          // Text("..."),
        ],
      );
    } else {
      String cooling = "";
      data[index]['cooling_required'] == 'TRUE' ? cooling = "Yes" : cooling = "No";

      return Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),

          Row(
            //mainAxisAlignment: MainAxisAlignment.,
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child : Text('Pickup Address', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['pickup_address']}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Delivery Address', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['dropoff_address']}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Distance', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['distance']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Collection Time', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['pickup_time']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Delivery Time', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['delivery_time']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Goods', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['goods_type']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Quantity', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['quantity']}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Total Weight', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['weight']}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Size', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['size']}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Cooling Required', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${cooling}', style: TextStyle( fontSize: 15)),
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
                        child : Text('Buyer Name', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['contact_name']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Buyer Contact Number', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['contact_number']}', style: TextStyle( fontSize: 15),),
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
                        child : Text('Delivery Cost', style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold),),
                      )
                  )
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child :  Text('${data[index]['cost']}', style: TextStyle( fontSize: 15),),
                      )
                  )
              ),
            ],
          ),
          if(data[index]['driver_id'] != null) ...[
            Row(
              //mainAxisAlignment: MainAxisAlignment.,
              children: <Widget>[
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text('Delivery Driver', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text('${data[index]['drivers']['first_name']} ${data[index]['drivers']['last_name']}',
                            style: TextStyle(fontSize: 15),),
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
                          child: Text('Driver Contact Number',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text('${data[index]['drivers']['contactnumber']}',
                            style: TextStyle(fontSize: 15),),
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
                          child: Text('Signee\'s Name',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text('${data[index]['signee_name']}',
                            style: TextStyle(fontSize: 15),),
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
                          child: Text('Confirmation Photo',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text('A PHOTO',
                            style: TextStyle(fontSize: 15),),
                        )
                    )
                ),
              ],
            ),

          ],
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FittedBox(
                //width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => { showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Remove from History"),
                        content: const Text("Are you sure you want to remove the selected item from your History?"),
                        actions: <Widget>[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: (){
                                loadingOverlay();
                                setState(() {
                                  removeFromHistory('${data[index]['job_id']}');
                                  // getHistory();
                                });
                                print("IVE BEEN REMOVED");
                                Navigator.of(context).pop();
                              }, child: const Text("Confirm")),

                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("Cancel")),
                        ],
                      )
                  )
                  },
                  child: Text("REMOVE FROM HISTORY", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}

