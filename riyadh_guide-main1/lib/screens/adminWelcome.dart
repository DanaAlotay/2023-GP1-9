import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:riyadh_guide/screens/signUp.dart';
import 'package:riyadh_guide/screens/signin.dart';

class AdminWelcome extends StatefulWidget {
  @override
  _AdminWelcomeState createState() => _AdminWelcomeState();
}

class _AdminWelcomeState extends State<AdminWelcome> {
  Color buttonOColor = Color.fromARGB(255, 176, 160, 193);
  Color buttonSColor = Color.fromARGB(255, 176, 160, 193);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 420,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -40,
                    height: 370,
                    width: width,
                    child: FadeInUp(
                      duration: Duration(seconds: 1),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/icons/bkph.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    height: 320,
                    width: width + 5,
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/icons/rho.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 325,
                    left: 0,
                    right: 0,
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Image.asset(
                        'lib/icons/rgLogo.png',
                        height: 94,
                        width: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: Text(
                      "دليلك للمتعة",
                      style: TextStyle(
                        color: Color.fromARGB(255, 105, 86, 124),
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          buttonOColor = Color.fromARGB(255, 93, 77, 111);
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      color: buttonOColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
