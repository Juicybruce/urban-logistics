import 'package:flutter/material.dart';
import 'addPost.dart';

class newPost extends StatefulWidget {
  const newPost({Key? key}) : super(key: key);

  @override
  State<newPost> createState() => _newPostState();
}

class _newPostState extends State<newPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Current Jobs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return addPost();
                    //after adding a vehicle, refresh the truck list
                  }).then((value) => setState(() {}));
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Merchant New Post Screen'),
      ),
    );
  }
}
