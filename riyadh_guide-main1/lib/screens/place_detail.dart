import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetails extends StatefulWidget {
  final String placeID;

  const PlaceDetails({Key? key, required this.placeID}) : super(key: key);

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  int currentTab=0;

  late DocumentSnapshot? placeData;
  List<String> imageUrls = [];
  
  String categoryName = '';
  String categoryNameInarabic = '';
  String classification ='';
  String classText ='';
  int percentageValue = 0 ;
  String face = '';

  @override
  void initState() {
    super.initState();
    _fetchPlaceData();
    placeData = null;
  }




  Future<void> _fetchPlaceData() async {
    // Fetch place data from Firebase Firestore based on the placeID
    final placeDocument = await FirebaseFirestore.instance
        .collection('place')
        .doc(widget.placeID)
        .get();

    setState(() {
      placeData = placeDocument;
      imageUrls = List<String>.from(placeData?['images'] ?? []);
      classification = placeData?['classification'] ?? '';
      percentageValue = placeData?['percentage']?? 0 ;
      
    });


    // Fetch the category name based on categoryID
    final categoryID = placeData?['categoryID'] ?? '';
    final categoryDocument = await FirebaseFirestore.instance
        .collection('category')
        .doc(categoryID)
        .get();

    // Set the categoryName
    setState(() {
      categoryName = categoryDocument['name'];
    });

    if (categoryName == "coffee") {
      categoryNameInarabic = 'مقهى';
    } else if (categoryName == "restaurant") {
      categoryNameInarabic = 'مطعم';
    } else if (categoryName == "shopping") {
      categoryNameInarabic = 'تسوق';
    } else if (categoryName == "beauty") {
      categoryNameInarabic = 'تجميل';
    } else if (categoryName == "entertainment") {
      categoryNameInarabic = 'ترفيه';
    } else {
      categoryNameInarabic = 'سياحة';
    }

     if (classification == "1") {
      classText = 'ممتاز';
      face = 'lib/icons/happiness.png';
    } else if (classification == "2") {
      classText = 'جيد';
      face = 'lib/icons/neutral.png';
    } else if (classification == "3") {
      classText = 'سيء';
      face = 'lib/icons/sad.png';
    } else {
      classText = '';
      face = 'lib/icons/empty-set.png';
       }
  }

  
    Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(placeData?['website']);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(placeData?['name'] ?? ''),
          backgroundColor: Color.fromARGB(255, 211, 198, 226)),


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


      body: 
      Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              
              width: double.maxFinite,
              height: 350,
              
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  enlargeCenterPage: true,
                  autoPlay: true,
                 // aspectRatio: 1,
                  enableInfiniteScroll: true,
                ),
            items: imageUrls
                  .map((url) => ClipRRect(
                        borderRadius: BorderRadius.circular(15), 
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ))
                  .toList(),
              ),
            ),
          ),
        Positioned(
            top: 45,
            left: 20,
            //right: 20,
            child:  
            AppIcon(icon: Icons.favorite)),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 330, //image diminsion
            child: Container(
                padding: const EdgeInsets.only(left: 9, right: 9, top: 9),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    color: Colors.white),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeData?['name'] ?? '',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight
                              .bold, 
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                            Text((classText == '' ? '' :'التقييم: $classText'), style: TextStyle(
                          
                          fontWeight: FontWeight
                              .bold, 
                        ),),
                            SizedBox(
                            width: 10,
                          ),
                             Image.asset(
                            face,
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Text((percentageValue == 0 ? '' : ' $percentageValue% اعجبهم هذا المكان'), style: TextStyle(
                        
                          fontWeight: FontWeight
                              .bold, 
                        ),)
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'lib/icons/c.jpeg',
                            width: 25,
                            height: 25,
                          ),
                          SizedBox(width: 4,),
                          Text(categoryNameInarabic),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          IconAndTextWidget(
                              icon: Icons.access_time_rounded,
                              text: placeData?['opening_hours'] ?? '',
                              iconColor: Colors.pinkAccent),
                        ],
                      ),
                      Text("الوصف",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight
                                .bold, 
                          )),
                      Text(placeData?['description'] ?? ''),
                      SizedBox(height: 20,),

                   Row(
                   
                   children: [
                    
                       const Text(" للتواصل ولمزيد من المعلومات يرجى زيارة",
                        style: TextStyle(
                        color: Color.fromARGB(200, 83, 56, 97), fontSize: 15)),
                        
                         GestureDetector(
                          onTap: 
                          _launchUrl,
                          
                        child: const Text(
                           " موقعهم من هنا ",
                           style: TextStyle(
                          color: Color.fromARGB(255, 83, 56, 97),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                       ),
                       )
                     ],
                  ),
                        
                        SizedBox(height: 50,),


                    ],
                  ),
                )
                )
                )
      ],
    ));
  }
}
