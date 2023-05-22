import 'package:flutter/material.dart';

import 'model.dart';

class historyDriver extends StatefulWidget {
  const historyDriver({Key? key}) : super(key: key);

  @override
  State<historyDriver> createState() => _historyDriverState();
}

class _historyDriverState extends State<historyDriver> {
  List<Item> itemList = [
    Item(
        distance: 'Date/Time Completed',
        address: 'Job Address',
        details: 'Job Details',
        isAccept: true,
        title: 'Ad Title'),
    Item(
        distance: 'Date/Time Completed',
        address: 'Job Address',
        details: 'Job Details',
        isAccept: false,
        title: 'Ad Title'),

    Item(
        distance: 'Date/Time Completed',
        address: 'Job Address',
        details: 'Job Details',
        isAccept: false,
        title: 'Ad Title'),

    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: SizedBox(
                        width: 200.0,
                        child: Center(
                          child: Text(
                            itemList[index].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemList[index].distance,
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              itemList[index].address,
                              style: TextStyle(color: Colors.black),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              itemList[index].details,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (itemList[index].isAccept == true)
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.arrow_drop_down_sharp)),
                        if (itemList[index].isAccept == false)
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.arrow_drop_up)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
          ;
        },
      ),
    );
  }
}
