import 'package:flutter/material.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _accountState();
}

class _accountState extends State<account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('حسابي'),
          backgroundColor: Color.fromARGB(255, 228, 207, 254)),
      body: Center(child: Text('حسابي')),
    );
  }
}
