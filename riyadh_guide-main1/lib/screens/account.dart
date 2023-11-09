import 'package:flutter/material.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _accountState();
}

class _accountState extends State<account> {
  @override
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  List<String> bankCards = ['Alinma', 'Nafea', 'Alahli'];
  String selectedBankCard = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() {
//
    setState(() {
      _usernameController.text = ' Sara Khaled';
      _emailController.text = 'sara@example.com';
      selectedBankCard = bankCards[0];
    });
  }

  void updateUserInformation() {
// Update the user information
    String updatedUsername = _usernameController.text;
    String updatedEmail = _emailController.text;
  }

  void resetPassword() {
// Implement password reset functionality
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('حسابي'),
            backgroundColor: Color.fromARGB(255, 211, 198, 226)),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Color.fromARGB(
                        255, 203, 166, 246), // You can change this color
                    child: Icon(
                      Icons
                          .person, // Change this to the appropriate female icon
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ]),
                TextFormField(
                  readOnly: true,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                  ),
                ),
                SizedBox(height: 40.0),
                TextFormField(
                  readOnly: true,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الالكتروني',
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(Icons.credit_card),
                    SizedBox(width: 10.0),
                    DropdownButton<String>(
                      value: selectedBankCard,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBankCard = newValue!;
                        });
                      },
                      items: bankCards.map((String bankCard) {
                        return DropdownMenuItem(
                          value: bankCard,
                          child: Text(
                            bankCard,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        );
                      }).toList(),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      dropdownColor: Colors.grey[200],
                    ),
                  ],
                ),
                /*
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: updateUserInformation,
                  child: Text('حفظ التغييرات'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
                */
                SizedBox(height: 20.0),
                /* button change pass
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color.fromARGB(38, 71, 10, 100),
                                Color.fromARGB(255, 183, 140, 243),
                                Color.fromARGB(255, 178, 127, 202),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8.0),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: resetPassword,
                        child: const Text('استعادة كلمة المرور'),
                      ),
                    ],
                  ),
                )
*/
                /*
            TextButton(

              onPressed: resetPassword,
              
              child: Text(
                'استعادة كلمة المرور ',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.red,
                ),
              ),
            ),
            */
                TextButton(
                  onPressed: resetPassword,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.black,
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
              ],
            ),
          ),
        ));
  }
}
