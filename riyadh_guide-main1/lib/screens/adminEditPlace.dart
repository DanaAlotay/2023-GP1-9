import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';
import 'package:riyadh_guide/screens/adminViewEdits.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class adminEditPlace extends StatefulWidget {
  final String placeID;

  const adminEditPlace({Key? key, required this.placeID}) : super(key: key);

  @override
  _adminEditPlaceState createState() => _adminEditPlaceState();
}

class _adminEditPlaceState extends State<adminEditPlace> {
  late DocumentSnapshot? placeData;
  String _selectedCategory = '';
  List<String> imageUrls = [];
  String name = '';
  String description = '';
  String hours = '';
  String website = '';
  String classi = '';
  int per = 0;
  bool isLoading = true;
  bool check = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaceData();
    placeData = null;
  }

  Future<void> _fetchPlaceData() async {
    // Fetch place data from Firebase Firestore based on the placeID
    final placeDocument = await FirebaseFirestore.instance
        .collection('place')
        .doc(widget.placeID)
        .get();

    setState(() {
      placeData = placeDocument;
      imageUrls = List<String>.from(placeData?['images'] ?? []);
      _selectedCategory = placeData?['categoryID'] ?? '';
      name = placeData?['name'] ?? '';
      description = placeData?['description'] ?? '';
      hours = placeData?['opening_hours'] ?? '';
      website = placeData?['website'] ?? '';
      classi = placeData?['classification'] ?? '';
      per = placeData?['percentage'] ?? '';
      _nameController.text = name;
      _descriptionController.text = description;
      _workingHoursController.text = hours;
      _websiteController.text = website;

      isLoading = false;
    });
  }

  List<String> oldImageUrls = [];

  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  List<File> _images = [];

  Future<List<String>> uploadImages(String placeId) async {
    for (var i = 0; i < _images.length; i++) {
      File image = _images[i];

      // Generate a unique filename for each image

      var uuid = Uuid();
      String fileName = uuid.v4() + '.jpg';

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
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
      // Show a loading indicator
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('حذف - تعديل مكان'),
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
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // Callback function when the button is pressed

                      deletePlaceWithConfirmation(
                          context, widget.placeID, name);
                    },
                    child: Text(
                      'حذف المكان',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 121, 19, 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                /* //start old code
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    //labelText: 'التصنيف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    prefixIcon: Icon(Icons.category),
                    fillColor: Color.fromARGB(255, 238, 227, 245), // Box color
                    filled: true,
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
                ),*/ // end old

                // start new
                DropdownButtonFormField<String>(
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
                ), // end new
                SizedBox(height: 20.0),
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
                ),*/ // end old
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

// end new

                SizedBox(height: 16.0),
                /*
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
              ),*/
// old des
                /*     TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
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
                ),*/
                // start new des
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',

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

                // new work hours
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: classi,
                        onChanged: (value) {
                          setState(() {
                            classi = value!;
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
                            'نسبة الاعجاب بالمكان: ${per.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: per.toDouble(),
                            min: 0,
                            max: 100,
                            onChanged: (value) {
                              setState(() {
                                per = value.toInt();
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
                    itemCount: imageUrls.length,
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
                                image: NetworkImage(imageUrls[index]),
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
                                    imageUrls.removeAt(index);
                                    //deleteImage(context,imageUrls, index); // Remove the image URL from the list
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
                ),
                SizedBox(height: 20),
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
                ),
                SizedBox(height: 20),
                Container(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      await imageTest();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => adminViewEdits(
                              name: _nameController.text,
                              hours: _workingHoursController.text,
                              description: _descriptionController.text,
                              categoryID: _selectedCategory,
                              imageUrls: this.imageUrls,
                              website: this._websiteController.text),
                        ),
                      );
                    },
                    child: Text(
                      'معاينة صفحة المكان ',
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
                SizedBox(height: 30),
                Container(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Callback function when the button is pressed
                      await _submitForm();
                      if (check) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => adminEditPlace(
                              placeID: widget.placeID,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'حفظ التعديلات ',
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

  /* void updateFirebaseDescription(String newText) async {
    // Replace 'your_collection' and 'your_document_id' with your actual collection and document ID
    String collection = 'place';
    String documentId = widget.placeID;

    // Get reference to the document
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collection).doc(documentId);

    // Update the 'description' field in the document
    await documentReference.update({'description': newText});

    // Optionally, you can also print a message or show a notification
   // print('Description updated in Firebase: $newText');
  }
*/
  Future<List<String>> imageTest() async {
    List<String> newImageUrls = await uploadImages(widget.placeID);
    return newImageUrls;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String collection = 'place';
      String documentId = widget.placeID;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(collection).doc(documentId);
      String newCategoryID = _selectedCategory;
      String newName = _nameController.text;
      String newDescription = _descriptionController.text;
      String NewOpening_hours = _workingHoursController.text;
      String newWebsite = _websiteController.text;
      String newClass = classi;
      int newPer = per;
      List<String> newImageUrls = await uploadImages(documentId);
      await documentReference.update({
        'description': newDescription,
      });
      await documentReference.update({
        'name': newName,
      });
      await documentReference.update({
        'opening_hours': NewOpening_hours,
      });
      await documentReference.update({
        'categoryID': newCategoryID,
      });
      await documentReference.update({
        'images': newImageUrls,
      });
      await documentReference.update({
        'website': newWebsite,
      });
      await documentReference.update({
        'classification': newClass,
      });
      await documentReference.update({
        'percentage': newPer,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التعديل بنجاح '),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
        ),
      );
      check = true;
    }
  }
}

void deletePlaceWithConfirmation(
    BuildContext context, String placeID, String placeName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد'),
        content: Text(' هل أنت متأكد من حذف ' + placeName + '؟'),
        actions: <Widget>[
          TextButton(
            child: Text('إلغاء'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('حذف'),
            onPressed: () async {
              // Delete the document
              Navigator.of(context).pop();
              deletePlace(context, placeID);
              showSnackBar(context, 'تم الحذف بنجاح',
                  Color.fromARGB(181, 203, 145, 210));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminPlaces(),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> deletePlace(BuildContext context, String placeID) async {
  try {
    DocumentReference placeRef =
        FirebaseFirestore.instance.collection('place').doc(placeID);
    await placeRef.delete();
  } catch (e) {
    print('حدث خطأ أثناء الحذف: $e');
  }
}
/*
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Color.fromARGB(181, 203, 145, 210),
    ),
  );
}
*/

void showSnackBar(BuildContext context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
    ),
  );
}

void deleteImage(BuildContext context, List imgArray, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد'),
        content: Text(' هل أنت متأكد من حذف الصورة؟'),
        actions: <Widget>[
          TextButton(
            child: Text('إلغاء'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('حذف'),
            onPressed: () {
              imgArray.removeAt(index);
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
