import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';

class Adminaddbview extends StatefulWidget {
  final String placeID;

  const Adminaddbview({Key? key, required this.placeID}) : super(key: key);

  @override
  State<Adminaddbview> createState() => _AdminaddbviewState();
}

class _AdminaddbviewState extends State<Adminaddbview> {
  late DocumentSnapshot? placeData;
  List<String> imageUrls = [];
  String categoryName = '';
  String categoryNameInarabic = '';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(placeData?['name'] ?? ''),
        backgroundColor: Color.fromARGB(255, 66, 49, 76),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPlaces(),
              ),
            );
          },
        ),
      ), // Box color
      body: Stack(
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
              child: AppIcon(icon: Icons.favorite)),
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
                        fontWeight: FontWeight.bold,
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(placeData?['description'] ?? '')
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
