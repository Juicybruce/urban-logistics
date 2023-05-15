import 'package:flutter/material.dart';

class newPost extends StatefulWidget {
  const newPost({Key? key}) : super(key: key);

  @override
  State<newPost> createState() => _newPostState();
}

class _newPostState extends State<newPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Merchant New Post"), centerTitle: true,),
      body: Center(
        child: Text('Merchant New Post Screen'),
      ),
    );
  }
}
