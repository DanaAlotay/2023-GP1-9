import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/category.dart';

Widget cat = category();

class WelcomeScreen extends StatelessWidget {
  List catNames = [
    "مقاهي",
    "مطاعم",
    "تسوق",
    "مراكز تجميل",
    "ترفيه",
    "معالم سياحية",
  ];
//hello

  List<Color> catColors = [
    (Colors.white),
    (Color.fromARGB(255, 227, 208, 239)),
    (Color.fromARGB(255, 207, 159, 237)),
    (Colors.white),
    (Color.fromARGB(255, 227, 208, 239)),
    (Color.fromARGB(255, 207, 159, 237)),
  ];

  List<Icon> catIcons = [
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    return Column(
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
                                  builder: (context) => category()),
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
