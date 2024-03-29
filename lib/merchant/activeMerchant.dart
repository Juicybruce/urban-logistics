import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

//shows a list of currently active jobs for the merchant
class activeMerchant extends StatefulWidget {
  const activeMerchant({Key? key}) : super(key: key);

  @override
  State<activeMerchant> createState() => _activeMerchantState();
}

class _activeMerchantState extends State<activeMerchant> {
  bool isLoading = false; //loading screen displayed
  late List<bool> expanded; //list of bools, for displaying expanded information, or not
  String? userID; //user  ID
  User? user; //User data
  late List<dynamic>? dbdata; //database data

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    userID = user?.id;

    getHistory();
    super.initState();
  }

  //get relevent data from the database
  Future<void> getHistory() async {
    await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('advertisments')
        .select('*, drivers:driver_id(driver_id, first_name, last_name, contactnumber)')
        .eq('supplier_id', userID)
        .eq('merchant_archived', false)
        .neq ('job_status', 'COMPLETE')
        .neq ('job_status', 'CANCELLED')
        .order('pickup_time', ascending: false); //TODO: Order by job date or something like
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }

  //cancel a job
  Future<void> CancelJob(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'job_status': 'CANCELLED'})
        .match({'job_id': jobID});
    getHistory();
  }

  //start a delivery
  Future<void> startDelivery(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'job_status':  'MERCHANT_START'})
        .match({'job_id': jobID});
    getHistory();
  }

  //confirm the delivery has been started
  Future<void> confirmStartDelivery(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'job_status':  'EN_ROUTE'})
        .match({'job_id': jobID});
    getHistory();
  }

  //confirm the delivery has ended
  Future<void> confirmEndDelivery(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'job_status':  'COMPLETE'})
        .match({'job_id': jobID});
    getHistory();
  }

  //get the status of the job
  Future<bool> getJobStatus(String jobID, String jobStatus) async {
    var response = await supabase
        .from('advertisments')
        .select('job_status')
        .eq('job_id', jobID);
    print(response[0]['job_status'] == jobStatus);
    return response[0]['job_status'] == jobStatus ?  true :  false;

  }

  OverlayEntry? overlay;
//show the loading overlay
  void loadingOverlay(){
    const String iconPath = 'assets/truck.svg';
    overlay = OverlayEntry(
        builder: (BuildContext context){
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

  //remove the loading overlay
  void removeLoadingOverlay() {
    overlay?.remove();
    overlay = null;
  }

  //dispose of the loading overlay
  @override
  void dispose() {
    removeLoadingOverlay();
    super.dispose();
  }

  //convert the datetime to a better format
  String convertToDateTime(DateTime DT){
    return DateFormat('dd-MM-yyyy\nHH:mm').format(DT);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) { //show the loading overlay
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

    //build the actual screen
    return Scaffold(
      body: Center( //
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

  //create a card
  Card buildCard(int index, List<bool> expanded, dynamic data) {
    print(data[index]['job_status']);
    Color? cardColor;
    Color? textColor;
    if (data[index]['job_status']  == 'POSTED' || data[index]['job_status']  == 'MERCHANT_START'){
      cardColor = ColorConstants.postedColor;
      textColor = Colors.white;
    }else if (data[index]['job_status']  == 'DRIVER_START' || data[index]['job_status']  == 'DELIVERED'){
      cardColor = ColorConstants.responseRequired;
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
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(
                    children : [
                      //pickup date and time displayed on card
                      Text(convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textAlign: TextAlign.start, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  children : [
                    //goods type and pick up address displayed on card
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
                      //job status displayed on card
                      if (data[index]['job_status'] == 'POSTED') ...[
                        Text('POSTED', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'ACCEPTED') ...[
                        Text('ACCEPTED', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'MERCHANT_START') ...[
                        Text('AWAITING\nRESPONSE', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'DRIVER_START') ...[
                        Text('RESPONSE\nREQUIRED', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'EN_ROUTE') ...[
                        Text('IN\nPROGRESS', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
                      ]else if (data[index]['job_status'] == 'DELIVERED') ...[
                        Text('CONFIRMATION\nREQUIRED', textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16 ,fontWeight: FontWeight.bold),),
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
          setState(() { //expand when tapped
            expanded[index] = !expanded[index];
          });
        },
        tileColor: cardColor,
      ),
    );
  }

//create substring (expaneded card details)
  Column buildSubstring(int index, dynamic data) {
    if (expanded[index]  != true){
      return Column(
        children: [
          // Text("..."),
        ],
      );
    } else {
      Color? textColor = data[index]['job_status']  == 'ACCEPTED' || data[index]['job_status']  == 'EN_ROUTE' ? Colors.black : Colors.white;
      String cooling = "";
      cooling = data[index]['cooling_required'] == true ?  "Yes" :  "No";

      return Column(
        children: [
          Divider( thickness: 1, color: textColor,),
          buildExpandedRow(data, index, 'Pickup Address', data[index]['pickup_address'].toString(), textColor),
          SizedBox(height: 5,),
          buildExpandedRow(data, index, 'Delivery Address', data[index]['dropoff_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Distance', "${data[index]['distance']} Km", textColor),
          buildExpandedRow(data, index, 'Collection Time', convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textColor),
          SizedBox(height: 5,),
          buildExpandedRow(data, index, 'Delivery Time', convertToDateTime(DateTime.parse(data[index]['delivery_time'].toString())), textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Goods', data[index]['goods_type'].toString(), textColor),
          buildExpandedRow(data, index, 'Quantity', "${data[index]['quantity']} Unit(s)", textColor),
          buildExpandedRow(data, index, 'Total Weight', "${data[index]['weight']} g", textColor),
          buildExpandedRow(data, index, 'Size', "${data[index]['size']} M³", textColor),
          buildExpandedRow(data, index, 'Cooling Required', cooling, textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Buyer Name', data[index]['contact_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Buyer Contact Number', data[index]['contact_number'].toString(), textColor),
          buildExpandedRow(data, index, 'Delivery Cost', "\$${data[index]['cost']}", textColor),
          if(data[index]['job_status'] != 'POSTED') ...[
            SizedBox(height: 10,),
            buildExpandedRow(data, index, 'Delivery Driver', '${data[index]['drivers']['first_name']} ${data[index]['drivers']['last_name']}', textColor),
            buildExpandedRow(data, index, 'Driver Contact Number', data[index]['drivers']['contactnumber'].toString(), textColor),
          ],
          SizedBox(
            height: 10,
          ),
          if(data[index]['job_status'] == 'POSTED') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  child: ElevatedButton( //create button to cancel advert
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Cancel Advertisement"),
                          content: const Text("Are you sure you want to cancel the selected Advertisement?"),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: (){
                                  Future<bool> tempBool = getJobStatus('${data[index]['job_id']}', 'POSTED');
                                  if(tempBool == false) {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('ERROR'),
                                          content: const SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('Unable to cancel Advertisement.'),
                                                Text('The selected Advertisement may have already been accepted.'),
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
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    loadingOverlay();
                                    setState(() {
                                      CancelJob('${data[index]['job_id']}');
                                    });
                                    print("IVE BEEN CANCELLED");
                                    Navigator.of(context).pop();
                                  }
                                }, child: const Text("Confirm")),

                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: const Text("Cancel")),
                          ],
                        )
                    )
                    },
                    child: Text("CANCEL ADVERTISEMENT", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else if (data[index]['job_status'] == 'ACCEPTED') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  child: ElevatedButton( //create button to start the delivery
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Start Delivery"),
                          content: const Text("Has the delivery driver picked up the goods?"),
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
                                                    Text('The selected Advertisement may have already started by the driver.'),
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
          ]else if (data[index]['job_status'] == 'DRIVER_START') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  //width: 100,
                  child: ElevatedButton( //create button to confirm the start of the delivery
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Confirm Start of Delivery"),
                          content: const Text("The Driver has started the delivery.\nHas the driver picked up the goods?"),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  bool tempBool = await getJobStatus('${data[index]['job_id']}', 'DRIVER_START');
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
          ] else if (data[index]['job_status'] == 'DELIVERED') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(
                  //width: 100,
                  child: ElevatedButton( //create button to view proof of delivery
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => { showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Proof of Delivery"),
                          content: Column(mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text("The Driver has delivered the goods.\nView the proof of delivery and confirm it has been delivered."),
                                const SizedBox(height: 10,),
                                const Text('Signee\'s Name', style: TextStyle(fontSize: 15 ,fontWeight: FontWeight.bold),),
                                Text(data[index]['signee_name'].toString(), style: TextStyle(fontSize: 15 ),),
                              ]),
                          actions: <Widget>[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  bool tempBool = await getJobStatus('${data[index]['job_id']}', 'DELIVERED');
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
                                    loadingOverlay();
                                    setState(() {
                                      confirmEndDelivery('${data[index]['job_id']}');
                                    });
                                    print("IVE BEEN FINISHED");
                                    Navigator.of(context).pop();
                                  }
                                }, child: const Text("Confirm")),

                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: const Text("Cancel")),
                          ],
                        )
                    )
                    },
                    child: Text("PROOF OF DELIVERY", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]
        ],
      );
    }
  }

  //build contents of each row in the expanded list
  Row buildExpandedRow(data, int index, String leftText, String rightText, Color textColor) {
    return Row(
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
