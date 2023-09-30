import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class activeDriver extends StatefulWidget {
  const activeDriver({Key? key}) : super(key: key);

  @override
  State<activeDriver> createState() => _activeDriverState();
}

class _activeDriverState extends State<activeDriver> {
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

        .select('*, suppliers:supplier_id(supplier_id, first_name, last_name, business_name, contact_phone)')
        .eq('driver_id', userID)
        .eq('driver_archived', false)
        .neq ('job_status', 'COMPLETE')
        .neq ('job_status', 'CANCELLED')
        .order('pickup_time', ascending: false); //TODO: Order by job date or something like
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

  Future<void> CancelJob(String jobID) async {
    //await Future.delayed(const Duration(seconds: 0));
    await supabase
        .from('advertisments')
        .update({'merchant_archived':  true, 'job_status': 'CANCELLED'})
        .match({'job_id': jobID});
    getHistory();
  }

  Future<void> startDelivery(String jobID) async {
    //await Future.delayed(const Duration(seconds: 0));
    await supabase
        .from('advertisments')
        .update({'job_status':  'DRIVER_START'})
        .match({'job_id': jobID});
    getHistory();
  }

  Future<void> confirmStartDelivery(String jobID) async {
    //await Future.delayed(const Duration(seconds: 0));
    await supabase
        .from('advertisments')
        .update({'job_status':  'EN_ROUTE'})
        .match({'job_id': jobID});
    getHistory();
  }

  Future<void> confirmDelivery(String jobID, String name) async {
    //await Future.delayed(const Duration(seconds: 0));


    await supabase
        .from('advertisments')
        .update({'job_status':  'DELIVERED', 'signee_name': name})
        .match({'job_id': jobID});
    getHistory();
  }

  Future<bool> getJobStatus(String jobID, String jobStatus) async {
    //await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('advertisments')
        .select('job_status')
        .eq('job_id', jobID);
    print(response[0]['job_status'] == jobStatus);
    return response[0]['job_status'] == jobStatus ?  true :  false;

  }

  String convertToDateTime(DateTime DT){
      DT = DT.toLocal();
      return DateFormat('dd-MM-yyyy\nHH:mm').format(DT);
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
    Color? textColor;
    if (data[index]['job_status']  == 'DELIVERED' || data[index]['job_status']  == 'DRIVER_START'){
      cardColor = ColorConstants.postedColor;
      textColor = Colors.white;
    }else{
      cardColor = ColorConstants.inProgressColor;
      textColor = Colors.black;
    }

    return Card(
      child: ListTile(
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
                      if(data[index]['pickup_time'] != null) ...[
                        Text(convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textAlign: TextAlign.start, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),),
                      ]
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  children : [
                    Text('${data[index]['goods_type']}', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 20 ,fontWeight: FontWeight.bold),),
                    Text('${data[index]['pickup_address']}', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ),),
                  ],
                ),
              ),

              Flexible(

                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,

                  child: Column(

                    children : [
                      if (data[index]['job_status'] == 'ACCEPTED') ...[
                        Text('ACCEPTED', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'DRIVER_START' || data[index]['job_status'] == 'MERCHANT_START') ...[
                        Text('PENDING\nRESPONSE', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'EN_ROUTE') ...[
                        Text('IN\nPROGRESS', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'DELIVERED') ...[
                        Text('PENDING\nVERIFICATION', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]
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
      Color? textColor = data[index]['job_status']  == 'DELIVERED' || data[index]['job_status']  == 'DRIVER_START' ? Colors.white : Colors.black;
      String cooling = "";
      data[index]['cooling_required'] == 'TRUE' ? cooling = "Yes" : cooling = "No";

      return Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: 10,),
          Divider( thickness: 1, color: textColor,),
          buildExpandedRow(data, index, 'Merchant Name', '${data[index]['suppliers']['first_name']} ${data[index]['suppliers']['last_name']}', textColor),
          buildExpandedRow(data, index, 'Business Name', data[index]['suppliers']['business_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Merchant Contact Number', data[index]['suppliers']['contact_phone'].toString(), textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Pickup Address', data[index]['pickup_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Delivery Address', data[index]['dropoff_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Distance', data[index]['distance'].toString(), textColor),
    if(data[index]['pickup_time'] != null) ...[
          buildExpandedRow(data, index, 'Collection Time', convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textColor),
    ],
    if(data[index]['delivery_time'] != null) ...[
          buildExpandedRow(data, index, 'Delivery Time', convertToDateTime(DateTime.parse(data[index]['delivery_time'].toString())), textColor),
          ],
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Goods', data[index]['goods_type'].toString(), textColor),
          buildExpandedRow(data, index, 'Quantity', data[index]['quantity'].toString(), textColor),
          buildExpandedRow(data, index, 'Total Weight', data[index]['weight'].toString(), textColor),
          buildExpandedRow(data, index, 'Size', data[index]['size'].toString(), textColor),
          buildExpandedRow(data, index, 'Cooling Required', data[index]['${cooling}'].toString(), textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Buyer Name', data[index]['contact_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Buyer Contact Number', data[index]['contact_number'].toString(), textColor),
          buildExpandedRow(data, index, 'Delivery Cost', "\$${data[index]['cost']}", textColor),
          if(data[index]['job_status'] == 'DELIVERED') ...[
            SizedBox(
              height: 10,
            ),
          buildExpandedRow(data, index, 'Signee Name', data[index]['signee_name'].toString(), textColor),
          ],
          SizedBox(
            height: 10,
          ),

          if (data[index]['job_status'] == 'ACCEPTED') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  //width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Start Delivery"),
                          content: const Text("Have you picked up the goods?"),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                                onPressed: () async {
                                  bool tempBool = await getJobStatus('${data[index]['job_id']}', 'ACCEPTED');
                                  //print(tempBool);
                                  if(tempBool == false) {
                                    Future.delayed(Duration.zero, () =>
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('ERROR'),
                                              content: const SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Unable to start delivery.'),
                                                    Text('The selected Advertisement may have already started by the merchant.'),
                                                    Text('Please refresh and try again.'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Okay'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    print("IVE BEEN STARTED BY MERCHANT");
                                    loadingOverlay();
                                    setState(() {
                                      startDelivery('${data[index]['job_id']}');
                                    });

                                    Navigator.of(context).pop();
                                  }
                                }, child: const Text("Yes")),

                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: const Text("No")),
                          ],
                        )
                    )
                    },
                    child: Text("START DELIVERY", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]else if (data[index]['job_status'] == 'MERCHANT_START') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  //width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Confirm Start of Delivery"),
                          content: const Text("The Merchant has started the delivery.\nHave you picked up the goods?"),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  bool tempBool = await getJobStatus('${data[index]['job_id']}', 'MERCHANT_START');
                                  if(tempBool == false) {
                                    Future.delayed(Duration.zero, () =>
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('ERROR'),
                                              content: const SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Unable to confirm start of delivery.'),
                                                    //Text('The selected Advertisement may have already started by the driver.'),
                                                    Text('Please refresh and try again.'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Confirm'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    loadingOverlay();
                                    setState(() {
                                      confirmStartDelivery('${data[index]['job_id']}');
                                    });
                                    print("IVE BEEN CONFIRM STARTED");
                                    Navigator.of(context).pop();
                                  }
                                }, child: const Text("Yes")),

                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: const Text("No")),
                          ],
                        )
                    )
                    },
                    child: Text("CONFIRM START OF DELIVERY", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else if (data[index]['job_status'] == 'EN_ROUTE') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  //width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("COMPLETE DELIVERY"),
                          content: const Text("Are you ready to attach proof of delivery and complete this advertisement?"),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  bool tempBool = await getJobStatus('${data[index]['job_id']}', 'EN_ROUTE');
                                  if(tempBool == false) {
                                    Future.delayed(Duration.zero, () =>
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('ERROR'),
                                              content: const SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text('Unable to confirm delivery of goods.'),
                                                    //Text('The selected Advertisement may have already started by the driver.'),
                                                    Text('Please refresh and try again.'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Okay'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    TextEditingController _signeeName = TextEditingController();
                                    Future.delayed(Duration.zero, () =>
                                        showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        title: const Text('PROOF OF DELIVERY'),
                                        content: Column(mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                          const Text('Confirm and enter details below'),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        child : Text('Buyer Name', style: TextStyle(color: textColor, fontSize: 15 ,fontWeight: FontWeight.bold),),
                                                      )
                                                  )
                                              ),
                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Container(
                                                        child :  Text(data[index]['suppliers']['buyer_name'].toString(), style: TextStyle(color: textColor, fontSize: 15)),
                                                      )
                                                  )
                                              ),
                                            ],
                                          ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Container(
                                                            child : Text('Delivery Address', style: TextStyle(color: textColor, fontSize: 15 ,fontWeight: FontWeight.bold),),
                                                          )
                                                      )
                                                  ),
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Container(
                                                            child :  Text(data[index]['dropoff_address'].toString(), style: TextStyle(color: textColor, fontSize: 15)),
                                                          )
                                                      )
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Container(
                                                            child : Text('Goods', style: TextStyle(color: textColor, fontSize: 15 ,fontWeight: FontWeight.bold),),
                                                          )
                                                      )
                                                  ),
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Container(
                                                            child :  Text(data[index]['goods_type'].toString(), style: TextStyle(color: textColor, fontSize: 15)),
                                                          )
                                                      )
                                                  ),
                                                ],
                                              ),
                                              Text('Signee\'s Name', style: TextStyle(color: textColor, fontSize: 15 ,fontWeight: FontWeight.bold),),
                                              TextField(
                                                controller: _signeeName,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: 'Person accepting delivery',
                                                ),
                                              ),
                                        ]),
                                        actions: <Widget>[
                                          ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () {
                                            if (_signeeName.text == ""){
                                              print("ERROR");
                                            }else{
                                              loadingOverlay();
                                              confirmDelivery('${data[index]['job_id']}', _signeeName.text);
                                              print(_signeeName.text);
                                              Navigator.of(context).pop();
                                            }
                                          },

                                          child: const Text('Confirm'),
                                        ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),

                                        ],
                                      ),
                                        )
                                    );
                                    //loadingOverlay();

                                    print("IVE BEEN FINISHED");
                                    Navigator.of(context).pop();
                                  }
                                }, child: const Text("YES")),

                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: const Text("NO")),
                          ],
                        )
                    )
                    },
                    child: Text("FINISH DELIVERY", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]
        ],
      );
    }
  }

  Row buildExpandedRow(data, int index, String leftText, String rightText, Color textColor) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.,
      children: <Widget>[
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child : Text(leftText, style: TextStyle(color: textColor, fontSize: 15 ,fontWeight: FontWeight.bold),),
                )
            )
        ),
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child :  Text(rightText, style: TextStyle(color: textColor, fontSize: 15)),
                )
            )
        ),
      ],
    );
  }
}
