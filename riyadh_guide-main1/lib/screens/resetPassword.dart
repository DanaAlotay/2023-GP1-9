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
                              // Check if email format is not valid
                              if (!RegExp(
                                      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                  .hasMatch(_emailTextController.text.trim())) {
                                const snackBar = SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    'صيغة البريد الإلكتروني غير صالحة. يرجى التحقق من البريد الإلكتروني.',
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

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);

                                  // Password reset email sent successfully
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  print('Error resetting password: $e');
                                  // Check the error code to determine the reason for failure
                                  if (e is FirebaseAuthException) {
                                    print(
                                        'Actual FirebaseAuthException code: ${e.code}'); // Add this line to print the error code
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
                                      print('Other error: ${e.message}');
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
