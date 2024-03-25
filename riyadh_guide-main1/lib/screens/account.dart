import 'package:flutter/material.dart';
import 'package:riyadh_guide/screens/favourites.dart';
import 'package:riyadh_guide/screens/home_screen.dart';
import 'package:riyadh_guide/screens/news.dart';
import 'package:riyadh_guide/screens/search.dart';
import 'package:riyadh_guide/screens/signin.dart';
import 'package:riyadh_guide/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _accountState();
}

class _accountState extends State<account> {
  List<String> _cardsList = []; // Declare cardsList here
  int currentTab = 1;
  @override
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _cardsController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? _selectedcard;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  String uid = '';
  Map<String, String> _bankImages = {
    'بنك الراجحي': 'lib/icons/rajlogoR.png',
    'بريميوم': 'lib/icons/rajlogoR.png',
    'الائتمانية': 'lib/icons/rajlogoR.png',
    'بنك الاهلي': 'lib/icons/ahlilogoR.png',
    'بنك ساب': 'lib/icons/sablogo.png',
    'ولاء بلس': 'lib/icons/wallogo.png',
    'نافع': 'lib/icons/naflogo.png',
    'يور باي': 'lib/icons/urlogo.png',
    'اس تي سي باي': 'lib/icons/stlogo.png',
    // Add more banks and their corresponding image paths as needed
  };
  List<String> _banks = [
    'بنك الراجحي',
    'بريميوم', // Child of بنك الراجحي
    'الائتمانية', // Child of بنك الراجحي
    'بنك الاهلي',
    'بنك ساب',
    'ولاء بلس',
    'نافع',
    'يور باي',
    'اس تي سي باي'
  ];
  List<String> _selectedBanks = [];
  String? _selectedBank;

  void _showDeleteCardDialog(BuildContext context) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        List<String> userSelectedBanks = [];
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('cards')) {
          userSelectedBanks = List<String>.from(data['cards']);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "حذف البطاقات",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 106, 57, 117),
                ),
              ),
              content: Container(
                height: 300.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (String cardName in userSelectedBanks)
                        ListTile(
                          title: Row(
                            children: [
                              // Use the corresponding image path from _bankImages map
                              Image.asset(
                                _bankImages[cardName] ??
                                    'lib/icons/sablogo.png',
                                width: 25,
                                height: 25,
                              ),
                              SizedBox(width: 4),
                              Text(
                                cardName,
                                style: TextStyle(fontSize: 14.5),
                              ),
                            ],
                          ),
                          /* content: Container(
              height: 300.0, // Set the desired height
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String cardName in userSelectedBanks)
                      ListTile(
                        title: Text(
                          cardName,
                          style: TextStyle(fontSize: 16),
                        ),*/

                          trailing: ElevatedButton(
                            onPressed: () async {
                              // Show the confirmation pop-up
                              // Close the first dialogs
                              //Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "هل أنت متأكد من حذف هذه البطاقة؟",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(228, 106, 57, 117),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          "نعم",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 53, 12, 77)),
                                        ),
                                        onPressed: () async {
                                          // Remove the card from the user's selected cards in the database
                                          userSelectedBanks.remove(cardName);
                                          await FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(uid)
                                              .update(
                                                  {'cards': userSelectedBanks});
// Close the first dialogs
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          // Close the first dialog
                                          //Navigator.of(context).pop();
// Fetch the updated userSelectedBanks here
                                          fetchUserData();

                                          // Show a SnackBar using ScaffoldMessenger
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('تم حذف البطاقة بنجاح!'),
                                            duration: Duration(seconds: 2),
                                            backgroundColor:
                                                Color.fromARGB(255, 61, 33, 65),
                                          ));

                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          "لا",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 53, 12, 77)),
                                        ),
                                        onPressed: () {
                                          // Close the confirmation pop-up
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color.fromARGB(180, 53, 12, 77)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)))),
                            child: Text(
                              'حذف',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the delete cards dialog
                  },
                  child: Text(
                    'إغلاق',
                    style: TextStyle(color: Color.fromARGB(255, 53, 12, 77)),
                  ),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      // Handle the error, e.g., show an error message
      print("Error fetching user data: $error");
    });
  }

  //with تم button hidden
  void _showBankSelectionDialog(BuildContext context) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        List<String> userSelectedBanks = [];
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('cards')) {
          userSelectedBanks = List<String>.from(data['cards']);
        }

        bool isButtonEnabled =
            false; // Track whether the "تم" button should be enabled

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(
                    "البطاقات البنكية وبرامج الولاء",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 106, 57, 117),
                    ),
                  ),
                  content: Container(
                    width: double.minPositive,
                    child: BanksCheckList(
                      banks: _banks,
                      selectedBanks: userSelectedBanks,
                      changeSelectedBanks: (selectedBanks) {
                        setState(() {
                          // Update local state immediately when the user selects a bank
                          userSelectedBanks = selectedBanks;
                          isButtonEnabled = selectedBanks
                              .isNotEmpty; // Enable the button if at least one checkbox is checked
                        });
                      },
                      bankImages: _bankImages,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text("تم"),
                      onPressed: isButtonEnabled
                          ? () {
                              //Navigator.of(context).pop(); // Close the dialog

                              // Show the confirmation pop-up
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "هل أنت متأكد من عملية الإضافة؟",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(228, 106, 57, 117),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          "نعم",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 53, 12, 77)),
                                        ),
                                        onPressed: () async {
                                          // Add the new selected banks to the database
                                          await FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(uid)
                                              .update(
                                                  {'cards': userSelectedBanks});

                                          // // Close the first dialog
                                          Navigator.of(context).pop();
                                          // Fetch the updated userSelectedBanks here
                                          fetchUserData();

                                          // Show a SnackBar using ScaffoldMessenger
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('تمت الإضافة بنجاح!'),
                                            duration: Duration(seconds: 2),
                                            backgroundColor:
                                                Color.fromARGB(255, 61, 33, 65),
                                          ));
                                          Navigator.of(context).pop();
                                          // Close the BanksCheckList if added successfully
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          "لا",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 53, 12, 77)),
                                        ),
                                        onPressed: () {
                                          // Close the confirmation pop-up
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : null, // Disable the button if no checkbox is checked
                    ),
                    TextButton(
                      child: Text(
                        "العودة",
                        style:
                            TextStyle(color: Color.fromARGB(255, 53, 12, 77)),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Close the dialog without adding cards
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    }).catchError((error) {
      // Handle the error, e.g., show an error message
      print("Error fetching user data: $error");
    });
  }

  void changeSelectedBanks(List<String> selectedBanks) {
    setState(() {
      _cardsList = selectedBanks;
    });
  }

  void fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      uid = user.uid;

      FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          String username = documentSnapshot['name'];
          String email = documentSnapshot['email'];
          List<dynamic>? cards;

          Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('cards')) {
            cards = data['cards'];
          } else {
            cards = ['نافع', 'الانماء', 'قطاف'];
          }
          setState(() {
            _usernameController.text = username;
            _emailController.text = email;

            if (cards != null) {
              _cardsList = List<String>.from(cards);
            } else {
              _cardsList = ['نافع', 'الانماء', 'قطاف'];
            }
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
              content: SingleChildScrollView(
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
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('الغاء'),
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
                              ' يجب أن تحتوي على حرف خاص واحد.';
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
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    // Show a snackbar indicating successful sign out
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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

  @override
  Widget build(BuildContext context) {
    if (uid == '') {
      return Scaffold(
        appBar: AppBar(
          title: Text('حسابي'),
          backgroundColor: Color.fromARGB(255, 211, 198, 226),
          automaticallyImplyLeading: false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              currentTab = 0;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomeScreen(),
                ),
              );
            });
          },
          child: Image.asset(
            'lib/icons/Logo.png',
          ),
          backgroundColor: Color.fromARGB(157, 165, 138, 182),
          elevation: 20.0,
//mini: true,
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 10,
          shape: CircularNotchedRectangle(),
          color: Color.fromARGB(157, 217, 197, 230),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10.0, left: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.account_box),
                      onPressed: () {
                        setState(() {
                          currentTab = 1;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => account(),
                            ),
                          );
                        });
                      },
                      color: currentTab == 1 ? Colors.white : Colors.black,
                    ),
                    Text(
                      "حسابي",
                      style: TextStyle(
                          color: currentTab == 1 ? Colors.white : Colors.black),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          currentTab = 2;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => search(),
                            ),
                          );
                        });
                      },
                      color: currentTab == 2 ? Colors.white : Colors.black,
                    ),
                    Text(
                      "البحث",
                      style: TextStyle(
                          color: currentTab == 2 ? Colors.white : Colors.black),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.newspaper),
                      onPressed: () {
                        setState(() {
                          currentTab = 3;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => news(),
                            ),
                          );
                        });
                      },
                      color: currentTab == 3 ? Colors.white : Colors.black,
                    ),
                    Text(
                      "أحداث اليوم",
                      style: TextStyle(
                          color: currentTab == 3 ? Colors.white : Colors.black),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite),
                      onPressed: () {
                        setState(() {
                          currentTab = 4;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => favourites(),
                            ),
                          );
                        });
                      },
                      color: currentTab == 4 ? Colors.white : Colors.black,
                    ),
                    Text(
                      "المفضلة",
                      style: TextStyle(
                          color: currentTab == 4 ? Colors.white : Colors.black),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'أنت لا تملك حساب في دليل الرياض بعد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'اكمل تسجيل الدخول ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text(
                      ' سجل دخول الأن ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 232, 231, 233),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 99, 62, 118),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('حسابي'),
            backgroundColor: Color.fromARGB(255, 211, 198, 226),
            automaticallyImplyLeading: false,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                currentTab = 0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(),
                  ),
                );
              });
            },
            child: Image.asset(
              'lib/icons/Logo.png',
            ),
            backgroundColor: Color.fromARGB(157, 165, 138, 182),
            elevation: 20.0,
//mini: true,
          ),
          bottomNavigationBar: BottomAppBar(
            notchMargin: 10,
            shape: CircularNotchedRectangle(),
            color: Color.fromARGB(157, 217, 197, 230),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.0, left: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.account_box),
                        onPressed: () {
                          setState(() {
                            currentTab = 1;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => account(),
                              ),
                            );
                          });
                        },
                        color: currentTab == 1 ? Colors.white : Colors.black,
                      ),
                      Text(
                        "حسابي",
                        style: TextStyle(
                            color:
                                currentTab == 1 ? Colors.white : Colors.black),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            currentTab = 2;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => search(),
                              ),
                            );
                          });
                        },
                        color: currentTab == 2 ? Colors.white : Colors.black,
                      ),
                      Text(
                        "البحث",
                        style: TextStyle(
                            color:
                                currentTab == 2 ? Colors.white : Colors.black),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.newspaper),
                        onPressed: () {
                          setState(() {
                            currentTab = 3;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => news(),
                              ),
                            );
                          });
                        },
                        color: currentTab == 3 ? Colors.white : Colors.black,
                      ),
                      Text(
                        "أحداث اليوم",
                        style: TextStyle(
                            color:
                                currentTab == 3 ? Colors.white : Colors.black),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () {
                          setState(() {
                            currentTab = 4;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => favourites(),
                              ),
                            );
                          });
                        },
                        color: currentTab == 4 ? Colors.white : Colors.black,
                      ),
                      Text(
                        "المفضلة",
                        style: TextStyle(
                            color:
                                currentTab == 4 ? Colors.white : Colors.black),
                      )
                    ],
                  ),
                ),
              ],
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
                        color: Color.fromARGB(
                            255, 8, 8, 8), // Set the outline color
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
                        color: Color.fromARGB(
                            255, 8, 8, 8), // Set the outline color
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
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            content: Container(
                              width: 250.0,
                              height: 260.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16.0),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'البطاقات التي تملكها',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color:
                                                Color.fromARGB(255, 48, 13, 56),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert,
                                              color: Color.fromARGB(
                                                  255, 69, 51, 80)),
                                          onSelected: (String choice) {
                                            // Handle menu item selection
                                            if (choice == 'حذف') {
                                              _showDeleteCardDialog(context);
                                            } else if (choice == 'إضافة') {
                                              _showBankSelectionDialog(context);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return ['حذف', 'إضافة']
                                                .map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice,
                                                child: Text(choice),
                                              );
                                            }).toList();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _cardsList.length,
                                      itemBuilder: (context, index) {
                                        String cardName = _cardsList[index];
                                        String imagePath =
                                            _bankImages[cardName] ?? '';

                                        return ListTile(
                                          leading: imagePath.isNotEmpty
                                              ? Image.asset(
                                                  imagePath,
                                                  width: 30,
                                                  height: 30,
                                                )
                                              : Icon(
                                                  Icons.credit_card,
                                                  color: Color.fromARGB(
                                                      255, 69, 51, 80),
                                                ),
                                          title: Text(
                                            cardName,
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'إغلاق',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 53, 12, 77)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(
                          color: Color.fromARGB(255, 8, 8, 8),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.0),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Color.fromARGB(255, 69, 51, 80),
                                  size: 25,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'البطاقات البنكية وبرامج الولاء',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}

class BanksCheckList extends StatefulWidget {
  const BanksCheckList({
    Key? key,
    required this.banks,
    required this.selectedBanks,
    required this.changeSelectedBanks,
    required this.bankImages,
  }) : super(key: key);

  final List<String> banks;
  final List<String> selectedBanks;
  final Function(List<String>) changeSelectedBanks;
  final Map<String, String> bankImages;

  @override
  State<BanksCheckList> createState() => _BanksCheckListState();
}

class _BanksCheckListState extends State<BanksCheckList> {
  late List<String> _unselectedBanks;

  @override
  void initState() {
    super.initState();
    _updateUnselectedBanks();
  }

  void _updateUnselectedBanks() {
    setState(() {
      bool premiumSelected = widget.selectedBanks.contains('بريميوم');
      bool creditSelected = widget.selectedBanks.contains('الائتمانية');

      _unselectedBanks = widget.banks
          .where((bank) =>
              !(premiumSelected && bank == 'بريميوم') &&
              !(creditSelected && bank == 'الائتمانية') &&
              !widget.selectedBanks.contains(bank))
          .toList();

      // Only add بنك الراجحي if at least one of "بريميوم" or "الائتمانية" is not selected
      if (!(premiumSelected && creditSelected)) {
        _unselectedBanks.add('بنك الراجحي');
      } else if ((premiumSelected && creditSelected)) {
        _unselectedBanks.remove('بنك الراجحي');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_unselectedBanks.contains('بنك الراجحي'))
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Image.asset(
                      widget.bankImages['بنك الراجحي'] ??
                          'lib/icons/alrajlogo.png',
                      width: 25,
                      height: 25,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'بنك الراجحي',
                      style: TextStyle(
                        color: Color.fromARGB(255, 106, 57, 117),
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            for (String childBank in ['بريميوم', 'الائتمانية'])
              if (_unselectedBanks.contains(childBank))
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20.0),
                  child: CheckboxListTile(
                    title: Row(
                      children: [
                        Image.asset(
                          widget.bankImages[childBank] ??
                              'lib/icons/rajlogo.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 4),
                        Text(
                          childBank,
                          style: TextStyle(
                            color: Color.fromARGB(255, 106, 57, 117),
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                    value: widget.selectedBanks.contains(childBank),
                    onChanged: (value) {
                      setState(() {
                        if (widget.selectedBanks.contains(childBank)) {
                          widget.selectedBanks.remove(childBank);
                        } else {
                          widget.selectedBanks.add(childBank);
                        }
                      });
                      widget.changeSelectedBanks(widget.selectedBanks);
                      // Don't call _updateUnselectedBanks() here to avoid immediate checkbox disappearance
                    },
                  ),
                ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (String bank in _unselectedBanks)
                      if (bank != 'بنك الراجحي' &&
                          bank != 'بريميوم' &&
                          bank != 'الائتمانية')
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 5.0),
                          child: CheckboxListTile(
                            title: Row(
                              children: [
                                Image.asset(
                                  widget.bankImages[bank] ??
                                      'lib/icons/sablogo.png',
                                  width: 25,
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  bank,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 106, 57, 117),
                                    fontSize: 14.5,
                                  ),
                                ),
                              ],
                            ),
                            value: widget.selectedBanks.contains(bank),
                            onChanged: (value) {
                              setState(() {
                                if (widget.selectedBanks.contains(bank)) {
                                  widget.selectedBanks.remove(bank);
                                } else {
                                  widget.selectedBanks.add(bank);
                                }
                                // Call _updateUnselectedBanks() after checkbox click
                                //_updateUnselectedBanks();
                              });
                              widget.changeSelectedBanks(widget.selectedBanks);
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
