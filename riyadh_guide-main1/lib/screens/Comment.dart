import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentPage extends StatefulWidget {
  final String placeID;

  CommentPage({required this.placeID});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _commentController = TextEditingController();
  static const String _defaultProfileImage = 'lib/icons/defu.jpeg';
  List<Map<String, dynamic>> _comments = [];
  @override
  void initState() {
    super.initState();
    // Fetch comments for the place and update the _comments list
    fetchComments();
  }

  void fetchComments() {
    String placeId = widget.placeID; // Replace with the actual place ID

    if (placeId.isNotEmpty) {
      // Get a reference to the Firestore collection
      CollectionReference commentsCollection =
          FirebaseFirestore.instance.collection('comments');

      // Query the comments for the specific place ID
      commentsCollection
          .where('placeId', isEqualTo: placeId)
          .get()
          .then((QuerySnapshot snapshot) {
        List<Map<String, dynamic>> comments = [];
        snapshot.docs.forEach((doc) async {
          String commentId = doc.id;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String userId = data['userId'] as String;
          String comment = data['comment'] as String;

          // Fetch the username from the user collection based on userId
          String username = await fetchUsername(userId);

          comments.add({
            'id': commentId, // Added commentId to the comment data
            'username': username,
            'comment': comment,
            'userid': userId,
          });
        });
        setState(() {
          _comments = comments;
        });
      }).catchError((error) {
        print('Failed to fetch comments: $error');
      });
    }
  }

  Future<String> fetchUsername(String userId) async {
    // Get a reference to the Firestore collection
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('user');

    // Fetch the username from the user collection based on userId
    DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String username = userData['name'] as String;

    return username;
  }

  String getCurrentUserId() {
    String currentUserId = '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      currentUserId = user.uid;
    }

    return currentUserId;
  }

  void _addComment() {
    String comment = _commentController.text;
    String userId = getCurrentUserId();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا تملك حساب'),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => account()),
      );
      return;
    }

    setState(() {
      _comments.add({
        'username': '', // The username will be fetched later
        'comment': comment,
        'userid': userId,
      });
      _commentController.clear();
    });

    // Store the comment in the database
    addComment(comment);
  }

  void addComment(String comment) async {
    String userId = getCurrentUserId(); // Replace with the actual user ID
    String placeId = widget.placeID; // Replace with the actual place ID

    // Get the username from the user collection based on userId
    String username = await fetchUsername(userId);

    // Get a reference to the Firestore collection
    CollectionReference commentsCollection =
        FirebaseFirestore.instance.collection('comments');

    // Create a new document in the comments collection
    DocumentReference newCommentRef = await commentsCollection.add({
      'comment': comment,
      'userId': userId,
      'placeId': placeId,
      'name': username,
    });

    String commentId =
        newCommentRef.id; // Get the ID of the newly created comment

    // Update the comment with the comment ID
    setState(() {
      _comments.last['id'] = commentId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت اضافة التعليق بنجاح'),
        backgroundColor: Color.fromARGB(181, 203, 145, 210),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteComment(int index) {
    String commentId = _comments[index]['id'] as String;

    // Get a reference to the Firestore collection
    CollectionReference commentsCollection =
        FirebaseFirestore.instance.collection('comments');

    // Delete the comment from the comments collection
    commentsCollection.doc(commentId).delete().then((value) {
      setState(() {
        _comments.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف التعليق بنجاح'),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      print('Failed to delete comment: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height, // Set a specific height
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color.fromARGB(
              255,
              222,
              217,
              217,
            ), // Set the background color to gray
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'اضافة تعليق',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                /*
                TextButton(
                  child: Text(
                    'ارسل',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _addComment,
                ),*/
                Tooltip(
                  message: 'ارسل',
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          if (_comments.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  String username = _comments[index]['username'] as String;
                  String comment = _comments[index]['comment'] as String;
                  String userId = _comments[index]['userid'] as String;
                  bool isCurrentUser = userId == getCurrentUserId();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(_defaultProfileImage),
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: username + '\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 78, 77, 77),
                                ),
                              ),
                              TextSpan(
                                text: comment,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: isCurrentUser
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteComment(index);
                                },
                              )
                            : null,
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          if (_comments.isEmpty)
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height -
                    150, // Adjust the height as per your need
                child: Center(
                  child: Text(
                    'لا يوجد تعليقات ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/widgets/app_icon.dart';
import 'package:riyadh_guide/widgets/icon_and_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentPage extends StatefulWidget {
  final String placeID;

  CommentPage({required this.placeID});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _commentController = TextEditingController();
  static const String _defaultProfileImage = 'lib/icons/bg.jpg';
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    // Fetch comments for the place and update the _comments list
    fetchComments();
  }

  void fetchComments() {
    String placeId = widget.placeID; // Replace with the actual place ID

    if (placeId.isNotEmpty) {
      // Get a reference to the Firestore collection
      CollectionReference commentsCollection =
          FirebaseFirestore.instance.collection('comments');

      // Query the comments for the specific place ID
      commentsCollection
          .where('placeId', isEqualTo: placeId)
          .get()
          .then((QuerySnapshot snapshot) {
        List<Map<String, dynamic>> comments = [];
        snapshot.docs.forEach((doc) async {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String userId = data['userId'] as String;
          String comment = data['comment'] as String;

          // Fetch the username from the user collection based on userId
          String username = await fetchUsername(userId);

          comments.add({
            'username': username,
            'comment': comment,
          });
        });
        setState(() {
          _comments = comments;
        });
      }).catchError((error) {
        print('Failed to fetch comments: $error');
      });
    }
  }

  Future<String> fetchUsername(String userId) async {
    // Get a reference to the Firestore collection
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('user');

    // Fetch the username from the user collection based on userId
    DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String username = userData['name'] as String;

    return username;
  }

  String getCurrentUserId() {
    String currentUserId = '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      currentUserId = user.uid;
    }

    return currentUserId;
  }

  void _addComment() {
    String comment = _commentController.text;
    String userId = getCurrentUserId();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا تملك حساب'),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => account()),
      );
      return;
    }

    setState(() {
      _comments.add({
        'username': '', // The username will be fetched later
        'comment': comment,
        'userid': userId,
      });
      _commentController.clear();
    });

    // Store the comment in the database
    addComment(comment);
  }

  void addComment(String comment) async {
    String userId = getCurrentUserId(); // Replace with the actual user ID
    String placeId = widget.placeID; // Replace with the actual place ID

    // Get the username from the user collection based on userId
    String username = await fetchUsername(userId);

    // Get a reference to the Firestore collection
    CollectionReference commentsCollection =
        FirebaseFirestore.instance.collection('comments');

    // Create a new document in the comments collection
    commentsCollection.add({
      'comment': comment,
      'userId': userId,
      'placeId': placeId,
      'name': username,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت اضافة التعليق بنجاح'),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('اعد المحاولة'),
          backgroundColor: Color.fromARGB(181, 203, 145, 210),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height, // Set a specific height
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color.fromARGB(
              255,
              222,
              217,
              217,
            ), // Set the background color to gray
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'اضافة تعليق',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                    'ارسل',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
          Divider(),
          if (_comments.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  String username = _comments[index]['username'] as String;
                  String comment = _comments[index]['comment'] as String;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(_defaultProfileImage),
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: username + '\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 78, 77, 77),
                                ),
                              ),
                              TextSpan(
                                text: comment,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          if (_comments.isEmpty)
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height -
                    150, // Adjust the height as per your need
                child: Center(
                  child: Text(
                    'لا يوجد تعليقات ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
*/