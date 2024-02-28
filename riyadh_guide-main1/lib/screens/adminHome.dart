import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/AdminOffers.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';
import 'package:riyadh_guide/screens/Adminprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAdminHomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(''),
      //   backgroundColor: Color.fromARGB(255, 211, 198, 226),
      //   automaticallyImplyLeading: false,
      // ),
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   title: const Text(
      //     " ",
      //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //     textAlign: TextAlign.right,
      //   ),
      // ),
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
                      padding: EdgeInsets.fromLTRB(16, 20, 20, 0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            size: 40,
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
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('user')
                              .doc(currentUser
                                  ?.uid) // Use currentUser?.uid to get the current user's UID
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                "أهلًا",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold),
                              );
                            }
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            //var userName = userData['name'];
                            var userName = userData?['name'] ?? '';

                            return Text(
                              "أهلًا $userName",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold),
                            );
                          },
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
                      FutureBuilder<int>(
                        future: _getUsersCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // If still loading, return a placeholder or loading indicator
                            return _buildSquare(
                                text1: '0', text2: 'مستخدم', icon: Icons.group);
                            //  imagePath: 'lib/icons/group.png');
                          } else {
                            // Display the users count
                            return _buildSquare(
                                text1: '${snapshot.data}',
                                text2: '  مستخدم',
                                icon: Icons.group);
                            //  imagePath: 'lib/icons/group.png');
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      FutureBuilder<int>(
                        future: _getPlacesCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // If still loading, return a placeholder or loading indicator
                            return _buildSquare(
                                text1: '0', text2: 'مكان', icon: Icons.place);
                            // imagePath: 'lib/icons/location-pin.png');
                          } else {
                            // Display the places count
                            return _buildSquare(
                                text1: '${snapshot.data}',
                                text2: 'مكان',
                                icon: Icons.place);
                            //imagePath: 'lib/icons/location-pin.png');
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
                        icon: Icons.celebration,
                      ),
                      //  imagePath: 'lib/icons/fireworks.png'),
                      SizedBox(width: 10),
                      _buildSquare(
                        text1: '6',
                        text2: ' تصنيفات',
                        icon: Icons.category,
                      ),
                      // imagePath: 'lib/icons/choose.png'),
                    ],
                  ),
                  SizedBox(height: 25),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the News button click action here
                      },
                      child: Text('  إدارة الفعاليات و الأخبار '),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 66, 49, 76),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width - 40, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Adjust the radius here
                        ), // Adjust the size here
                      ),
                    ),
                  ),
                  SizedBox(height: 11),
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
                        minimumSize:
                            Size(MediaQuery.of(context).size.width - 40, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Adjust the radius here
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the Places button click action here
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminOffers(),
                          ),
                        );
                      },
                      child: Text(' إدارة العروض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 66, 49, 76),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width - 40, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Adjust the radius here
                        ),
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

  Future<int> _getUsersCount() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('user').get();
      return querySnapshot.size;
    } catch (e) {
      print('Error getting users count: $e');
      return 0;
    }
  }

  Widget _buildSquare({
    required String text1,
    required String text2,
    required IconData icon,
    // required String imagePath,
  }) {
    return Expanded(
      child: Container(
        height: 150,
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
