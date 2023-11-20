import 'package:flutter/material.dart';
import 'package:riyadh_guide/firebase_options.dart';
import 'package:riyadh_guide/screens/AdminPlaces.dart';
import 'package:riyadh_guide/screens/account.dart';
import 'package:riyadh_guide/screens/adminHome.dart';
import 'package:riyadh_guide/screens/navigate.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:riyadh_guide/screens/place_detail.dart';
import 'package:riyadh_guide/screens/signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localizations Sample App',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'AE'), // English
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      //try push
<<<<<<< HEAD
      home: SignInScreen(),
=======
      home: account(),
>>>>>>> 3cbf6898fe970848b8d54a0f388d68f935d66209
    );
  }
}
