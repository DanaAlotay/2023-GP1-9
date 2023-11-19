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
                        }),
                      ],
                    ),
                  )))),
    );
  }
}
