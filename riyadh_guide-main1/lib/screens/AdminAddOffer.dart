import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/AdminOffers.dart';

class AdminAddOffer extends StatefulWidget {
  @override
  _AdminAddOffer createState() => _AdminAddOffer();
}

class _AdminAddOffer extends State<AdminAddOffer> {

  Future<List<DocumentSnapshot>> fetchPlaces() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('place').get();
    List<DocumentSnapshot> places = querySnapshot.docs;
    return places;
  } catch (error) {
    print('Error fetching places: $error');
    throw error;
  }
}

  void _submitForm() async {
   if (_percentageValue == 0 ||
      _selectedProvider == '' ||
      _startDate == null ||
      _endDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ادخل معلومات العرض كاملة'),
        backgroundColor: Colors.red,
      ),
    );
    return; 
  }
    final offerInfo = {
        'placeID': _selectedPlaceID ?? '',
        'provider': _selectedProvider ??'',
        'discount': _percentageValue,
        'startDate': _startDate, 
        'endDate': _endDate, 
        'placeName': _selectedPlaceName,
      };
      final DocumentReference OfferRef =
      await FirebaseFirestore.instance.collection('offer').add(offerInfo);
      String OfferId = OfferRef.id;

            await OfferRef.update({
        'offerID': OfferId,
      });

            ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('تم إضافة العرض بنجاح'),
              backgroundColor: Color.fromARGB(181, 203, 145, 210),
            ),
          )
          .closed
          .then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOffers(),
          ),
        );
      });
  }

 String? _selectedPlaceID = 'p1'; // Set a default value
 String? _selectedProvider = '';
 int _percentageValue = 0;
 DateTime? _startDate;
 DateTime? _endDate; 
 String? _selectedPlaceName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة عرض'),
        backgroundColor: Color.fromARGB(255, 66, 49, 76),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminOffers(),
              ),
            );
          },
        ),
      ),
      body: 
      Padding(
        padding: EdgeInsets.only(right: 8.0, left: 8.0 , top: 40),
          child: ListView(
            children: [     
      Container(
  height: 80,
  child: FutureBuilder<List<DocumentSnapshot>>(
    future: fetchPlaces(), // Function to fetch places from Firebase
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator()); // Placeholder while loading
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<DocumentSnapshot> places = snapshot.data!;
        return DropdownButtonFormField<String>(
          value: _selectedPlaceID,
          decoration: InputDecoration(
            labelText: 'مكان العرض',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/icons/pin.png',
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
          ),
          items: places.map((place) {
            return DropdownMenuItem<String>(
              value: place['placeID'],
              child: Text(
                place['name'],
                style: TextStyle(fontSize: 11),
              ),
            );
          }).toList(),
         onChanged: (value) async {
  setState(() {
    _selectedPlaceID = value!;
  });

  // Fetch the corresponding name from Firestore
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('place')
        .doc(value)
        .get();
    if (snapshot.exists) {
      setState(() {
        _selectedPlaceName = snapshot['name'];
      });
    }
  } catch (error) {
    print('Error fetching place name: $error');
  }
},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'اختر المكان';
            }
            return null;
          },
        );
      }
    },
  ),
),
   SizedBox(height: 20,),
                 Container(
                height: 80,
                child: DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: InputDecoration(
                    labelText: 'مقدم العرض',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/icons/offer.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    // fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                    // filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                  ),

                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(
                        'اختر مقدم العرض',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'بريميوم',
                      child: Text(
                        'بنك الراجحي بريميوم',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'الائتمانية',
                      child: Text(
                        'بنك الراجحي الائتمانية',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'بنك الاهلي',
                      child: Text(
                        'بنك الاهلي',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'بنك ساب',
                      child: Text(
                        'بنك ساب',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'ولاء بلس',
                      child: Text(
                        'ولاء بلس',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                     DropdownMenuItem<String>(
                      value: 'نافع',
                      child: Text(
                        'نافع',
                        style: TextStyle(fontSize: 15),
                      ),
                    ), DropdownMenuItem<String>(
                      value: 'يور باي',
                      child: Text(
                        'يور باي',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                     DropdownMenuItem<String>(
                      value: 'اس تي سي باي',
                      child: Text(
                        'اس تي سي باي',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProvider = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'اختر مقدم العرض';
                    }

                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),

              Expanded(
                    child: Column(
                      children: [
                        Text(
                          'نسبة الخصم : ${_percentageValue.toStringAsFixed(0)} %',
                          style: TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: _percentageValue.toDouble(),
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _percentageValue = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  Column(
  children: [
    TextButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light().copyWith(
            primary: const Color.fromARGB(255, 93, 25, 105), // Change the header background color
          ),
          textTheme: TextTheme(
            headline1: TextStyle(
              fontSize: 20, // Change the font size of the header text
              color: Colors.black, // Change the color of the header text
            ),
            subtitle1: TextStyle(
              fontSize: 12, // Change the font size of the date text
              color: Colors.black, // Change the color of the date text
            ),
          ),
        ),
        child: child!,
      );
    },
        );
        if (selectedDate != null) {
          setState(() {
            _startDate = selectedDate;
          });
        }
      },
      child: Text(
        _startDate != null ? _startDate.toString() : 'اختر تاريخ بداية العرض',
      ),
    ),
    SizedBox(width: 20),
    TextButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light().copyWith(
            primary: const Color.fromARGB(255, 93, 25, 105), // Change the header background color
          ),
          textTheme: TextTheme(
            headline1: TextStyle(
              fontSize: 20, // Change the font size of the header text
              color: Colors.black, // Change the color of the header text
            ),
            subtitle1: TextStyle(
              fontSize: 12, // Change the font size of the date text
              color: Colors.black, // Change the color of the date text
            ),
          ),
        ),
        child: child!,
      );
    },
        );
        if (selectedDate != null) {
          setState(() {
            _endDate = selectedDate;
          });
        }
      },
      child: Text(
        _endDate != null ? _endDate.toString() : 'اختر تاريخ نهاية العرض',
      ),
    ),
  ],
),

SizedBox( height: 20,),

              Container(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: Text(
                    'إضافة العرض',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 66, 49, 76),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ),
      ]
        )
          )
              
    );
  }
}