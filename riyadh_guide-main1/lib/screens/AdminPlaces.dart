import 'package:flutter/material.dart';

class AdminPlaces extends StatefulWidget {
  @override
  _AdminPlaces createState() => _AdminPlaces();
}

class _AdminPlaces extends State<AdminPlaces> {
  String searchText = 'ابحث عن مكان';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اضافة- حذف - تعديل الاماكن'),
        backgroundColor: Colors.grey,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مكان',
                              border: InputBorder.none,
                            ),
                            onChanged: (String value) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('       '),
              SizedBox(height: 12.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 97, 92, 92)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Handle "Add" action
                  },
                ),
              ),
            ],
          ),
          Center(),
        ],
      ),
    );
  }
}
