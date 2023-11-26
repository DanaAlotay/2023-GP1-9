import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';
import 'package:riyadh_guide/screens/Adminprofile.dart';

class MyAdminHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية'),
        backgroundColor: Color.fromARGB(255, 211, 198, 226),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/icons/Bk.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Navigate to account() page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => adminprofile(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Text(
                          " اهلاً",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
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
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSquare(
                        text1: '30',
                        text2: ' مستخدم',
                        icon: Icons.person,
                      ),
                      SizedBox(width: 10),
                      FutureBuilder<int>(
                        future: _getPlacesCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // If still loading, return a placeholder or loading indicator
                            return _buildSquare(
                              text1: '0',
                              text2: 'Places Count',
                              icon: Icons.place,
                            );
                          } else {
                            // Display the places count
                            return _buildSquare(
                              text1: '${snapshot.data}',
                              text2: "مكان",
                              icon: Icons.place,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSquare(
                        text1: '21',
                        text2: ' فعالية',
                        icon: Icons.theater_comedy,
                      ),
                      SizedBox(width: 10),
                      _buildSquare(
                        text1: '6',
                        text2: ' تصنيفات',
                        icon: Icons.category,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the News button click action here
                      },
                      child: Text('  إدارة الفعاليات و الأخبار '),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 66, 49, 76),
                        minimumSize: Size(
                            MediaQuery.of(context).size.width - 40,
                            60), // Adjust the size here
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the Places button click action here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminPlaces(),
                          ),
                        );
                      },
                      child: Text(' إدارة الأماكن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 66, 49, 76),
                        minimumSize: Size(
                            MediaQuery.of(context).size.width - 40,
                            60), // Adjust the size here
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<int> _getPlacesCount() async {
    try {
      QuerySnapshot placesSnapshot = await _firestore.collection('place').get();
      return placesSnapshot.size;
    } catch (e) {
      print("Error getting places count: $e");
      return 0;
    }
  }

  Widget _buildSquare({
    required String text1,
    required String text2,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Color.fromARGB(255, 8, 2, 69),
            ),
            SizedBox(height: 8),
            Text(
              text1,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              text2,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
