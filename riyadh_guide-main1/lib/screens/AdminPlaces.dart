import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/adminEditPlace.dart';
import 'package:riyadh_guide/screens/adminHome.dart';
import 'package:riyadh_guide/screens/place_detail.dart';
import 'package:riyadh_guide/widgets/Allplaces.dart';
import 'package:riyadh_guide/screens/AdminAddForm.dart';

class AdminPlaces extends StatefulWidget {
  @override
  _AdminPlaces createState() => _AdminPlaces();
}

class _AdminPlaces extends State<AdminPlaces> {
  @override
  Color color = Color.fromARGB(255, 59, 52, 63);
  void initState() {
    super.initState();
    _fetchPlaceData();
  }

  final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('place');
  List<String> placeList = [];
  Future<void> _fetchPlaceData() async {
    FirebaseFirestore.instance.collection('place').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var name = doc.data()['name'];
        placeList.add(name);
      });
    });
  }

  String searchText = 'ابحث عن مكان';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اضافة- حذف - تعديل الاماكن'),
        backgroundColor: Color.fromARGB(255, 211, 198, 226),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAdminHomePage(),
              ),
            );
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Icon(
                          Icons.search,
                          color: const Color.fromARGB(255, 91, 91, 91),
                        ),
                        Container(
                          width: 210,
                          // Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مكان',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 8, 7),
                            ),
                            onTap: () {
                              showSearch(
                                context: context,
                                delegate: CustomSearchDelegate(placeList),
                              );
                            },
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
          /*
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPlaceForm(),// Handle "Add" action
                      ),
                    );
                    
                  },
                ),
              ),
            ],
          ),*/
          /*
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 10,),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 227, 248), // Box color
                  border: Border.all(color: Color.fromARGB(255, 97, 92, 92)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextButton.icon(
                  icon: Icon(Icons.add, color: Color.fromARGB(255, 97, 92, 92)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPlaceForm(), // Handle "Add" action
                      ),
                    );
                  },
                  label: Text('اضافة ',
                      style: TextStyle(color: Color.fromARGB(255, 97, 92, 92))),
                ),
              ),
              SizedBox(height: 15,),
            ],
          ),*/
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox.fromSize(
                size: Size(56, 56),
                child: ClipOval(
                  child: Material(
                    // color: Color.fromARGB(255, 211, 198, 226),
                    color: Color.fromARGB(255, 249, 240, 203),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPlaceForm(), // Handle "Add" action
                          ),
                        );
                      },
                      child: InkWell(
                        splashColor: Color.fromARGB(255, 59, 52, 63),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add, size: 40), // <-- Icon
                            //Text(  "اضافة",  style: TextStyle(fontWeight: FontWeight.bold),
                            // ), // <-- Text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AllPlaces(), // Display places using the AllPlaces widget
          ),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<String> placeList;
  CustomSearchDelegate(this.placeList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var placeName in placeList) {
      if (placeName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(placeName);
      }
    }
    if (matchQuery.isEmpty) matchQuery.add('لا يوجد نتائج مطابقة');
    Future<void> fetchPlaceDetails(String placeName) async {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('place')
            .where('name', isEqualTo: placeName)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final placeID = snapshot.docs.first['placeID'];
          // Do something with placeID, e.g., navigate to 'PlaceDetails' page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => adminEditPlace(placeID: placeID),
            ),
          );
        }
      } catch (e) {
        // Handle any errors that may occur during the Firebase query
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            fetchPlaceDetails(result);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var placeName in placeList) {
      if (placeName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(placeName);
      }
    }
    if (matchQuery.isEmpty) matchQuery.add('لا يوجد نتائج مطابقة');
    Future<void> fetchPlaceDetails(String placeName) async {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('place')
            .where('name', isEqualTo: placeName)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final placeID = snapshot.docs.first['placeID'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => adminEditPlace(placeID: placeID),
            ),
          );
        }
      } catch (e) {
        // Handle any errors that may occur during the Firebase query
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            fetchPlaceDetails(result);
          },
        );
      },
    );
  }
}
