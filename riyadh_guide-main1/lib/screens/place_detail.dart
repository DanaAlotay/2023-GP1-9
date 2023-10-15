import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore

class PlaceDetails extends StatefulWidget {
  final String placeID;

  const PlaceDetails({Key? key, required this.placeID}) : super(key: key);
  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

// ignore: camel_case_types
class _PlaceDetailsState extends State<PlaceDetails> {
  late DocumentSnapshot? placeData;
  String imageUrl = '';
  String categoryName = '';
  String categoryNameInarabic='';

  @override
  void initState() {
    super.initState();
    _fetchPlaceData();
    placeData = null;
  }

  Future<void> _fetchPlaceData() async {
    // Fetch place data from Firebase Firestore based on the placeID
    //place id
//get the place id according to the chosen place => it should be sent from category.dart

    final placeDocument = await FirebaseFirestore.instance
        .collection('place')
        .doc(widget.placeID)
        .get();

    setState(() {
      placeData = placeDocument;
      imageUrl = placeData?['image'] ?? '';
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
      categoryNameInarabic='مقهى' ;
    }
    else if(categoryName == "restaurant"){
categoryNameInarabic='مطعم' ;
    }
    else if(categoryName == "shopping"){
categoryNameInarabic='تسوق' ;
    }
    else if(categoryName == "beauty"){
categoryNameInarabic='تجميل' ;
    }
    else if(categoryName == "entertainment"){
categoryNameInarabic='ترفيه' ;
    }
    else{
      categoryNameInarabic='سياحة' ;
    }

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            left: 0,
            right: 0,
            child: Container(
              width: double.maxFinite,
              height: 350, //change to screen hight
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl),
              )),
            )),
        Positioned(
            top: 45,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    },
                    child: AppIcon(icon: Icons.arrow_back_ios)
                    ) ,
                AppIcon(icon: Icons.favorite)
              ],
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 330, //make it the image diminsion
            child: Container(
                padding: const EdgeInsets.only(left: 9, right: 9, top: 9),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeData?['name'] ?? '',
                      style: TextStyle(
                        fontSize: 24, // Adjust the font size as needed
                        fontWeight:
                            FontWeight.bold, // You can also apply other styles
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
                       
                        Text("230"),
                        SizedBox(
                          width: 10,
                        ),
                        Text("تعليق")
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        IconAndTextWidget(
                            icon: Icons.circle_sharp,
                            text: categoryNameInarabic,
                            iconColor: Colors.purple),
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
                          fontSize: 24, // Adjust the font size as needed
                          fontWeight: FontWeight
                              .bold, // You can also apply other styles
                        )),
                    Text(placeData?['description'] ?? '')
                  ],
                )))
      ],
    ));
  }
}
