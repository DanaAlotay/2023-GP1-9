import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/adminAddEvnt.dart';
import 'package:riyadh_guide/screens/adminHome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEvents extends StatelessWidget {
  String _formatDate(Timestamp? timestamp) {
  if (timestamp != null) {
    DateTime date = timestamp.toDate();
    String day = _convertToArabic(date.day);
    String month = _getMonthName(date.month);
    String year = _convertToArabic(date.year);
    return '$day $month $year';
  } else {
    return 'Date not available';
  }
}

String _convertToArabic(int number) {
  String arabicNumbers = '٠١٢٣٤٥٦٧٨٩';
  return number.toString().split('').map((char) => arabicNumbers[int.parse(char)]).join();
}


String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'يناير';
    case 2:
      return 'فبراير';
    case 3:
      return 'مارس';
    case 4:
      return 'أبريل';
    case 5:
      return 'مايو';
    case 6:
      return 'يونيو';
    case 7:
      return 'يوليو';
    case 8:
      return 'أغسطس';
    case 9:
      return 'سبتمبر';
    case 10:
      return 'أكنوبر';
    case 11:
      return 'نوفمبر';
    case 12:
      return 'ديسمبر';
    default:
      return '';
  }
}

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الفعاليات والأخبار'),
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
                  // Handle the Add Event button click action here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAddEvent(),
                    ),
                  );
                },
                child: Text('إضافة فعالية أو خبر جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 66, 49, 76),
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 40, 
                    60
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
                future: FirebaseFirestore.instance.collection('event').get().then((snapshot) => snapshot.docs),
                builder: (context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show a loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Display the error message
                  } else {
                    final events = snapshot.data!; // Extract the list of events
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        // Build a card for each event
                        final event = events[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Card(
                            child: ListTile(
                             title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اسم الفعالية: ${event['name']}'),
          SizedBox(height: 10), // Add space between title and subtitles
        ],
      ),
                             subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تاريخ بدء الفعالية: ${_formatDate(event['start_date'])}'), // Display formatted date
          Text('تاريخ انتهاء الفعالية: ${_formatDate(event['end_date'])}'), // Display formatted date
          // Add more fields here
                              // Add more fields as needed
           ] ),
                          ),
                         ) );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
