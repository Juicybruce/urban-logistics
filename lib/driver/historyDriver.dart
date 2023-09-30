import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class historyDriver extends StatefulWidget {
  const historyDriver({Key? key}) : super(key: key);

  @override
  State<historyDriver> createState() => _historyDriverState();
}

class _historyDriverState extends State<historyDriver> {
  bool isLoading = false;
  late List<bool> expanded;
  String? userID;
  User? user;
  late List<dynamic>? dbdata;

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    userID = user?.id;

    getHistory();
    super.initState();
  }

  Future<void> getHistory() async {
    await Future.delayed(const Duration(seconds: 0));
    var response = await supabase
        .from('advertisments')

        .select('*, suppliers:supplier_id(first_name, last_name, business_name, contact_phone)')
        .eq('driver_id', userID)
        .eq('driver_archived', false)
        .or ('job_status.eq.COMPLETE')
        .order('pickup_time', ascending: false); //TODO: Order by job date or something like
   print(response);
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    setState(() {
      isLoading = false;
    });
    removeLoadingOverlay();
  }

  Future<void> removeFromHistory(String jobID) async {
    await supabase
        .from('advertisments')
        .update({'driver_archived':  true})
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

  String convertToDateTime(DateTime DT){
    DT = DT.toLocal();
    return DateFormat('dd-MM-yyyy\nHH:mm').format(DT);
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
    Color? cardColor = ColorConstants.completeColor;
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
                      //Text('${data[index]['pickup_time']}', textAlign: TextAlign.start, style: TextStyle( fontSize: 14 ),),
                      Text(convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textAlign: TextAlign.start, style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold),),
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
        ],
      );
    } else {
      String cooling = "";
      data[index]['cooling_required'] == 'TRUE' ? cooling = "Yes" : cooling = "No";
      Color? textColor = data[index]['job_status']  == 'COMPLETE' ? Colors.black : Colors.black;
      return Column(
        children: [
          //SizedBox(height: 10,),
          Divider( thickness: 1, color: Colors.black,),
          buildExpandedRow(data, index, 'Merchant Name', '${data[index]['suppliers']['first_name']} ${data[index]['suppliers']['last_name']}', textColor),
          buildExpandedRow(data, index, 'Business Name', data[index]['suppliers']['business_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Merchant Contact Number', data[index]['suppliers']['contact_phone'].toString(), textColor),
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Pickup Address', data[index]['pickup_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Delivery Address', data[index]['dropoff_address'].toString(), textColor),
          buildExpandedRow(data, index, 'Distance', data[index]['distance'].toString(), textColor),
          buildExpandedRow(data, index, 'Collection Time', convertToDateTime(DateTime.parse(data[index]['pickup_time'].toString())), textColor),
          buildExpandedRow(data, index, 'Delivery Time', convertToDateTime(DateTime.parse(data[index]['delivery_time'].toString())), textColor),
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
          SizedBox(height: 10,),
          buildExpandedRow(data, index, 'Signee\'s Name', data[index]['signee_name'].toString(), textColor),
          buildExpandedRow(data, index, 'Confirmation Photo', 'A PHOTO', textColor),
          SizedBox(height: 10,),
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