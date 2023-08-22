import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class historyDriver extends StatefulWidget {
  const historyDriver({Key? key}) : super(key: key);

  @override
  State<historyDriver> createState() => _historyDriverState();
}

class _historyDriverState extends State<historyDriver> {



  final User? user = supabase.auth.currentUser;
  final String? uid = supabase.auth.currentUser!.id;
  final String? uEmail = supabase.auth.currentUser!.email;
  final SupabaseClient _client = Supabase.instance.client;



  //initialise the state of the widget

  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    final Stream _future = Supabase.instance.client
        .from('advertisments')
    //select the data from the database
        .select()
        .eq('job_status', 'COMPLETE')
        //.or('CANCELLED')
        .eq('driver_id', uid)
        .asStream();

    return Scaffold(
      appBar: AppBar(
        title: const Text('List of completed Jobs'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: _future,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final List<dynamic> data = snapshot.data as List<dynamic>;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    //final job = data[index];
                    final Map<String, dynamic> job = data[index] as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(job['pickup_address'].toString()),
                        subtitle: Text(job['goods_type'].toString()),
                        trailing: Text(job['job_status'].toString()),
                        onTap: () {
                          // alert dialog to  show job details and accept job
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Job Details'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text('Job ID: ${job['job_id']}'),
                                      Text('Goods Type: ${job['goods_type']}'),
                                      Text('Pickup Address: ${job['pickup_address']}'),
                                      Text('Dropoff Address: ${job['dropoff_address']}'),
                                      Text('Pickup Date: ${job['pickup_date']}'),
                                      Text('Pickup Time: ${job['pickup_time']}'),
                                      Text('Dropoff Date: ${job['dropoff_date']}'),
                                      Text('Dropoff Time: ${job['dropoff_time']}'),
                                      Text('Job Status: ${job['job_status']}'),
                                      //    Text('Job Description: ' + job['job_description'].toString()),
                                      Text('Job Weight: ${job['weight']}'),
                                      Text('Job Volume: ${job['job_volume']}'),
                                      Text('Job Payment Image: ${job['job_payment_image']}'),
                                      Text('Job Payment Status: ${job['job_payment_status']}'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[

                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}
