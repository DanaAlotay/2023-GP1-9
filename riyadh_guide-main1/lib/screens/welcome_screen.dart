import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 8, 124),
      body: ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3.9,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/icons/bg.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Image.asset(
                        'lib/icons/rgLogo.png',
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 7.1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Text(
                    "أهلًا بك",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 25),
            width: MediaQuery.of(context).size.width / 3.2,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "...ابحث",
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Column(
              children: [
                GridView.builder(
                  itemCount: catNames.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 1.1),
                  itemBuilder: ((context, index) {
                    String categoryID = catID[index];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          InkWell(
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: catColors[index],
                                  shape: BoxShape.circle),
                              child: Center(
                                child: catIcons[index],
                              ),
                            ),
                            onTap: () {
                              // just for testing
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => category(categoryID: categoryID)),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            catNames[index],
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6)),
                          )
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
*/
  @override
  Widget build(BuildContext context) {
    String categoryID = 'c2';
    var str = <Widget>[
      Text(
        "التصنيفات",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 20),
      ),
      SizedBox(
        height: 20,
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
                categoryID: 'c4'),
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
        height: 80,
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
