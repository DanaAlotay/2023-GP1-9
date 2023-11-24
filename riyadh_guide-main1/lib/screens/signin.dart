import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/adminHome.dart';
import 'package:riyadh_guide/screens/resetPassword.dart';
import 'package:riyadh_guide/screens/signUp.dart';
import 'package:riyadh_guide/screens/squareTile.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/screens/reusable.dart';
import 'package:riyadh_guide/services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  //email or password incorrect
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: <Widget>[
                    const Text("تسجيل الدخول",
                        style: TextStyle(
                            color: Color.fromARGB(255, 99, 62, 118),
                            fontSize: 23,
                            fontWeight: FontWeight.bold)),

                    reusableTextField("الايميل الالكتروني",
                        Icons.email_outlined, false, _emailTextController),
                    const SizedBox(
                      height: 10,
                    ),
                    reusableTextField("كلمة المرور", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 3,
                    ),
                    forgetPassword(context),
                    // Display the error message
                    Text(
                      _errorMessage ?? '',
                      style: TextStyle(color: Colors.red),
                    ),
                    firebaseUIButton(context, "الدخول", () {
                      setState(() {
                        _errorMessage = null;
                      });

                      // Check if email and password are not null
                      if (_emailTextController.text == null ||
                          _emailTextController.text.trim().isEmpty ||
                          _passwordTextController.text == null ||
                          _passwordTextController.text.trim().isEmpty) {
                        setState(() {
                          _errorMessage =
                              "الرجاء تعبئة جميع المعلومات المطلوبة";
                        });
                      } else if (!isValidEmail(_emailTextController.text)) {
                        setState(() {
                          _errorMessage = "البريد الإلكتروني غير صالح";
                        });
                      }
                      if (_errorMessage != null) {
                        return;
                      }

                      // Continue with the sign-in process
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        // Get the currently signed-in user
                        User? user = FirebaseAuth.instance.currentUser;

                        // Assuming you have a Firestore collection named 'user'
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(user?.uid)
                            .get()
                            .then((userData) {
                          // Assuming 'type' is a field in your user data
                          String userType = userData['type'];

                          if (userType == 'admin') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminPage()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomeScreen()));
                          }
                        }).catchError((error) {
                          print("Error fetching user data: $error");
                        });
                      }).catchError((error) {
                        print(
                            "An error occurred during sign in: ${error.toString()}");
                        if (error is FirebaseAuthException) {
                          print("FirebaseAuthException code: ${error.code}");
                          setState(() {
                            if (error.code == 'user-not-found' ||
                                error.code == 'wrong-password') {
                              _errorMessage =
                                  "البريد الإلكتروني أو كلمة المرور غير صحيحة";
                            } else if (error.code ==
                                'INVALID_LOGIN_CREDENTIALS') {
                              _errorMessage =
                                  "البريد الإلكتروني أو كلمة المرور غير صحيحة";
                            } else {
                              _errorMessage = "حدثت مشكلة أثناء تسجيل الدخول";
                            }
                          });
                        }
                      });
                    }),
                    const SizedBox(width: 20),
                    //google sign in button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareTile(
                          onTap: () => AuthService().SignInWithGoogle(),
                          imagePath: 'lib/icons/Google.jpg',
                        ),
                      ],
                    ),

                    signUpOption(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لا تملك حساب؟",
            style: TextStyle(
                color: Color.fromARGB(200, 83, 56, 97), fontSize: 14)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " تسجيل مستخدم جديد",
            style: TextStyle(
                color: Color.fromARGB(255, 83, 56, 97),
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "نسيت كلمة المرور؟",
          style:
              TextStyle(color: Color.fromARGB(200, 83, 56, 97), fontSize: 12),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
