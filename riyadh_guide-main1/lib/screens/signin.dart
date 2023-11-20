/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/resetPassword.dart';
import 'package:riyadh_guide/screens/signUp.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/screens/reusable.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  //email or peassword incorrect
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/icons/logI.JPEG'), // Path to your image
            fit: BoxFit.cover, // You can adjust the fit to your preference
          ),
        ),

        //start of single child
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 100, // Adjust the width to your preference
                  height: 100, // Adjust the height to your preference
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'lib/icons/newLogo.png'), // Path to your logo image
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
                const Text("تسجيل الدخول",
                    style: TextStyle(
                        color: Color.fromARGB(255, 99, 62, 118),
                        fontSize: 23,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("الايميل الالكتروني", Icons.email_outlined,
                    false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("كلمة المرور", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(
                  height: 5,
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
                      _errorMessage = "الرجاء تعبئة جميع المعلومات المطلوبة";
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen()));
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
                        } else if (error.code == 'INVALID_LOGIN_CREDENTIALS') {
                          _errorMessage =
                              "البريد الإلكتروني أو كلمة المرور غير صحيحة";
                        } else {
                          _errorMessage = "حدثت مشكلة أثناء تسجيل الدخول";
                        }
                      });
                    }
                  });
                  //
                }),
                signUpOption()
              ],
            ),
          ),
        ),
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
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/resetPassword.dart';
import 'package:riyadh_guide/screens/signUp.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:riyadh_guide/screens/reusable.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  //email or peassword incorrect
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/icons/roro.JPG'), // Path to your image
                  fit:
                      BoxFit.cover, // You can adjust the fit to your preference
                ),
              ),

              //start of single child
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/icons/newLogo.png'),
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).size.height * 0.05,
                  20,
                  0,
                ),
                child: Column(
                  children: <Widget>[
                    const Text("تسجيل الدخول",
                        style: TextStyle(
                            color: Color.fromARGB(255, 99, 62, 118),
                            fontSize: 23,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField("الايميل الالكتروني",
                        Icons.email_outlined, false, _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("كلمة المرور", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 5,
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WelcomeScreen()));
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
                      //
                    }),
                    signUpOption()
                  ],
                ),
              ),
            ),
          ],
        ),
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
