import 'package:flutter/material.dart';
import 'package:supabase/src/supabase_stream_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class activeMerchant extends StatefulWidget {
  const activeMerchant({Key? key}) : super(key: key);

  @override
  State<activeMerchant> createState() => _activeMerchantState();
}

class _activeMerchantState extends State<activeMerchant> {
  String userID = ''; // This will hold the userID once obtained

  @override
  void initState() {
    super.initState();
    _fetchUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Jobs'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: supabase
                  .from('advertisments')
                  .select()
                  .eq('supplier_id', userID)
                  .in_('job_status', ['POSTED', 'AWAITING_PICKUP', 'EN_ROUTE'])
                  .execute()
                  .asStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<PostgrestResponse> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  final List<dynamic> data =
                      snapshot.data!.data as List<dynamic>;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> job =
                          data[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(job['goods_type'].toString()),
                        subtitle: Text(job['pickup_address'].toString()),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserID() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      setState(() {
        userID = currentUser.id;
      });
    }
  }
}
