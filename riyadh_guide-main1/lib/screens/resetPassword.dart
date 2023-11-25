/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/screens/reusable.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add a form key
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "إعادة تعيين كلمة المرور",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/icons/rig&re.JPEG'), // Path to your image
              fit: BoxFit.cover, // You can adjust the fit to your preference
            ),
          ),
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 130,
                          height: 220,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('lib/icons/rePP.png')),
                          ),
                        ),
                        const Text(
                            "أدخل بريدك الالكتروني لإعادة تعيين كلمة المرور",
                            style: TextStyle(
                                color: Color.fromARGB(255, 76, 53, 87))),
                        const SizedBox(
                          height: 20,
                        ),
                        reusableTextField(
                          "البريد الالكتروني",
                          Icons.email_outlined,
                          false,
                          _emailTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال بريدك الإلكتروني';
                            } else if (!isValidEmail(value)) {
                              return 'البريد الإلكتروني غير صالح';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        /*firebaseUIButton(context, "إعادة تعيين كلمة المرور",
                            () {
                          // Validate the form
                          if (_formKey.currentState!.validate()) {
                            //Reset Password
                            FirebaseAuth.instance
                                .sendPasswordResetEmail(
                                    email: _emailTextController.text)
                                .then((value) => Navigator.of(context).pop());
                          }
                        })*/
                        // Check if email exists
                        firebaseUIButton(context, "إعادة تعيين كلمة المرور",
                            () async {
                          // Validate the form
                          if (_formKey.currentState!.validate()) {
                            try {
                              var email = _emailTextController.text.trim();

                              // Reset Password
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);

                              // Password reset email sent successfully
                              Navigator.of(context).pop();
                            } catch (e) {
                              print('Error resetting password: $e');
                              // Check the error code to determine the reason for failure
                              if (e is FirebaseAuthException) {
                                print(
                                    'FirebaseAuthException code: ${e.code}'); // Add this line to print the error code
                                if (e.code == 'user-not-found') {
                                  // Email not registered
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'البريد الإلكتروني غير مسجل. يرجى التحقق من البريد الإلكتروني.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                                } else if (e.code == 'invalid-email') {
                                  // Invalid email format
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'صيغة البريد الإلكتروني غير صالحة. يرجى التحقق من البريد الإلكتروني.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Handle other errors
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'حدث خطأ أثناء إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى.',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        }),

                        /*firebaseUIButton(context, "إعادة تعيين كلمة المرور",
                            () async {
                          // Validate the form
                          if (_formKey.currentState!.validate()) {
                            try {
                              // Check if email exists
                              var email = _emailTextController.text.trim();
                              var signInMethods = await FirebaseAuth.instance
                                  .fetchSignInMethodsForEmail(email);

                              // If signInMethods is not empty, the email is registered
                              if (signInMethods.isNotEmpty) {
                                // Reset Password
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: _emailTextController.text);
                                // Password reset email sent successfully
                                Navigator.of(context).pop();
                              } else {
                                // Email not registered
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'البريد الإلكتروني غير مسجل. يرجى التحقق من البريد الإلكتروني.',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error checking email existence: $e');
                              // Handle error if any
                            }
                          }
                        }),*/
                      ],
                    ),
                  )))),
    );
  }
}*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/screens/reusable.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add a form key
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "إعادة تعيين كلمة المرور",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // White background
          Container(
            height: MediaQuery.of(context).size.height * 0.28,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/icons/roro.JPG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White background and content
          Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25),
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),

              ///here
              child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 120,
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('lib/icons/rePP.png'),
                                        // fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                                "أدخل بريدك الالكتروني لإعادة تعيين كلمة المرور",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 76, 53, 87))),
                            const SizedBox(
                              height: 10,
                            ),
                            reusableTextField(
                              "البريد الالكتروني",
                              Icons.email_outlined,
                              false,
                              _emailTextController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال بريدك الإلكتروني';
                                } else if (!isValidEmail(value)) {
                                  return 'البريد الإلكتروني غير صالح';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            // Check if email exists
                            firebaseUIButton(context, "إعادة تعيين كلمة المرور",
                                () async {
                              // Check if email field is empty or null
                              if (_emailTextController.text.trim().isEmpty ||
                                  _emailTextController.text.trim() == null) {
                                const snackBar = SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    'يرجى إدخال عنوان بريد إلكتروني.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );

                                // Show the SnackBar
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                return;
                              }
                              bool emailExists = await FirebaseFirestore
                                  .instance
                                  .collection('user')
                                  .where('email',
                                      isEqualTo:
                                          _emailTextController.text.trim())
                                  .get()
                                  .then((value) =>
                                      value.docs.isEmpty ? false : true);
                              if (emailExists == false) {
                                const snackBar = SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    'البريد الإلكتروني غير مسجل. يرجى التحقق من البريد الإلكتروني.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                return;
                              }

                              // Validate the form
                              if (_formKey.currentState!.validate()) {
                                try {
                                  var email = _emailTextController.text.trim();

                                  // Reset Password
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(email: email);
                                  const snackBar = SnackBar(
                                    backgroundColor: Colors.white,
                                    content: Text(
                                      'تم الارسال لبريدك الالكتروني',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);

                                  // Password reset email sent successfully
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  print('Error resetting password: $e');
                                  // Check the error code to determine the reason for failure
                                  if (e is FirebaseAuthException) {
                                    print(
                                        'FirebaseAuthException code: ${e.code}'); // Add this line to print the error code
                                    if (e.code == 'invalid-email') {
                                      // Invalid email format
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'صيغة البريد الإلكتروني غير صالحة. يرجى التحقق من البريد الإلكتروني.',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Handle other errors
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'حدث خطأ أثناء إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى.',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              }
                            }),
                          ],
                        ),
                      )))),
        ],
      ),
    );
  }
}
