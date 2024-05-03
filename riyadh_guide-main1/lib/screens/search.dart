import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/place_detail.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';


class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  bool isFavorite = false;
  int currentTab=2;
    final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('place');
      List<String> placeList = [];
      
    String getCurrentUserID() {
    String currentUserId = '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      currentUserId = user.uid;
    }

    return currentUserId;
  }

  void addToFavorites(String placeID) {
 
  String userID = getCurrentUserID(); 
  
  // Add the place to favorites
  FirebaseFirestore.instance
      .collection('favorites')
      .doc(userID)
      .collection('place')
      .doc(placeID)
      .set({
        'placeID': placeID,
      })
      .then((value) {
        
          ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('تم إضافة المكان للمفضلة'),
              backgroundColor: Color.fromARGB(181, 203, 145, 210),
            ),
          )
          .closed;
      });
}

Future<bool> checkIfPlaceIsInFavorites(String placeID) async {
  String userID = getCurrentUserID();
  
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(userID)
        .collection('place')
        .doc(placeID)
        .get();
    
    return snapshot.exists;
  } catch (e) {
    print('Error checking favorites: $e');
    return false; 
  }
}

void removeFromFavorites(String placeID) {
  String userID = getCurrentUserID(); 
  
  FirebaseFirestore.instance
      .collection('favorites')
      .doc(userID)
      .collection('place')
      .doc(placeID)
      .delete()
      .then((value) {

        ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('تم إزالة المكان من المفضلة'),
              backgroundColor: Color.fromARGB(181, 203, 145, 210),
            ),
          )
          .closed;
      });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('البحث'),
          backgroundColor: Color.fromARGB(255, 211, 198, 226),
          automaticallyImplyLeading: false,
           leading: IconButton(
            onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(placeList),
              );
            },
           icon: const Icon(Icons.search),
            ),
          ),
        
      body: FutureBuilder<QuerySnapshot>(
        future: placesCollection
            .get(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found for this category.'));
          }

          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot placeDocument = snapshot.data!.docs[index];
                String placeName = placeDocument.get('name').toString();
                String classification = placeDocument.get('classification').toString();
                String classText ='';
                String face = '';
                     if (classification == "1") {
                      classText = 'ممتاز';
                      face = 'lib/icons/happiness.png';
                      } else if (classification == "2") {
                      classText = 'جيد';
                      face = 'lib/icons/neutral (1).png';
                      } else if (classification == "3") {
                      classText = 'سيء';
                      face = 'lib/icons/sad.png';
                      } else {
                       classText = 'لم يحدد بعد';
                       face = 'lib/icons/empty-set.png';
                      }
                String placeID = placeDocument.get('placeID').toString();
                List<dynamic> imageArray = placeDocument.get('images') ?? [];
                String placeImage = (imageArray.isNotEmpty) ? imageArray[0].toString() : '';
               // String placeImage = placeDocument.get('image').toString();
                String openingHours =
                    placeDocument.get('opening_hours').toString();
                    placeList.add(placeName);
                    CustomSearchDelegate customSearchDelegate = CustomSearchDelegate(placeList);
                    

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetails(placeID: placeID),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 7,
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                placeImage,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: 250,
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    Colors.black.withOpacity(0.8)
                                  ],
                                  stops: [0.6, 1],
                                ),
                              ),
                              child: Text(
                                placeName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            if(getCurrentUserID() !='')
                            Positioned(
                              top: 8.0,
                              right: 8.0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(27),
                                  onTap: () async {
                                    bool isInFavorites = await checkIfPlaceIsInFavorites(placeID);
                                    if (isInFavorites) {
                                      removeFromFavorites(placeID);
                                    } else {
                                      addToFavorites(placeID);
                                    }
                                    // Update the UI immediately
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 255, 255, 255), // Placeholder color for the filled heart icon
                                    ),
                                    child: FutureBuilder<bool>(
                                      future: checkIfPlaceIsInFavorites(placeID),
                                      builder: (context, snapshot) {
                                        final bool isInFavorites = snapshot.data ?? false;
                                        return Icon(
                                          isInFavorites ? Icons.favorite : Icons.favorite_border,
                                          color: isInFavorites ? Color.fromARGB(255, 250, 2, 2) : Color.fromARGB(255, 110, 22, 187),
                                          size: 27,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                  size: 27,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlaceDetails(placeID: placeID),
                                    ),
                                  );
                                },
                              ),
                              Text(
                                "للمزيد",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 15,),
                              Image.asset(
                            face,
                            width: 20,
                            height: 20,
                          ),
                              
                              Text(
                                classText,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 15,),
                              Icon(
                                Icons.schedule,
                                color: Colors.blue,
                                size: 20,
                              ),
                              Text(
                                openingHours,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
                      currentTab = 0;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomeScreen(),
                      ),
                    );
                    });
        },
        child: Image.asset(
                        'lib/icons/Logo.png',
                      ),
        backgroundColor: Color.fromARGB(157, 165, 138, 182),
        elevation: 20.0,
        //mini: true,
         ),
      bottomNavigationBar: BottomAppBar(
          notchMargin: 10,
          shape: CircularNotchedRectangle(),
          color:Color.fromARGB(157, 217, 197, 230),
          child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           mainAxisSize: MainAxisSize.max, 
           children: [
            
             Padding(
            padding: EdgeInsets.only(right: 10.0, left: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.account_box), onPressed: (){setState(() {
                      currentTab = 1;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => account(),
                      ),
                    );
                    });},
                  color: currentTab == 1 ? Colors.white : Colors.black,
                  
                ),
                Text(
                  "حسابي",
                  style: TextStyle(color:currentTab == 1 ? Colors.white : Colors.black),
                )
              ],
            ),
            ),

             Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.search), onPressed: (){ 
                    setState(() {
                      currentTab = 2;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => search(),
                      ),
                    );
                    });
                  },
                  color: currentTab == 2 ? Colors.white : Colors.black,
                  
                ),
                Text(
                  "البحث",
                  style: TextStyle(color:currentTab == 2 ? Colors.white : Colors.black),
                )
              ],
            ),
            ),

  Padding(
            padding: const EdgeInsets.only( right: 30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.newspaper), onPressed: (){setState(() {
                      currentTab = 3;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => news(),
                      ),
                    );
                    });},
                  color: currentTab == 3 ? Colors.white : Colors.black,
                  
                ),
                Text(
                  "أحداث اليوم",
                  style: TextStyle(color:currentTab == 3 ? Colors.white : Colors.black),
                )
              ],
            ),
            ),

            Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite), onPressed: (){
                    setState(() {
                      currentTab = 4;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => favourites(),
                      ),
                    );
                    });},
                  color: currentTab == 4 ? Colors.white : Colors.black,
                  
                ),
                Text(
                  "المفضلة",
                  style: TextStyle(color: currentTab == 4 ? Colors.white : Colors.black),
                )
              ],
            ),
            ),
           ],
          ),
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
          builder: (context) => PlaceDetails(placeID: placeID),
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
          builder: (context) => PlaceDetails(placeID: placeID),
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