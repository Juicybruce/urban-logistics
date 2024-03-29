import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import '../navBar.dart';
import 'package:intl/intl.dart';

// list of avaliable jobs posted by merchant
class listDriver extends StatefulWidget {
  const listDriver({Key? key}) : super(key: key);

  @override
  State<listDriver> createState() => _listDriverState();
}

class _listDriverState extends State<listDriver> {
  bool isLoading = false; //if loading screen is displayed
  late List<bool> expanded; //list of bools, for displaying expanded information, or not
  String? userID; //user id
  User? user; //user details
  late List<dynamic>? dbdata; //data from the database

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    userID = user?.id;
    getHistory();
    super.initState();
  }

  //get jobs details from database
  Future<void> getHistory() async {
    await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('advertisments')
        .select('*, suppliers:supplier_id(first_name, last_name, business_name, contact_phone)')
        .eq ('job_status', 'POSTED')
        .order('pickup_time', ascending: false); //TODO: Order by job date or something like
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }

  //accept a job
  Future<void> acceptJob(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'driver_id':  userID, 'job_status':  'ACCEPTED'})
        .match({'job_id': jobID});
    getHistory();
  }

  //gets currently accepted jobs and checks if they conflict with the new job
  Future<bool> getJobs(DateTime start, DateTime end) async {
    final response = await supabase
        .from('advertisments')
        .select('pickup_time, delivery_time')
        .neq('job_status', 'CANCELLED')
        .neq('job_status', 'COMPLETE')
        .eq('driver_id', userID);
    if (response.length == 0) {
      return true;
    } else {
      int sJ = start.millisecondsSinceEpoch;
      int eJ = end.millisecondsSinceEpoch;
      for (dynamic time in response as List) {
        int sA = DateTime
            .parse(time['pickup_time'].toString())
            .millisecondsSinceEpoch;
        int eA = DateTime
            .parse(time['delivery_time'].toString())
            .millisecondsSinceEpoch;
        print(sA);
        print(eA);
        print(sJ);
        print(eJ);
        print('\n');

        if ((sA < sJ && sJ < eA) ||
            (sA < eJ && eJ < eA) ||
            (sJ < sA && sA < eJ) ||
            (sJ < eA && eA < eJ) ||
            (sA == sJ && eA == eJ)) { //test conditions to make sure it doesnt conflict
          return false;
        }
      }
      return true;
    }
  }


  OverlayEntry? overlay;
//display loading overlay
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

  //remove loading overlay
  void removeLoadingOverlay() {
    overlay?.remove();
    overlay = null;
  }

  //convert datetime to useable string
  String convertToDateTime(DateTime DT){
    return DateFormat('dd-MM-yyyy\nHH:mm').format(DT);
  }

  //dispose of overlay
  @override
  void dispose() {
    removeLoadingOverlay();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) { //show loading screen
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

//show available jobs
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

  //create cards for list items
  Card buildCard(int index, List<bool> expanded, dynamic data) {
    print(data[index]['job_status']);
    Color? cardColor = ColorConstants.driverListColor;
    Color? textColor = Colors.white;
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
                    children : [//show pickup date time
                      if (data[index]['pickup_time'] != null)...[
                        Text(convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textAlign: TextAlign.start, style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold, color: textColor),),
                      ]
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Column(
                  children : [ //show goods and pickup address
                    Text('${data[index]['goods_type']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 20 ,fontWeight: FontWeight.bold, color: textColor),),
                    Text('${data[index]['pickup_address']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 16 , color: textColor),),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Column(
                    children : [ //show job status
                      Text('${data[index]['job_status']}', textAlign: TextAlign.end, style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.bold, color: textColor),),
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
          setState(() { //if displaying expanded information or not
            expanded[index] = !expanded[index];
          });
        },
        tileColor: cardColor,
      ),
    );
  }

  //create expanded information string
  Column buildSubstring(int index, dynamic data) {
    if (expanded[index]  != true){
      return Column(
        children: [
        ],
      );
    } else {
      String cooling = "";
      cooling = data[index]['cooling_required'] == true ? "Yes" : "No";
      Color? textColor = Colors.white;
      return Column(
        children: [
          Divider( thickness: 1, color: textColor,),
          buildExpandedRow(data, index, 'Merchant Name', '${data[index]['suppliers']['first_name']} ${data[index]['suppliers']['last_name']}', textColor),
          buildExpandedRow(data, index, 'Business Name', data[index]['suppliers']['business_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Merchant Contact Number', data[index]['suppliers']['contact_phone'].toString(), textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Pickup Address', data[index]['pickup_address'].toString(), textColor),
          SizedBox(height: 5,),
          buildExpandedRow(data, index, 'Delivery Address', data[index]['dropoff_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Distance', "${data[index]['distance']} Km", textColor),
          if (data[index]['pickup_time'] != null)...[
            buildExpandedRow(data, index, 'Collection Time', convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textColor),
          ],
          SizedBox(height: 5,),
          if (data[index]['delivery_time'] != null)...[
            buildExpandedRow(data, index, 'Delivery Time', convertToDateTime(DateTime.parse(data[index]['delivery_time'].toString())), textColor),
          ],
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
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FittedBox(
                child: ElevatedButton( //create accept advertisement button
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => { showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Accept Advertisement"),
                        content: const Text("Are you sure you want to ACCEPT this advertisement?"),
                        actions: <Widget>[
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () async {
                                bool tempBool =  navBar.regoNumber == '' ? false : true;//getJobStatus('${data[index]['job_id']}', 'DELIVERED');
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
                                              Text('Unable to accept advertisment.'),
                                              Text('Please ensure you have a vehicle selected.'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Okay'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  bool res = await getJobs(DateTime.parse(data[index]['pickup_time'].toString()), DateTime.parse(data[index]['delivery_time'].toString()));
                                  print(res);
                                  if(res){
                                    setState(() {
                                      acceptJob('${data[index]['job_id']}');
                                      getHistory();
                                      print("IVE BEEN ACCEPTED");
                                    });
                                  } else {
                                    Future.delayed(Duration.zero, () => showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('CONFLICTING JOBS'),
                                          content: const SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text('You are unable to accept this advertisement.'),
                                                Text('You cannot accept advertisements that overlap with your currently accepted advertisements pickup-delivery times.'),
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
                                  }
                                  Navigator.of(context).pop();
                                }
                              }, child: const Text("Accept")),
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("Cancel")),
                        ],
                      )
                  )
                  },
                  child: Text("ACCEPT", textAlign: TextAlign.center, style: TextStyle( fontSize: 15 ,fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  //build row information for expanded card details
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