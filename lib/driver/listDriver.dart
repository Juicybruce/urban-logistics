import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

class listDriver extends StatefulWidget {
  const listDriver({Key? key}) : super(key: key);

  @override
  State<listDriver> createState() => _listDriverState();
}
// list of avaliable jobs posted by merchant

class _listDriverState extends State<listDriver> {

  final User? user = supabase.auth.currentUser;
  final String? uid = supabase.auth.currentUser!.id;
  final String? uEmail = supabase.auth.currentUser!.email;
  final SupabaseClient _client = Supabase.instance.client;
  final Stream _future = Supabase.instance.client
      .from('advertisments')
  //select the data from the database
      .select()
      .eq('job_status', 'POSTED')
      .asStream();

  //returns a list of jobs posted by merchants
  /*Future<Object> getJobs() async {
    final response = await _client
        .from('advertisments')
        .select()
        .eq('job_status', 'POSTED')
        .execute();

    if (response == null) {
      return response.data as List<dynamic>;
    } else {
      return Exception('Failed to load jobs');
    }
  }*/

  //initialise the state of the widget

  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Jobs'),
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
                        title: Text(job['job_title'].toString()),
                        subtitle: Text(job['job_description'].toString()),
                        trailing: Text(job['job_status'].toString()),
                        onTap: () {
                          Navigator.pushNamed(context, '/jobDetails',
                              arguments: job);
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
