import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import for FirebaseStorage
import 'package:image_picker/image_picker.dart'; // Import for ImagePicker
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:riyadh_guide/screens/AdminEvents.dart';
import 'package:uuid/uuid.dart';

class AdminEditEvent extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> eventData;

  AdminEditEvent({required this.eventData});
  @override
  _AdminEditEventState createState() => _AdminEditEventState();
}

class _AdminEditEventState extends State<AdminEditEvent> {
   TextEditingController _startdateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _imagesController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _reservationController = TextEditingController();

  List<File> _images = []; // List to store picked images
  bool isDefaultImageSelected =
      false; // Flag to track if default image is selected
 bool _isLoading = false;
 // initState method to set initial values for text controllers
  @override
  void initState() {
    super.initState();
    // Set initial values for text controllers with data from widget.eventData
    
    _nameController.text = widget.eventData['name'] ?? '';
    _timeController.text = widget.eventData['time'] ?? '';
    _startdateController.text = widget.eventData['start_date']?.toDate().toString() ?? '';
    _endDateController.text = widget.eventData['end_date']?.toDate().toString() ?? '';
    _descriptionController.text = widget.eventData['description'] ?? '';
    _locationController.text = widget.eventData['location'] ?? '';
    _reservationController.text = widget.eventData['reservation'] ?? '';

// Fetch image URLs from Firestore and download images
  List<String> imageUrls = List<String>.from(widget.eventData['images'] ?? []);
  downloadImages(imageUrls);
}
// Function to download images from Firebase Storage based on image URLs
void downloadImages(List<String> imageUrls) async {
  List<File> downloadedImages = [];
  for (String imageUrl in imageUrls) {
    try {
      // Download image from Firebase Storage using its URL
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Save the downloaded image to a temporary file
        Directory tempDir = await getTemporaryDirectory();
        File tempFile = File('${tempDir.path}/${Uuid().v4()}');
        await tempFile.writeAsBytes(response.bodyBytes);
        // Add the downloaded image file to the list
        downloadedImages.add(tempFile);
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }
  // Update the _images list with downloaded images
  setState(() {
    _images = downloadedImages;
  });
}

// Function to add event to Firestore
  void _addEventToFirestore() async {
     // Validate if all fields are not empty
  if (_startdateController.text.isEmpty ||
      _timeController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _endDateController.text.isEmpty ||
      _locationController.text.isEmpty ||
      _nameController.text.isEmpty ||
      _reservationController.text.isEmpty) {
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
  // Update event details in Firestore
  FirebaseFirestore.instance.collection('event').doc(widget.eventData.id).update({
    'name': _nameController.text,
    'time': _timeController.text,
    'start_date': startTimestamp,
    'end_date': endTimestamp,
    'description': _descriptionController.text,
    'location': _locationController.text,
    'reservation': _reservationController.text,
    'images': imageUrls, // Update to store image URLs
  }).then((value) {
    // Navigate to adminEvents screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminEvents()),
    );
    // Show SnackBar to notify the user of successful update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم التعديل بنجاح'),
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
          title: Text('التعديل على فعالية أو خبر'),
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
            'حفظ التعديلات على الفعالية أو الخبر',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
