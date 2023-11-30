import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';
import 'package:riyadh_guide/screens/adminEditPlace.dart';
import 'package:riyadh_guide/screens/place_detail.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';

class AllPlaces extends StatefulWidget {
  @override
  _AllPlacesState createState() => _AllPlacesState();
}

class _AllPlacesState extends State<AllPlaces> {
  final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('place');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: placesCollection.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data found for any category.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot placeDocument = snapshot.data!.docs[index];
            String placeName = placeDocument.get('name').toString();
            String placeID = placeDocument.get('placeID').toString();
            List<dynamic> imageArray = placeDocument.get('images') ?? [];
            String placeImage =
                (imageArray.isNotEmpty) ? imageArray[0].toString() : '';
            String openingHours = placeDocument.get('opening_hours').toString();

            return InkWell(
              /* onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceDetails(placeID: placeID),
                  ),
                );
              },*/
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
                        // Add delete and edit icons here
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              IconButton(
                                icon: AppIcon(icon: Icons.edit),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          adminEditPlace(placeID: placeID),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: AppIcon(icon: Icons.delete),
                                color: Color.fromARGB(255, 121, 19, 3),
                                onPressed: () {
                                  // Handle delete action
                                  deletePlaceWithConfirmation(
                                      context, placeID, placeName);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*InkWell(
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
                          ),*/
                          SizedBox(
                            width: 15,
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
                          SizedBox(
                            width: 40,
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
                          SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void deletePlaceWithConfirmation(
    BuildContext context, String placeID, String placeName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد'),
        content: Text(' هل أنت متأكد من حذف ' + placeName + '؟'),
        actions: <Widget>[
          TextButton(
            child: Text('إلغاء'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('حذف'),
            onPressed: () async {
              // Delete the document
              Navigator.of(context).pop();
              deletePlace(context, placeID);
              showSnackBar(context, 'تم الحذف بنجاح',
                  Color.fromARGB(181, 203, 145, 210));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPlaces(),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> deletePlace(BuildContext context, String placeID) async {
  try {
    DocumentReference placeRef =
        FirebaseFirestore.instance.collection('place').doc(placeID);
    await placeRef.delete();
  } catch (e) {
    print('حدث خطأ أثناء الحذف: $e');
  }
}

void showSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
    ),
  );
}
