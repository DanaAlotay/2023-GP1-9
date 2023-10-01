import 'package:flutter/material.dart';

class category extends StatefulWidget {
  const category({super.key});

  @override
  State<category> createState() => _categoryState();
}

class _categoryState extends State<category> {
  @override
  var catNames = [
    'مقاهي',
    'مطاعم',
    'تسوق',
    'مراكز تجميل',
    'ترفيه',
    'معالم سياحية'
  ];
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        backgroundColor: Color.fromARGB(255, 200, 161, 250),
      ),
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: SizedBox(
              height: 70,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      for (int i = 0; i < 6; i++)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 254, 255),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ]),
                          child: Text(
                            catNames[i],
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
