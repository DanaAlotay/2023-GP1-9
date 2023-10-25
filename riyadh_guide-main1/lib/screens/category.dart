import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/place_detail.dart';

class category extends StatefulWidget {
  final String categoryID;

  const category({Key? key, required this.categoryID}) : super(key: key);
  

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<category> {
  // Define a collection reference to the "places" collection in Firestore
  final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('place');

      String categoryNameInarabic='';

  @override
  Widget build(BuildContext context) {
    if (widget.categoryID == "c2") {
      categoryNameInarabic = 'مقاهي';
    } else if (widget.categoryID == "c1") {
      categoryNameInarabic = 'مطاعم';
    } else if (widget.categoryID == "c3") {
      categoryNameInarabic = 'تسوق';
    } else if (widget.categoryID == "c4") {
      categoryNameInarabic = 'مراكز تجميل';
    } else if (widget.categoryID == "c5") {
      categoryNameInarabic = 'ترفيه';
    } else {
      categoryNameInarabic = 'أماكن سياحية';
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(categoryNameInarabic),
          backgroundColor: Color.fromARGB(255, 211, 198, 226)),
      body: FutureBuilder<QuerySnapshot>(
        future: placesCollection
            .where('categoryID', isEqualTo: widget.categoryID)
            .get(), // Fetch documents with categoryID equal to the category ID send from homepage
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
                String placeID = placeDocument.get('placeID').toString();
                List<dynamic> imageArray = placeDocument.get('images') ?? [];
                String placeImage = (imageArray.isNotEmpty) ? imageArray[0].toString() : '';
               // String placeImage = placeDocument.get('image').toString();
                String openingHours =
                    placeDocument.get('opening_hours').toString();

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
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              Text(
                                "ممتاز",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
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
    );
  }
}
