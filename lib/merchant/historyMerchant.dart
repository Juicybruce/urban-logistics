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
  late var expanded =  List<bool>.filled(testdata.length, false);
  late var substings =  List<String>.filled(testdata.length, "NOT EXPANDED");
  //String? email;
  String? userID;
  User? user;

  List<String> testdata = ["TEST1", "TEST2", "TEST3", "TEST4", "TEST5", "TEST6", "TEST7", "TEST8", "TEST9", "TEST10", "TEST11", "TEST12", "TEST13", "TEST14", "TEST15", "TEST16", "TEST17", "TEST18", "TEST19", "TEST20"];

  void initState() {
    isLoading = true;
    user = supabase.auth.currentUser;
    //email = user?.email;
    userID = user?.id;

    getHistory();
  }

  Future<void> getHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    var response = await supabase
        .from('advertisments')
        .select('*, suppliers!inner(supplier_id, email)')
        .eq('suppliers.supplier_id', userID)
        .or ('job_status.eq.COMPLETE, job_status.eq.CANCELLED');
    print(response);

    setState(() {
      isLoading = false;
    });
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
          child: ListView.builder(
            //padding: const EdgeInsets.all(8),
            itemCount: testdata.length,
            itemBuilder: (BuildContext context, int index) {
              return buildCard(index, expanded, substings);
            },
            //separatorBuilder: (BuildContext context, int index) => const Divider(),
          )
      ),
    );
  }

  Card buildCard(int index, List<bool> expanded, List<String> substings) {
    //String subtitleText = "NOT EXPANDED";
    var color = Colors.grey[200];
    expanded[index]  == true ? color = Colors.green[100] : color = Colors.red[100];
    expanded[index]  == true ?  substings[index] = "EXPANDED\n1\n2\n3\n4" : substings[index] = "NOT EXPANDED";
    return Card(
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 4.0),
                    child: Text('Entry ${testdata[index]}', textAlign: TextAlign.center,),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8.0, top: 4.0),
                    child: Text(substings[index]),
                  ),
                  onTap: () {
                    print("TAPPED ${index}");
                    setState(() {
                      expanded[index] = !expanded[index];
                      expanded[index]  == true ?  print("EXPANDED") : print("NOT EXPANDED");
                    });
                  },
                  tileColor: color,
                ),
            );
  }
}

