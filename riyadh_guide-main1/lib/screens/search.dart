import 'package:flutter/material.dart';

class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البحث'),
        backgroundColor: Color.fromARGB(255, 200, 161, 250)),
      body: Center(
        child: Text('البحث')
        ),
    );
  }
}