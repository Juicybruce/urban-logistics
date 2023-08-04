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

  //returns a list of jobs posted by merchants
  Future<Object> getJobs() async {
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Driver List Screen'),
      ),
    );
  }
}
