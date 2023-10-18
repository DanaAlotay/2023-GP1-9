import 'package:flutter/material.dart';

class favourites extends StatefulWidget {
  const favourites({super.key});

  @override
  State<favourites> createState() => _favouritesState();
}

class _favouritesState extends State<favourites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('المفضلة'),
          backgroundColor: Color.fromARGB(255, 228, 207, 254)),
      body: Center(child: Text('المفضلة')),
    );
  }
}
