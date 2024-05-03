

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
      // Clear the events list before populating it with new events
      events.clear();

      eventDocuments.docs.forEach((doc) {
        final eventData = doc.data();
        Event event = Event(
          name: eventData['name'],
          description: eventData['description'],
          startDate: (eventData['start_date'] as Timestamp).toDate(),
          endDate: (eventData['end_date'] as Timestamp).toDate(),
          location: eventData['location'],
          reservation: eventData['reservation'],
          imageUrl: eventData['images'][0],
        );

        // Check if the selected day is within the event's start and end dates if (_selectedDay.isAfter(event.startDate) && _selectedDay.isBefore(event.endDate)) {
          // Add the event to the list only if it falls within the selected date range
          events.add(event);
        
      });

      events.forEach((event) {
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
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: {CalendarFormat.month: 'Month'}, // Only show Month format
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide format button
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
              locale: 'ar_SA', // Set locale to Arabic in Saudi Arabia
              calendarStyle: CalendarStyle(
                // Customize calendar style if needed
                defaultTextStyle: TextStyle(fontWeight: FontWeight.bold),
                cellMargin: EdgeInsets.all(4), // Add margin around each cell
                outsideDaysVisible: false, // Hide days from previous and next months
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                // Customize days of week style if needed
                weekdayStyle: TextStyle(color: Colors.black, fontSize: 10.5),
                weekendStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 10.5),
              ),
              calendarBuilders: CalendarBuilders(
                // Customize day builder to use Arabic numerals with a little space
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
                        SizedBox(height: 10), // Add space between day name and number
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
                        SizedBox(height: 10), // Add space between day name and number
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
                        SizedBox(height: 10), // Add space between day name and number
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
                // Ensure the current day is displayed in Arabic numerals
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
                        SizedBox(height: 10), // Add space between day name and number
                        Text(
                          _convertToArabicNumerals(date.day),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 15), // Add some space between the calendar and the text
            Text(
              'الفعاليات:',
              style: TextStyle(
                fontSize: 20, // Set the font size
                fontWeight: FontWeight.bold, // Optionally set font weight
              ),
            ),
             SizedBox(height: 25), // Add some space between the calendar and the text
           Expanded(
  child: ListView.builder(
  itemCount: events.length,
  itemBuilder: (context, index) {
    // Check if the selected date is within the start and end dates of the event
    bool isSelectedDateInRange = _selectedDay.isAfter(events[index].startDate) &&
        _selectedDay.isBefore(events[index].endDate);

    // Show the event only if the selected date is within the start and end dates
    return isSelectedDateInRange ? EventBox(event: events[index]) : SizedBox.shrink();
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
      padding: EdgeInsets.only(left: index == 1 ? 10.0 : 0.0, right: index == 4 ? 10.0 : 0.0),
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
            }},
            color: _currentTab == index ? Colors.white : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(color: _currentTab == index ? Colors.white : Colors.black),
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

