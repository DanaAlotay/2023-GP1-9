import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:riyadh_guide/screens/eventDetails.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  //final TextEditingController searchController = TextEditingController();
  int currentTab = 0;
  String username = '';
  List<Map<String, dynamic>?> eventList = [];

  // Get the current user
  void fetchUserName() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          username = documentSnapshot['name'];
        }
      }).catchError((error) {
        // Handle error retrieving user data
      });
    }
  }

  List<String> placeList = [];
  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchPlaceNames().then((names) {
      setState(() {
        placeList = names;
      });
    });
    fetchEventsThisWeek().then((events) {
      setState(() {
        eventList = events;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchEventsThisWeek() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek =
        DateTime(now.year, now.month, now.day - now.weekday + 1, 0, 0, 0, 0);
    DateTime endOfWeek = DateTime(
        now.year, now.month, now.day - now.weekday + 7, 23, 59, 59, 999);

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('event')
        .where('start_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('start_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
        .get();

    List<Map<String, dynamic>> events = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()!;
      data['start_date'] = (data['start_date'] as Timestamp).toDate();
      data['eventId'] = doc.id; // Store the document ID separately
      return data;
    }).toList();

    return events;
  }

  Future<List<String>> fetchPlaceNames() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('place').get();
      querySnapshot.docs.forEach((doc) {
        final name = doc.get('name').toString();
        placeList.add(name);
      });
    } catch (e) {
      print('Error fetching place names: $e');
    }

    return placeList;
  }

  final List catNames = [
    "مقاهي",
    "مطاعم",
    "تسوق",
    "مراكز تجميل",
    "ترفيه",
    "أماكن سياحية",
  ];

  /*final List catID = [
    "c2",
    "c1",
    "c3",
    "c4",
    "c5",
    "c6",
  ];
*/
  final List<Color> catColors = [
    (Colors.white),
    (Color.fromARGB(255, 227, 208, 239)),
    (Color.fromARGB(255, 207, 159, 237)),
    (Colors.white),
    (Color.fromARGB(255, 227, 208, 239)),
    (Color.fromARGB(255, 207, 159, 237)),
  ];

  final List<Icon> catIcons = [
    Icon(
      Icons.local_cafe,
      color: Colors.black,
      size: 40,
    ),
    Icon(
      Icons.restaurant,
      color: Colors.black,
      size: 40,
    ),
    Icon(
      Icons.shopping_basket,
      color: Colors.black,
      size: 40,
    ),
    Icon(
      Icons.brush,
      color: Colors.black,
      size: 40,
    ),
    Icon(
      Icons.celebration,
      color: Colors.black,
      size: 40,
    ),
    Icon(
      Icons.attractions,
      color: Colors.black,
      size: 40,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    String categoryID = '';
    var str = <Widget>[
      Text(
        "يحدث هذا الأسبوع ",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          fontSize: 20,
        ),
      ),
      SizedBox(
        height: 15,
      ),
      //Start news
      Container(
        child: eventList.length == 1
            ? makeItem2(
                image: eventList[0]?['images'][0] as String,
                title: eventList[0]?['name'] as String,
                context: context,
                eventId: eventList[0]?['eventId'] as String,
              )
            : CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.65,
                  aspectRatio: 1.45,
                ),
                items: eventList.map((event) {
                  List<dynamic>? images = event?['images'] as List<dynamic>?;

                  return makeItem2(
                    image: (images != null && images.isNotEmpty)
                        ? images[0] as String
                        : '',
                    title: event?['name'] as String? ?? '',
                    context: context,
                    eventId: event?['eventId'] as String?,
                  );
                }).toList(),
              ),
      ),
      // End News
      SizedBox(
        height: 30,
      ),
      Text(
        "التصنيفات",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 20),
      ),
      SizedBox(
        height: 15,
      ),
      Container(
        height: 200,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            makeItem(
                image: 'lib/icons/Co.jpeg',
                title: 'مقاهي',
                context: context,
                categoryID: 'c2'),
            makeItem(
                image: 'lib/icons/Rs.jpeg',
                title: 'مطاعم',
                context: context,
                categoryID: 'c1'),
            makeItem(
                image: 'lib/icons/shop.jpeg',
                title: 'تسوق',
                context: context,
                categoryID: 'c3'),
            makeItem(
                image: 'lib/icons/tourist.jpeg',
                title: 'أماكن سياحية',
                context: context,
                categoryID: 'c6'),
            makeItem(
                image: 'lib/icons/Entertain.jpeg',
                title: 'ترفيه',
                context: context,
                categoryID: 'c5'),
            makeItem(
                image: 'lib/icons/beauty.jpeg',
                title: 'مراكز تجميل',
                context: context,
                categoryID: 'c4'),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        height: 30,
      ),
    ];
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
        color: Color.fromARGB(157, 217, 197, 230),
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
                    icon: Icon(Icons.account_box),
                    onPressed: () {
                      setState(() {
                        currentTab = 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => account(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 1 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "حسابي",
                    style: TextStyle(
                        color: currentTab == 1 ? Colors.white : Colors.black),
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
                    icon: Icon(Icons.search),
                    onPressed: () {
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
                    style: TextStyle(
                        color: currentTab == 2 ? Colors.white : Colors.black),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.newspaper),
                    onPressed: () {
                      setState(() {
                        currentTab = 3;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => news(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 3 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "أحداث اليوم",
                    style: TextStyle(
                        color: currentTab == 3 ? Colors.white : Colors.black),
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
                    icon: Icon(Icons.favorite),
                    onPressed: () {
                      setState(() {
                        currentTab = 4;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => favourites(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 4 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "المفضلة",
                    style: TextStyle(
                        color: currentTab == 4 ? Colors.white : Colors.black),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('lib/icons/Bk.jpg'), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Text(
                          " أهلًا " + username,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: TextField(
                          //controller: searchController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 15),
                            hintText: "ابحث عن مكان...",
                          ),

                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(placeList),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: str,
              ),
            )
          ],
        ),
      ),
    );
  }

  makeItem({image, title, context, categoryID}) {
    int Index = 0;
    String categoryi = categoryID;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => category(categoryID: categoryi)),
        );
      },
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: Container(
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image:
                  DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//class news
/*makeItem2({image, title, isCenterItem = false, context, eventId}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => eventDetails(eventID: eventId),
        ),
      );
    },
    child: AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              if (!isCenterItem)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color
                  spreadRadius: 0.5, // Spread radius
                  blurRadius: 5, // Blur radius
                  offset: isCenterItem
                      ? Offset(0, 0) // No shadow for the center item
                      : Offset(0, 3), // Shadow offset for left and right items
                ),
            ],
            borderRadius: BorderRadius.circular(20),
            image:
                DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
        child: ClipRRect(
          //Clip the child with a circular border radius
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    ),
  );

*/

Widget makeItem2({
  required dynamic image,
  required dynamic title,
  dynamic isCenterItem = false,
  required BuildContext context,
  required dynamic eventId,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => eventDetails(eventID: eventId),
        ),
      );
    },
    child: AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (!isCenterItem)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0.5,
                blurRadius: 5,
                offset: isCenterItem ? Offset(0, 0) : Offset(0, 3),
              ),
          ],
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
