import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/signin.dart';
import 'package:riyadh_guide/screens/adminHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class adminprofile extends StatefulWidget {
  const adminprofile({super.key});

  @override
  State<adminprofile> createState() => _adminprofile();
}

class _adminprofile extends State<adminprofile> {
  @override
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  // TextEditingController _cardsController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  //String? _selectedcard;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          String username = documentSnapshot['name'];
          String email = documentSnapshot['email'];
          List<dynamic>? cards;

          setState(() {
            _usernameController.text = username;
            _emailController.text = email;
          });
        }
      }).catchError((error) {
        // Handle error retrieving user data
      });
    }
  }

  bool hasSpecialCharacter(String value) {
    // Define a list of special characters
    List<String> specialCharacters = [
      '!',
      '@',
      '#',
      '\$',
      '%',
      '^',
      '&',
      '*',
      '_',
      '-',
      '(',
      ')',
      '\\',
      '?'
    ];

    // Check if the value contains any special character
    for (var character in specialCharacters) {
      if (value.contains(character)) {
        return true;
      }
    }

    return false;
  }

  void resetPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String oldPassword = '';
        String newPassword = '';
        String authenticationErrorMessage = '';
        String newPasswordErrorMessage = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('تغيير كلمة المرور'),
              content: Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'ادخل كلمة المرور القديمة',
                        ),
                        onChanged: (value) {
                          oldPassword = value;
                        },
                        obscureText: true,
                      ),
                      if (authenticationErrorMessage.isNotEmpty)
                        Visibility(
                          visible: authenticationErrorMessage.isNotEmpty,
                          maintainState: true,
                          child: Text(
                            authenticationErrorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'ادخل كلمة المرور الجديدة',
                          errorText: newPasswordErrorMessage.isNotEmpty
                              ? newPasswordErrorMessage
                              : null,
                        ),
                        onChanged: (value) {
                          newPassword = value;
                        },
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('الغاء'),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      // Validate new password
                      if (newPassword.isEmpty) {
                        setState(() {
                          newPasswordErrorMessage =
                              'كلمة المرور الجديدة لا يمكن أن تكون فارغة.';
                        });
                      } else if (newPassword.length < 8) {
                        setState(() {
                          newPasswordErrorMessage =
                              ' يجب أن تحتوي على 8 أحرف على الأقل.';
                        });
                      } else if (!hasSpecialCharacter(newPassword)) {
                        setState(() {
                          newPasswordErrorMessage =
                              'يجب أن تحتوي على حرف خاص واحدعلى الأقل';
                        });
                      } else {
                        // Clear new password error message
                        setState(() {
                          newPasswordErrorMessage = '';
                        });

                        // Authenticate old password
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          String? email = user.email;

                          if (email != null) {
                            AuthCredential credential =
                                EmailAuthProvider.credential(
                                    email: email, password: oldPassword);

                            user
                                .reauthenticateWithCredential(credential)
                                .then((authResult) {
                              // Old password authentication successful
                              // Clear authentication error message
                              setState(() {
                                authenticationErrorMessage = '';
                              });

                              // Proceed with password update
                              user.updatePassword(newPassword).then((_) {
                                // Password updated successfully
                                Navigator.pop(context); // Close the dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('تم تغيير كلمة المرور'),
                                      content:
                                          Text('تم تحديث كلمة المرور بنجاح.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('موافق'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }).catchError((error) {
                                // Handle error updating password
                                if (error is PlatformException) {
                                  String errorMessage =
                                      error.message ?? 'حدث خطأ.';
                                  Navigator.pop(context); // Close the dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('خطأ في تحديث كلمة المرور'),
                                        content: Text(errorMessage),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('موافق'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              });
                            }).catchError((error) {
                              // Handle error authenticating old password
                              if (error is FirebaseAuthException) {
                                String errorMessage = 'كلمة المرور غير صحيحة';
                                setState(() {
                                  authenticationErrorMessage = errorMessage;
                                });
                              }
                            });
                          }
                        }
                      }
                    },
                    child: Text('تغيير'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show the sign-out confirmation dialog
  void showSignOutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد تسجيل الخروج'),
          content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('موافق'),
              onPressed: () {
                signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Sign-out function
  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
    // Show a snackbar indicating successful sign out
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الخروج بنجاح'),
        backgroundColor: Color.fromARGB(181, 203, 145, 210),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('حسابي'),
          backgroundColor: Color.fromARGB(255, 211, 198, 226),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAdminHomePage(),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color:
                          Color.fromARGB(255, 8, 8, 8), // Set the outline color
                      width: 1.0, // Set the outline width
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.person,
                        color: Color.fromARGB(255, 69, 51, 80)),
                    title: TextFormField(
                      readOnly: true,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        labelStyle: TextStyle(fontSize: 18.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(
                      color:
                          Color.fromARGB(255, 8, 8, 8), // Set the outline color
                      width: 1.0, // Set the outline width
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Color.fromARGB(255, 69, 51, 80),
                    ),
                    title: TextFormField(
                      readOnly: true,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الالكتروني',
                        labelStyle: TextStyle(fontSize: 18.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(height: 50.0),
                ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(
                        color: const Color.fromARGB(
                            255, 12, 12, 12), // Set the outline color
                        width: 1.0, // Set the outline width
                      ),
                    ),
                    padding: EdgeInsets.all(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Color.fromARGB(255, 69, 51, 80),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'تغيير كلمة المرور',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Hero(
                  tag: 'uniqueTagForFab', // Assign a unique tag
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 99, 62, 118),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showSignOutConfirmationDialog(context);
                      },
                      icon: Icon(Icons.logout_rounded),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
