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
                  })
                      //.onError((error, stackTrace) {
                      //   //print("Error ${error.toString()}");
                      //   if (error is FirebaseAuthException) {
                      //     if (error.code == 'user-not-found' ||
                      //         error.code == 'wrong-password') {
                      //       // Handle user not found error
                      //       _errorMessage =
                      //           " البريد الالكتروني أو كلمة المرور غير صحيحة";
                      //       // } else if (error.code == 'wrong-password') {
                      //       //   // Handle wrong password error
                      //       //   print("Wrong password");
                      //     } else {
                      //       // Handle other errors
                      //       // _errorMessage = "حصلت بعض المشاكل عند تسجيل الدخول";
                      //     }
                      //   }
                      // });
                      /* .catchError((error, stackTrace) {
                    print(
                        "An error occurred during sign in: ${error.toString()}");
                    if (error is FirebaseAuthException) {
                      print("FirebaseAuthException code: ${error.code}");
                      if (error.code == 'user-not-found' ||
                          error.code == 'wrong-password') {
                        // Handle user not found or wrong password error
                        setState(() {
                          _errorMessage =
                              " البريد الالكتروني أو كلمة المرور غير صحيحة";
                        });
                      } else if (error.code == 'INVALID_LOGIN_CREDENTIALS') {
                        // Handle invalid login credentials error
                        setState(() {
                          _errorMessage =
                              " البريد الالكتروني أو كلمة المرور غير صحيحة";
                        });
                      } else {
                        // Handle other errors
                        setState(() {
                          _errorMessage = "حصلت بعض المشاكل عند تسجيل الدخول";
                        });
                      }
                    }
                  });*/
                      .catchError((error) {
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
}

/*
//half screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/icons/Bk.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(.8),
                    Colors.black.withOpacity(.2),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).size.height * 0.2,
                  20,
                  0,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/icons/newLogo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    reusableTextField(
                      "الايميل الالكتروني",
                      Icons.email_outlined,
                      false,
                      _emailTextController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField(
                      "كلمة المرور",
                      Icons.lock_outline,
                      true,
                      _passwordTextController,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    forgetPassword(context),
                    firebaseUIButton(context, "الدخول", () {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text,
                      )
                          .then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomeScreen(),
                          ),
                        );
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    }),
                    signUpOption(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("لا تملك حساب؟",
            style: TextStyle(color: Color.fromARGB(179, 5, 5, 5))),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: const Text(
            " تسجيل مستخدم جديد",
            style: TextStyle(
                color: Color.fromARGB(255, 22, 20, 20),
                fontWeight: FontWeight.bold),
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
          style: TextStyle(color: Color.fromARGB(179, 10, 9, 9)),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPassword()),
        ),
      ),
    );
  }
}*/
