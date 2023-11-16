import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

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

  String? _selectedCategory = 'c1'; // Set a default value

  List<File> _images = []; // List to store the selected images

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save the form data to the database

      final placeData = {
        'categoryID': _selectedCategory ?? '',
        'name': _nameController.text,
        'description': _descriptionController.text,
        'opening_hours': _workingHoursController.text,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت الاضافة بنجاح '),
        ),
      );

      // Reset the form After adding
      _formKey.currentState!.reset();
      _categoryController.clear();
      _nameController.clear();
      _descriptionController.clear();
      _workingHoursController.clear();
      setState(() {
        _images.clear();
      });
    }
  }

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
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اضافة مكان'),
        backgroundColor: Color.fromARGB(255, 66, 49, 76), // Box color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  //labelText: 'التصنيف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.category),
                  fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: 'c1',
                    child: Text('مطاعم'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'c2',
                    child: Text('مقاهي'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'c6',
                    child: Text('معالم سياحيه'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'c5',
                    child: Text('ترفيه'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'c4',
                    child: Text('مراكز تجميل'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'c3',
                    child: Text('تسوق'),
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
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المكان',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
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
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
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
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _workingHoursController,
                decoration: InputDecoration(
                  labelText: 'ساعات العمل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
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
              ),
              SizedBox(height: 10),
              Text(
                'الصور',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              /*
              Row(
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('التقاط صورة'),
                    onPressed: () => pickImage(ImageSource.camera),
                  ),
                  SizedBox(width: 10),
                  TextButton.icon(
                    icon: Icon(Icons.image),
                    label: Text('اختيار صورة'),
                    onPressed: () => pickImage(ImageSource.gallery),
                  ),
                ],
              ),*/

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
                        borderRadius: BorderRadius.circular(8.0),
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
                        borderRadius: BorderRadius.circular(8.0),
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
                  itemCount: _images.length,
                  itemBuilder: (ctx, index) => Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 238, 227, 245),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_images[index]),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Callback function when the button is pressed

                  _submitForm();
                },
                child: Text(
                  'اضافة مكان',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 66, 49, 76),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddPlaceForm(),
  ));
}

/* 

  

  

import 'package:flutter/material.dart'; 

  

  

import 'package:cloud_firestore/cloud_firestore.dart'; 

  

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

  String? _selectedCategory = 'c1'; // Set a default value 

  

  void _submitForm() { 

    if (_formKey.currentState!.validate()) { 

      _formKey.currentState!.save(); 

  

      // Save the form data to the database 

      FirebaseFirestore.instance.collection('place').add({ 

        'category_ID': _selectedCategory ?? '', // Add a null check here 

        'name': _nameController.text, 

        'description': _descriptionController.text, 

        'opening_hours': _workingHoursController.text, 

      }); 

  

      // Reset the form 

      _formKey.currentState!.reset(); 

    } 

  } 

  

  @override 

  Widget build(BuildContext context) { 

    return Scaffold( 

      appBar: AppBar( 

        title: Text('اضافة مكان'), 

      ), 

      body: Padding( 

        padding: EdgeInsets.all(16.0), 

        child: Form( 

          key: _formKey, 

          child: ListView( 

            children: [ 

              DropdownButtonFormField<String>( 

                value: _selectedCategory, 

                decoration: InputDecoration(labelText: 'التصنيف'), 

                items: [ 

                  DropdownMenuItem<String>( 

                    value: 'c1', 

                    child: Text('مطاعم'), 

                  ), 

                  DropdownMenuItem<String>( 

                    value: 'c2', 

                    child: Text('مقاهي'), 

                  ), 

                  DropdownMenuItem<String>( 

                    value: 'c6', 

                    child: Text('معالم سياحيه'), 

                  ), 

                  DropdownMenuItem<String>( 

                    value: 'c5', 

                    child: Text('ترفيه'), 

                  ), 

                  DropdownMenuItem<String>( 

                    value: 'c4', 

                    child: Text('مراكز تجميل'), 

                  ), 

                  DropdownMenuItem<String>( 

                    value: 'c3', 

                    child: Text('تسوق'), 

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

              TextFormField( 

                controller: _nameController, 

                decoration: InputDecoration(labelText: 'اسم المكان'), 

                validator: (value) { 

                  if (value == null || value.isEmpty) { 

                    return 'ادخل اسم المكان'; 

                  } 

                  return null; 

                }, 

              ), 

              TextFormField( 

                controller: _descriptionController, 

                decoration: InputDecoration(labelText: 'الوصف'), 

                validator: (value) { 

                  if (value == null || value.isEmpty) { 

                    return 'ادخل وصف المكان'; 

                  } 

                  return null; 

                }, 

              ), 

              TextFormField( 

                controller: _workingHoursController, 

                decoration: InputDecoration(labelText: 'اوقات العمل'), 

                validator: (value) { 

                  if (value == null || value.isEmpty) { 

                    return 'ادخل اوقات العمل '; 

                  } 

                  return null; 

                }, 

              ), 

              ElevatedButton( 

                onPressed: _submitForm, 

                child: Text('اضافة'), 

              ), 

            ], 

          ), 

        ), 

      ), 

    ); 

  } 

} 

  

class AddPlacePage extends StatelessWidget { 

  @override 

  Widget build(BuildContext context) { 

    return Scaffold( 

      appBar: AppBar( 

        title: Text('Add Place'), 

      ), 

      body: AddPlaceForm(), 

    ); 

  } 

} 

  

void main() { 

  runApp(MaterialApp( 

    title: 'Add Place', 

    home: AddPlacePage(), 

  )); 

} 

*/
