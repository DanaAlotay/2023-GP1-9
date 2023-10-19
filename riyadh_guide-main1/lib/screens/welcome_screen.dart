import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomeScreen extends StatelessWidget {
  final List catNames = [
    "مقاهي",
    "مطاعم",
    "تسوق",
    "مراكز تجميل",
    "ترفيه",
    "معالم سياحية",
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
  /*
 List<String> catID =[];

   Future<List<String>> fetchDataFromFirestore() async {
    
  
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('category').get();

      for (QueryDocumentSnapshot document in snapshot.docs) {
        catID.add(document.id);
      }
    
      return catID;
      
   }
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
    String categoryID = 'c2';
    var str = <Widget>[
      ////
      Text(
        "آخر الأخبار",
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
          child: CarouselSlider(
        options: CarouselOptions(
          enlargeCenterPage: true,
          enableInfiniteScroll:
              true, // You can change this as per your requirements
          viewportFraction:
              0.65, // Adjust this value to control the visible portion of adjacent images
          aspectRatio:
              1.45, // Adjust this value to control the width-to-height ratio
        ),
        items: <Widget>[
          makeItem2(image: 'lib/icons/news1.jpeg', title: 'عرض مسرحي'),
          makeItem2(image: 'lib/icons/news2.jpeg', title: 'جروفز'),
          makeItem2(image: 'lib/icons/news3.jpeg', title: 'واجهة روشن'),
          // Add more items here as needed
        ],
      )),
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
                title: 'معالم سياحية',
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
                          " اهلًا ",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 33,
                              fontWeight: FontWeight.bold),
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
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                              hintText: "ابحث عن مكان..."),
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
makeItem2({image, title, isCenterItem = false}) {
  return GestureDetector(
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
}
