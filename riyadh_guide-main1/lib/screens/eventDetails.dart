import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/home_screen.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/Comment.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class eventDetails extends StatefulWidget {
  String eventID;
  eventDetails({Key? key, required this.eventID}) : super(key: key);

  @override
  State<eventDetails> createState() => _eventDetailsState();
}

class _eventDetailsState extends State<eventDetails> {
  int currentTab = 0;
  Future<String> getEventName() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('event')
        .doc(widget.eventID)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> eventData = snapshot.data() as Map<String, dynamic>;
      return eventData['name'] as String? ?? 'تفاصيل الفعالية';
    } else {
      return 'تفاصيل الفعالية';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 211, 198, 226),
          title: FutureBuilder<String>(
            future: getEventName(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(snapshot.data ?? 'Event Details');
              }
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
        color: Color.fromARGB(157, 217, 197, 230),
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
                    icon: Icon(Icons.account_box),
                    onPressed: () {
                      setState(() {
                        currentTab = 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => account(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 1 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "حسابي",
                    style: TextStyle(
                        color: currentTab == 1 ? Colors.white : Colors.black),
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
                    icon: Icon(Icons.search),
                    onPressed: () {
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
                    style: TextStyle(
                        color: currentTab == 2 ? Colors.white : Colors.black),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.newspaper),
                    onPressed: () {
                      setState(() {
                        currentTab = 3;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => news(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 3 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "أحداث اليوم",
                    style: TextStyle(
                        color: currentTab == 3 ? Colors.white : Colors.black),
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
                    icon: Icon(Icons.favorite),
                    onPressed: () {
                      setState(() {
                        currentTab = 4;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => favourites(),
                          ),
                        );
                      });
                    },
                    color: currentTab == 4 ? Colors.white : Colors.black,
                  ),
                  Text(
                    "المفضلة",
                    style: TextStyle(
                        color: currentTab == 4 ? Colors.white : Colors.black),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('event')
            .doc(widget.eventID)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Event not found.'),
            );
          }

          // Event data
          var eventData = snapshot.data!.data() as Map<String, dynamic>;
          var name = eventData['name'] as String?;
          var location = eventData['location'] as String?;
          var time = eventData['time'] as String?;
          var description = eventData['description'] as String?;
          var images = eventData['images'] as List<dynamic>?;
          var startDateTimestamp = eventData['start_date'] as Timestamp?;
          var endDateTimestamp = eventData['end_date'] as Timestamp?;
          var reservationUrl = eventData['reservation'] as String?;

          var startDate = startDateTimestamp?.toDate();
          var endDate = endDateTimestamp?.toDate();

          var dateFormat = DateFormat('dd/MM/yy');

          bool shouldAutoplay = (images?.length ?? 0) > 1;
          bool shouldEnableInfiniteScroll =
              (images?.length ?? 0) > 1 && images != null;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    autoPlay: shouldAutoplay,
                    enableInfiniteScroll: shouldEnableInfiniteScroll,
                  ),
                  items: images
                          ?.map((url) => ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  url as String,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ))
                          .toList() ??
                      [],
                ),
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Color.fromARGB(255, 40, 2, 84),
                            size: 30,
                          ),
                          SizedBox(height: 8.0),
                          Text('من', textAlign: TextAlign.center),
                          Text(
                              startDate != null
                                  ? dateFormat.format(startDate)
                                  : "N/A",
                              textAlign: TextAlign.center),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Color.fromARGB(255, 40, 2, 84),
                            size: 30,
                          ),
                          SizedBox(height: 8.0),
                          Text('الى', textAlign: TextAlign.center),
                          Text(
                              endDate != null
                                  ? dateFormat.format(endDate)
                                  : "N/A",
                              textAlign: TextAlign.center),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.alarm,
                            color: Color.fromARGB(255, 40, 2, 84),
                            size: 30,
                          ),
                          SizedBox(height: 8.0),
                          Text('الوقت', textAlign: TextAlign.center),
                          Text(time!, textAlign: TextAlign.center),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 30,
                            color: Color.fromARGB(255, 40, 2, 84),
                          ),
                          SizedBox(height: 8.0),
                          Text('الموقع', textAlign: TextAlign.center),
                          GestureDetector(
                            onTap: () {
                              openGoogleMaps(location!);
                            },
                            child: Text(
                              'اضغط هنا',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 30,
                            color: Color.fromARGB(255, 40, 2, 84),
                          ),
                          SizedBox(height: 8.0),
                          Text('للحجز', textAlign: TextAlign.center),
                          if (reservationUrl == 'لا يتطلب حجز ')
                            Text(
                              'لا يتطلب حجز',
                              textAlign: TextAlign.center,
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                openReservationWebsite(reservationUrl!);
                              },
                              child: Text(
                                'اضغط هنا',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '  ماذا يحدث هنا ؟',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        description ?? "No description available.",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Function to open Google Maps with the specified location
void openGoogleMaps(String location) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$location';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// Function to open the reservation website
void openReservationWebsite(String? reservationUrl) async {
  if (reservationUrl != null && reservationUrl.isNotEmpty) {
    if (await canLaunch(reservationUrl)) {
      await launch(reservationUrl);
    } else {
      throw 'Could not launch $reservationUrl';
    }
  } else {
    throw 'Reservation URL is empty';
  }
}
