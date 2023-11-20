import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/adminEditPlace.dart';
import 'package:riyadh_guide/screens/place_detail.dart';
import 'package:riyadh_guide/widgets/Allplaces.dart';
import 'package:riyadh_guide/screens/AdminAddForm.dart';

class AdminPlaces extends StatefulWidget {
  @override
  _AdminPlaces createState() => _AdminPlaces();
}

class _AdminPlaces extends State<AdminPlaces> {
    @override
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
                             readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مكان',
                              border: InputBorder.none,
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
          ),
          Expanded(
            child: AllPlaces(), // Display places using the AllPlaces widget
          ),
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate{

  final List<String> placeList;
  CustomSearchDelegate(this.placeList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return[
      IconButton(
        onPressed: (){
          query ='';
        }, 
        icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: (){
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
    if(matchQuery.isEmpty)
         matchQuery.add('لا يوجد نتائج مطابقة');
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
    if(matchQuery.isEmpty)
         matchQuery.add('لا يوجد نتائج مطابقة');
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

