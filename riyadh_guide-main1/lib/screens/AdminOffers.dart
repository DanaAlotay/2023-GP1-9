import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/AdminAddOffer.dart';
import 'package:riyadh_guide/screens/EditDeleteOffer.dart';
import 'package:riyadh_guide/screens/adminHome.dart';

class AdminOffers extends StatefulWidget {
  @override
  _AdminOffersState createState() => _AdminOffersState();
}

class _AdminOffersState extends State<AdminOffers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة العروض'),
        backgroundColor: Color.fromARGB(255, 211, 198, 226),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAdminHomePage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle the Places button click action here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAddOffer(),
                    ),
                  );
                },
                child: Text('إضافة عرض جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 66, 49, 76),
                  minimumSize: Size(
                      MediaQuery.of(context).size.width - 40, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30), // Adjust the radius here
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // StreamBuilder to listen for changes in the offer collection
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('offer').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Placeholder while loading
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                // Display offer documents as cards
                return Column(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                         builder: (context) => EditDeleteOffer(placeID: data['placeID'], offerID: data['offerID'], provider: data['provider'], discount: data['discount'], startDate: (data['startDate'] as Timestamp).toDate(), endDate: (data['endDate'] as Timestamp).toDate()),
                    ),
                  );
                        
                        },child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ListTile(
                        title: Text('اسم المكان: ${data['placeName']}'),
                        subtitle: Text('مقدم العرض: ${data['provider']} | نسبة الخصم: ${data['discount'].toString()}%'),
                      ),
                    ),
                  );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
