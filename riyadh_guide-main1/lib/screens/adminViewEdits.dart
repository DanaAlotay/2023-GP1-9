import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class adminViewEdits extends StatefulWidget {
  
  final String name;
  final String hours;
  final String description;
  final String categoryID;
  final List<String> imageUrls;
  final String website;

  const adminViewEdits({Key? key, required this.name, required this.hours, required this.description, required this.categoryID, required this.imageUrls, required this.website}) : super(key: key);

  @override
  _adminViewEditsState createState() => _adminViewEditsState();
}

class _adminViewEditsState extends State<adminViewEdits> {

  late DocumentSnapshot? placeData;
  String categoryName = '';
  String categoryNameInarabic = '';

  @override
  void initState() {
    super.initState();
    _fetchPlaceData();
    placeData = null;
  }

  Future<void> _fetchPlaceData() async {
 
    // Fetch the category name based on categoryID
    final categoryID = widget.categoryID;
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
  }

   Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(widget.website);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.name),
          backgroundColor: Color.fromARGB(255, 66, 49, 76), ),


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
            items: widget.imageUrls
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
                        widget.name,
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
                          Text("4.5"),
                          SizedBox(
                            width: 10,
                          ),
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
                              text: widget.hours,
                              iconColor: Colors.pinkAccent),
                        ],
                      ),
                      Text("الوصف",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight
                                .bold, 
                          )),
                      Text(widget.description),

                       SizedBox(height: 20,),

                   Row(
                   
                   children: [
                    
                       const Text(" للتواصل ولمزيد من المعلومات يرجى زيارة",
                        style: TextStyle(
                        color: Color.fromARGB(200, 83, 56, 97), fontSize: 16)),
                        
                         GestureDetector(
                          onTap: 
                          _launchUrl,
                          
                        child: const Text(
                           " موقعهم من هنا ",
                           style: TextStyle(
                          color: Color.fromARGB(255, 83, 56, 97),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                       ),
                       )
                     ],
                  ),
                        
                        SizedBox(height: 50,),

                    ],
                  ),
                )))
      ],
    ));
  }
}
