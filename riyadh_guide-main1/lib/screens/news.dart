import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/Event.dart';
import 'package:riyadh_guide/screens/EventBox.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class news extends StatefulWidget {
  const news({super.key});

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<news> {
  int _currentTab = 3;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedClassification =
      ''; // Variable to store the selected classification
  List<Event> events = [
    // Event data
  ];

  @override
  void initState() {
    super.initState();
    _fetchEventData();
  }

  Future<void> _fetchEventData() async {
    try {
      final eventCollection = FirebaseFirestore.instance.collection('event');
      final eventDocuments = await eventCollection.get();

      setState(() {
        events.clear();

        eventDocuments.docs.forEach((doc) {
          final eventId = doc.id; // Retrieve the document ID
          final eventData = doc.data();

          Event event = Event(
            id: eventId,
            name: eventData['name'],
            description: eventData['description'],
            startDate: (eventData['start_date'] as Timestamp).toDate(),
            endDate: (eventData['end_date'] as Timestamp).toDate(),
            location: eventData['location'],
            reservation: eventData['reservation'],
            imageUrl: eventData['images'][0],
            classification: eventData['classification'],
          );

          events.add(event);
        });

        events.forEach((event) {
          print('ID: ${event.id}'); // Print the ID
          print('Name: ${event.name}');
          print('Description: ${event.description}');
          print('Start Date: ${event.startDate}');
          print('End Date: ${event.endDate}');
          print('Location: ${event.location}');
          print('Reservation: ${event.reservation}');
          print('Image URL: ${event.imageUrl}');
          print('---------------------------------------');
        });
      });
    } catch (error) {
      print("Error fetching event data: $error");
      // Handle error here
    }
  }

  String _convertToArabicNumerals(int number) {
    final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      if (RegExp(r'[0-9]').hasMatch(char)) {
        return arabicNumerals[int.parse(char)];
      } else {
        return char;
      }
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أحداث اليوم'),
        backgroundColor: Color.fromARGB(255, 211, 198, 226),
        automaticallyImplyLeading: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentTab = 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ),
            );
          });
        },
        child: Image.asset('lib/icons/Logo.png'),
        backgroundColor: Color.fromARGB(157, 165, 138, 182),
        elevation: 20.0,
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        shape: CircularNotchedRectangle(),
        color: Color.fromARGB(157, 217, 197, 230),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildBottomNavItem(Icons.account_box, 'حسابي', 1),
            _buildBottomNavItem(Icons.search, 'البحث', 2),
            SizedBox(width: 48), // Placeholder to maintain space
            _buildBottomNavItem(Icons.newspaper, 'أحداث اليوم', 3),
            _buildBottomNavItem(Icons.favorite, 'المفضلة', 4),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(3.0),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 30,
                  color: Color.fromARGB(255, 53, 3, 109),
                ),
                onSelected: (String value) {
                  // Handle filter option selection
                  setState(() {
                    _selectedClassification = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'تصفية حسب نوع الفعالية',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(),
                        PopupMenuItem<String>(
                          value: 'عروض',
                          child: Text('عروض '),
                        ),
                        PopupMenuItem<String>(
                          value: 'حفلات',
                          child: Text('حفلات موسيقية'),
                        ),
                        PopupMenuItem<String>(
                          value: 'افتتاحات',
                          child: Text('افتتاحات'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: {CalendarFormat.month: 'Month'},
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              locale: 'ar_SA',
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(fontWeight: FontWeight.bold),
                cellMargin: EdgeInsets.all(4),
                outsideDaysVisible: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black, fontSize: 10.5),
                weekendStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0), fontSize: 10.5),
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 82, 29, 107),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                defaultBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
                outsideBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
                todayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 180, 140, 207),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  final hasEvent = events.isNotEmpty;
                  return hasEvent
                      ? Positioned(
                          bottom: 5,
                          child: Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.red, // Customize the color of the dot
                            ),
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
            ),

            SizedBox(
                height: 5), // Add some space between the calendar and the text
            Text(
              'الفعاليات:',
              style: TextStyle(
                fontSize: 20, // Set the font size
                fontWeight: FontWeight.bold, // Optionally set font weight
              ),
            ),
            SizedBox(
                height: 5), // Add some space between the calendar and the text
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  // Check if the selected date is within the start and end dates of the event
                  bool isSelectedDateInRange =
                      _selectedDay.isAfter(events[index].startDate) &&
                          _selectedDay.isBefore(events[index].endDate);

                  bool hasSelectedClassification = _selectedClassification ==
                          null ||
                      _selectedClassification.isEmpty ||
                      events[index].classification == _selectedClassification;

                  // Show the event only if the selected date is within the start and end dates
                  // and the event has the selected classification
                  return isSelectedDateInRange && hasSelectedClassification
                      ? EventBox(event: events[index])
                      : SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return Padding(
      padding: EdgeInsets.only(
          left: index == 1 ? 10.0 : 0.0, right: index == 4 ? 10.0 : 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {
              if (_currentTab != index) {
                setState(() {
                  _currentTab = index;
                  _navigateToScreen(index);
                });
              }
            },
            color: _currentTab == index ? Colors.white : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
                color: _currentTab == index ? Colors.white : Colors.black),
          )
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => account(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => search(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => news(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => favourites(),
          ),
        );
        break;
      default:
        break;
    }
  }
}
