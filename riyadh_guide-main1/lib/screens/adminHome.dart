import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MyAdminHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('الصفحة الرئيسية'),
        ),
        body: AdminPage(),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
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
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                            hintText: "ابحث عن مكان...",
                          ),
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
                children: <Widget>[
                 Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildSquare(
      text: ' 30 مستخدم' ,
      icon: Icons.person,
    ),
    SizedBox(width: 10),
    FutureBuilder<int>(
      future: _getPlacesCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If still loading, return a placeholder or loading indicator
          return _buildSquare(
            text: 'Places Count',
            icon: Icons.place,
          );
        } else {
          // Display the places count
          return _buildSquare(
            text: '${snapshot.data} مكان ',
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
                        text: '21 فعالية',
                        icon: Icons.circle,
                      ),
                       SizedBox(width: 10),
                      _buildSquare(
                        text: '6 تصنيفات',
                        icon: Icons.circle,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                Center(
  child: ElevatedButton(
    onPressed: () {
      // Handle the News button click action here
    },
    child: Text('  عرض الفعاليات  ' ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.pink,
      minimumSize: Size(MediaQuery.of(context).size.width - 40, 60), // Adjust the size here
    ),
  ),
),
                  SizedBox(height: 20),
                 Center(
  child: ElevatedButton(
    onPressed: () {
      // Handle the Places button click action here
    },
    child: Text(' عرض الاماكن '),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.pink,
      minimumSize: Size(MediaQuery.of(context).size.width - 40, 60), // Adjust the size here
    ),
  ),
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
      QuerySnapshot placesSnapshot =
          await _firestore.collection('place').get();
      return placesSnapshot.size;
    } catch (e) {
      print("Error getting places count: $e");
      return 0;
    }
  }

  Widget _buildSquare({required String text, required IconData icon}) {
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
              color: Colors.blue,
            ),
            SizedBox(height: 8),
            Text(
              text,
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
