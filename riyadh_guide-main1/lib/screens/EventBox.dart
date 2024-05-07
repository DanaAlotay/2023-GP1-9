import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/Event.dart';
import 'package:riyadh_guide/screens/eventDetails.dart';

class EventBox extends StatelessWidget {
  final Event event;

  const EventBox({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 7, // Blur radius
            offset: Offset(0, 3), // Offset
          ),
        ],
      ),
      child: Row(
        children: [
          if (event.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Rounded corner radius
              child: Image.network(
                event.imageUrl!,
                width: 130.0,
                height: 130.0,
                fit: BoxFit.cover,
              ),
            ),
          if (event.imageUrl != null) const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  event.description.substring(0, 20) + "...",
                  style: const TextStyle(fontSize: 14.0),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => eventDetails(eventID: event.id),
                      ),
                    );
                  },
                  child: Text(
                    "للمزيد",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
