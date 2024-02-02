import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:riyadh_guide/screens/Adminaddview.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';

class AddPlaceForm extends StatefulWidget {
  @override
  _AddPlaceFormState createState() => _AddPlaceFormState();
}

class _AddPlaceFormState extends State<AddPlaceForm> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _workingHoursController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  final _percentageController = TextEditingController();

  String? _selectedCategory = 'c1'; // Set a default value
  String? _classificationController = "1";
  int _percentageValue = 0;
  List<File> _images = []; // List to store the selected images

  bool _isLoading = false;
  bool isDefaultImageSelected = true;
  @override
  void initState() {
    super.initState();
    isDefaultImageSelected = true; // Initialize the variable
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the form data to the database

      final placeData = {
        'categoryID': _selectedCategory ?? '',
        'name': _nameController.text,
        'description': _descriptionController.text,
        'opening_hours': _workingHoursController.text,
        'website': _websiteController.text,
        'classification': _classificationController ?? '',
        'percentage': _percentageValue,
      };

      // Add the place data to Firestore and get the document ID

      final DocumentReference placeRef =
          await FirebaseFirestore.instance.collection('place').add(placeData);

      String placeId = placeRef.id;

      // Upload the images to Firestore

      List<String> imageUrls = await uploadImages(placeId);

      // Update the place document with the image URLs

      await placeRef.update({
        'images': imageUrls,
        'placeID': placeId,
      });

      // Show a snackbar message indicating successful addition

      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('تمت الاضافة بنجاح '),
              backgroundColor: Color.fromARGB(181, 203, 145, 210),
            ),
          )
          .closed
          .then((_) {
        // Navigate to the PageDetails screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Adminaddbview(placeID: placeId),
          ),
        );
      });

      // Reset the form After adding
      _formKey.currentState!.reset();
      _categoryController.clear();
      _nameController.clear();
      _descriptionController.clear();
      _workingHoursController.clear();
      _websiteController.clear();
      _classificationController;
      _percentageController.clear();
      setState(() {
        bool isDefaultImageSelected = true;
        _images.clear();
      });
    }
  }

// For secuirty Reasons chatgpt key stored in db

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

// old code
/*
  Future<List<String>> uploadImages(String placeId) async {
    List<String> imageUrls = [];

    for (var i = 0; i < _images.length; i++) {
      File image = _images[i];

      // Generate a unique filename for each image

      String fileName = 'place_$placeId$i.jpg';

      // Upload the image to Firestore

      Reference storageRef =
          FirebaseStorage.instance.ref().child('images').child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);

      // Get the download URL of the uploaded image

      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }*/
  Future<List<String>> uploadImages(String placeId) async {
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
      String fileName = 'place_$placeId$i.jpg';

      // Upload the image to Firestore
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images').child(fileName);

      UploadTask uploadTask = storageRef.putFile(image);

      // Get the download URL of the uploaded image
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

      String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

// old code
/*
  Future<void> pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);

      // Get the temporary directory path
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Generate a unique filename for the image
      String fileName = 'place_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a new File object with the temporary path and filename
      File tempImage = await imageFile.copy('$tempPath/$fileName');

      setState(() {
        _images.add(tempImage);
      });
    }
  }
*/

// New code
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
        title: Text('اضافة مكان'),
        backgroundColor: Color.fromARGB(255, 66, 49, 76),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPlaces(),
              ),
            );
          },
        ), // Box color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                height: 80,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  //Edit image icon
                  /*
                  decoration: InputDecoration(
                    //labelText: 'التصنيف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    prefixIcon: Icon(Icons.category),
                    fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                  ),*/ //End edit image icon old

                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
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
                    // fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                    // filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
                  ),

                  items: [
                    DropdownMenuItem<String>(
                      value: 'c1',
                      child: Text(
                        'مطاعم',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'c2',
                      child: Text(
                        'مقاهي',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'c6',
                      child: Text(
                        'معالم سياحيه',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'c5',
                      child: Text(
                        'ترفيه',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'c4',
                      child: Text(
                        'مراكز تجميل',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'c3',
                      child: Text(
                        'تسوق',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'اختر التصنيف';
                    }

                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              //old
              /*
              TextFormField(
                controller: _nameController,
              
                decoration: InputDecoration(
                  labelText: 'اسم المكان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  prefixIcon: Icon(Icons.place),
                  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل اسم المكان';
                  }

                  return null;
                },
              ),*/
              // end old

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المكان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),

                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                          'lib/icons/p.jpeg',
                          width: 30,
                          height: 30,
                          //color: Color.fromARGB(255, 8, 2, 69),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  // fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  // filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل اسم المكان';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              //old
/*
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  hintText:
                      '   للاستفادة من خدمة كتابة الوصف باستخدام الذكاء الاصطناعي ادخل مثلا : اكتب وصف لمعلم سياحي اسمه حي طريف التاريخي ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                  prefixIcon: Icon(Icons.description),
                  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل الوصف';
                  }

                  return null;
                },
              ), // end old
*/

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  hintText:
                      'للاستفادة من خدمة كتابة الوصف باستخدام الذكاء الاصطناعي ادخل مثلا: اكتب وصف لمعلم سياحي اسمه حي طريف التاريخي',
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
                      SizedBox(width: 8),
                    ],
                  ),
                  //  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  //filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل الوصف';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 30.0,
                width: 150,
              ),
              //old
              /*
              Container(
                height: 80,

                // Set the desired height here
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
                      Color.fromARGB(255, 143, 129, 152),
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
                      : Text('انشاء الوصف باستخدام الذكاء الاصطناعي'),
                ),
              ),*/
              Container(
                height: 80,
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

              SizedBox(height: 16.0),
              /*
              TextFormField(
                controller: _workingHoursController,
                decoration: InputDecoration(
                  labelText: 'ساعات العمل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  prefixIcon: Icon(Icons.access_time),
                  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل ساعات العمل';
                  }

                  return null;
                },
              ),*/

              TextFormField(
                controller: _workingHoursController,
                decoration: InputDecoration(
                  labelText: 'ساعات العمل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'lib/icons/cl.jpeg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  // fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  // filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ادخل ساعات العمل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.0),
// Classification and percentage
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _classificationController,
                      onChanged: (value) {
                        setState(() {
                          _classificationController = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: "1",
                          child: Text(
                            "ممتاز",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "2",
                          child: Text(
                            "جيّد",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "3",
                          child: Text(
                            "سيء",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "4",
                          child: Text(
                            "لم يحدد بعد",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'التصنيف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        // Add other styling properties as needed
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  /*// Add some spacing between the fields
                  Expanded(
                    child: TextFormField(
                      controller: _percentageController,
                      decoration: InputDecoration(
                        labelText: ' نسبة الاعجاب',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(8),
                        ),
                        // Add other styling properties as needed
                      ),
                    ),
                  ),*/
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'نسبة الاعجاب بالمكان: ${_percentageValue.toStringAsFixed(0)}',
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
                ],
              ),

// website
              SizedBox(height: 16.0),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: ' الموقع الالكتروني ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      'lib/icons/web.jpeg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                  // fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  // filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '  ادخل الموقع الالكتروني ';
                  }
                  return null;
                },
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
              /*
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (ctx, index) => GestureDetector(
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 120,
                          height: 150,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 238, 227, 245),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(_images[index]),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 1 / 2,
                          right: 1 / 2,
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
                                  _images.removeAt(index);
                                  //deleteImage(context,_images, index); // Remove the image URL from the list
                                });
                              },
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length +
                      (isDefaultImageSelected
                          ? 1
                          : 0), // Add 1 for the default image if it is selected
                  itemBuilder: (ctx, index) {
                    if (index == 0 && isDefaultImageSelected) {
                      // Display the default image
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 238, 227, 245),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'lib/icons/defaultImg.jpeg'), // Add the default image path
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 1 / 2,
                              right: 1 / 2,
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
                                      _images.removeWhere((image) =>
                                          image.path ==
                                          'lib/icons/defaultImg.jpeg');
                                      isDefaultImageSelected = false;
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
                      // Display the selected images
                      int imageIndex = isDefaultImageSelected
                          ? index - 1
                          : index; // Adjust the index to match the _images list
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
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
                              left: 1 / 2,
                              right: 1 / 2,
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

              Container(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // Callback function when the button is pressed

                    _submitForm();
                  },
                  child: Text(
                    'اضافة',
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
            ],
          ),
        ),
      ),
    );
  }
}
