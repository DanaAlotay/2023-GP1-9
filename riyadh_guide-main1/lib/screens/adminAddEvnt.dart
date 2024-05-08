import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import for FirebaseStorage
import 'package:image_picker/image_picker.dart'; // Import for ImagePicker
import 'package:riyadh_guide/screens/AdminEvents.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AdminAddEvent extends StatefulWidget {
  const AdminAddEvent({Key? key}) : super(key: key);

  @override
  _AdminAddEventState createState() => _AdminAddEventState();
}

class _AdminAddEventState extends State {
  TextEditingController _startdateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _imagesController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _reservationController = TextEditingController();
  //TextEditingController _classificationController = TextEditingController();

  List<String> _classification = [
    'مغامرات',
    'افتتاحات',
    'عروض',
    'حفلات',
];

String? _selectedClassification;


  List<File> _images = []; // List to store picked images
  bool isDefaultImageSelected =
      false; // Flag to track if default image is selected
 bool _isLoading = false;
// Function to add event to Firestore
  void _addEventToFirestore() async {
     // Validate if all fields are not empty
  if (_startdateController.text.isEmpty ||
      _timeController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _endDateController.text.isEmpty ||
      _locationController.text.isEmpty ||
      _nameController.text.isEmpty ||
      _reservationController.text.isEmpty ||
      _selectedClassification == null) {
    // Show a message to the user that all fields are required
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تنبيه"),
          content: Text("تأكد من اكتمال جميع الحقول"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("تم",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 53, 12, 77)),),
            ),
          ],
        );
      },
    );
    return; // Exit the method
  }
  // Convert start and end date strings to DateTime objects
  DateTime startDate = DateTime.parse(_startdateController.text);
  DateTime endDate = DateTime.parse(_endDateController.text);
  
  // Convert DateTime objects to Firestore Timestamps
  Timestamp startTimestamp = Timestamp.fromDate(startDate);
  Timestamp endTimestamp = Timestamp.fromDate(endDate);

// Upload images to Firebase Storage and get their URLs
    List<String> imageUrls = await uploadImages();
// Add event details along with image URLs to Firestore
    FirebaseFirestore.instance.collection('event').add({
      'classification':_selectedClassification,
      'time': _timeController.text,
      'start_date': startTimestamp,
      'description': _descriptionController.text,
      'end_date': endTimestamp,
      'images': imageUrls, // Update to store image URLs
      'location': _locationController.text,
      'name': _nameController.text,
      'reservation': _reservationController.text,
    }).then((value) {
      // Clear text controllers after adding event
      _selectedClassification = null;
      _startdateController.clear();
      _timeController.clear();
      _descriptionController.clear();
      _endDateController.clear();
      _imagesController.clear();
      _locationController.clear();
      _nameController.clear();
      _reservationController.clear();
      // Navigate to adminEvents screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminEvents()),
    );
    // Show SnackBar to notify the user of successful addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت الاضافة بنجاح'),
        backgroundColor: Color.fromARGB(181, 203, 145, 210),
      ),
    );
    }).catchError((error) {
      // Handle errors
    });
  }
Future<String?> getApiKey() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('api_keys')
        .doc('ai_key')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      print('Retrieved data: $data');
      if (data != null) {
        String? apiKey = data['OPENAI_API_KEY'] as String?;
        print('Retrieved API Key: $apiKey');
        if (apiKey != null) {
          return apiKey;
        } else {
          throw Exception('API Key is null');
        }
      } else {
        throw Exception('No data available');
      }
    } else {
      throw Exception('Document not found');
    }
  }

  Future<String> chatGPTAPI(
      TextEditingController _descriptionController) async {
    final String prompt = _descriptionController.text;
    final OpenAiKey = await getApiKey();

    final List<Map<String, String>> messages = [
      {
        'role': 'user',
        'content': prompt,
      },
    ];

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8', // Specify UTF-8 encoding
          'Authorization': 'Bearer $OpenAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content = utf8.decode(jsonDecode(res.body)['choices'][0]
                ['message']['content']
            .codeUnits); // Decode the response using UTF-8
        content = content.trim();

        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

// Function to upload images to Firebase Storage
  Future<List<String>> uploadImages() async {
    List<String> imageUrls = [];
    if (isDefaultImageSelected) {
      // Upload the default image to Firestore
      String defaultImageUrl =
          'https://firebasestorage.googleapis.com/v0/b/riyadh-guide-database-9528e.appspot.com/o/defaultImg.jpeg?alt=media&token=5efaca11-cfa2-401d-98c0-e597a158a5ed';
      imageUrls.add(defaultImageUrl);
    }

    for (var i = 0; i < _images.length; i++) {
      File image = _images[i];

      // Generate a unique filename for each image
      String fileName = 'event_image_$i.jpg';

      // Upload the image to Firestore
      Reference storageRef =
          FirebaseStorage.instance.ref().child('event_images').child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);

      // Get the download URL of the uploaded image
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

// Function to pick image from gallery or camera
  void pickImage(ImageSource source) async {
    if (isDefaultImageSelected) {
      setState(() {
        _images.removeWhere((image) =>
            image.path ==
            'lib/icons/defaultImg.jpeg'); // Remove the default image from the list
        isDefaultImageSelected = false;
      });
    }
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      setState(() {
        _images.add(imageFile);
      });
    } else if (_images.isEmpty) {
      setState(() {
        isDefaultImageSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('إضافة فعالية أو خبر جديد'),
          backgroundColor: Color.fromARGB(255, 66, 49, 76),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminEvents(),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          // Wrap the Column with SingleChildScrollView
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
// Text form fields for event details
// Wrap the SizedBox with a Row
           Row(
  children: [
    Expanded(
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/icons/c.jpeg',
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 8),
                
              ],
            ),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 13.0, horizontal: 13.0),
        ),
        child: DropdownButton<String>(
          value: _selectedClassification,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(fontSize: 15, color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClassification = newValue!;
            });
          },
          items: <String>[
            'مغامرات',
            'افتتاحات',
            'عروض',
            'حفلات',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    ),
    SizedBox(width: 8), // Spacer
  ],
),


            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الفعالية',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                 prefixIcon: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/icons/p.jpeg',
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
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'الوقت',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                 prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'lib/icons/cl.jpeg',
                      width: 20,
                      height: 20,
                    ),
                  ),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
              SizedBox(height: 10),
            TextFormField(
  controller: _startdateController,
  onTap: () async {
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
        _startdateController.text = selectedDate.toString();
      });
    }
  },
  decoration: InputDecoration(
    labelText: 'تاريخ البداية',
    labelStyle: TextStyle(fontSize: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
    ),
    prefix: Image.asset(
      'lib/icons/calendar.png', // Adjust the path to your image
      width: 17, // Adjust the width as needed
      height: 17, // Adjust the height as needed
    ),
  ),
  style: TextStyle(fontSize: 16, color: Colors.black),
),

            SizedBox(height: 10),
TextFormField(
  controller: _endDateController,
  onTap: () async {
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
        _endDateController.text = selectedDate.toString();
      });
    }
  },
  decoration: InputDecoration(
    labelText: 'تاريخ الانتهاء',
    labelStyle: TextStyle(fontSize: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
    ),
    prefix: Image.asset(
      'lib/icons/calendar.png', // Adjust the path to your image
      width: 17, // Adjust the width as needed
      height: 17, // Adjust the height as needed
    ),
  ),
  style: TextStyle(fontSize: 16, color: Colors.black),
),
            SizedBox(height: 10),
            TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  hintText:
                      'للاستفادة من خدمة كتابة الوصف باستخدام الذكاء الاصطناعي ادخل مثلا: اكتب وصف لفعالية تاريخية اسمها فعالية أيام زمان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                          'lib/icons/des.jpeg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(width: 2),
                    ],
                  ),
                  //  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  //filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل الوصف';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10.0,
                width: 150,
              ),
              Container(
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    // Callback function when the button is pressed
                    setState(() {
                      _isLoading = true;
                    });

                    String response = await chatGPTAPI(_descriptionController);

                    setState(() {
                      _descriptionController.text = response;
                      _isLoading = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 235, 216, 247),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 8.0),
                            Text('جاري الانشاء...'),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/icons/ai.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 8.0),
                            Text('انشاء الوصف باستخدام الذكاء الاصطناعي'),
                          ],
                        ),
                ),
              ),
            SizedBox(height: 25),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'الموقع',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'lib/icons/pin.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _reservationController,
              decoration: InputDecoration(
                labelText: 'آلية الحجز',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
               prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'lib/icons/booking-online.png',
                      width: 20,
                      height: 20,
                    ),
                  ), 
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 10),
              Text(
                'الصور',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  TextButton.icon(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      'التقاط صورة',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => pickImage(ImageSource.camera),
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 66, 49, 76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    label: Text(
                      'اختيار صورة',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => pickImage(ImageSource.gallery),
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 66, 49, 76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
Container(
  height: 120,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _images.isNotEmpty ? _images.length : 1, // Display default image if _images is empty
    itemBuilder: (ctx, index) {
      if (_images.isEmpty) {
        return GestureDetector(
          onTap: () {
            setState(() {
              // No action needed when tapping on the default image
            });
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                width: 120,
                height: 150,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 238, 227, 245),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('lib/icons/defaultImg.jpeg'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0, // Adjusted position
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 142, 27, 19),
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        // No need to remove the default image here
                      });
                    },
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        int imageIndex = index;
        return GestureDetector(
          onTap: () {
            // Add any onTap logic for the selected images
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                width: 120,
                height: 150,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 238, 227, 245),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_images[imageIndex]),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0, // Adjusted position
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 142, 27, 19),
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(imageIndex);
                      });
                    },
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    },
  ),
),

        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _addEventToFirestore,
          child: Text(
            'اضافة الفعالية أو الخبر',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 66, 49, 76),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    ),
  ),
));
}
}