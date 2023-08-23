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
    await Future.delayed(const Duration(seconds: 1));
    var response = await supabase
        .from('advertisments')
        //.select('*, suppliers!inner(supplier_id, email)')
        .select()
        //.eq('suppliers.supplier_id', userID)
        .eq('supplier_id', userID)
        .or ('job_status.eq.COMPLETE, job_status.eq.CANCELLED');
    //.order('job_id', ascending: false); //TODO: Order by job date or something like
    //print(response);
    dbdata = response as List<dynamic>;
    expanded = List<bool>.filled(dbdata!.length, false);
    //print("TEST1  ${dbdata?[0]['job_status']}");
    print("TEST1  ${dbdata?[1]}");
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
    data[index]['job_status']  == 'COMPLETE' ? cardColor = Colors.greenAccent[200] : cardColor = Colors.redAccent[100];

    return Card(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
          child: Column(
            children : [
              Text('${data[index]['goods_type']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 25 ,fontWeight: FontWeight.bold),),
              Text('${data[index]['job_status']}', textAlign: TextAlign.center, style: TextStyle( fontSize: 18 ),),
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
        ],
      );
    }
  }
}

