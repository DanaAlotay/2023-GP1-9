import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

// with star
Widget reusableTextField(
  String labelText,
  IconData icon,
  bool isPasswordType,
  TextEditingController controller, {
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  FocusNode? focusNode,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: [
          Text(
            "*",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      SizedBox(
          height: 1), // Add some spacing between the star and the text field
      TextFormField(
        controller: controller,
        obscureText: isPasswordType,
        enableSuggestions: !isPasswordType,
        autocorrect: !isPasswordType,
        validator: validator,
        onChanged: onChanged,
        focusNode: focusNode,
        cursorColor: Color.fromARGB(255, 77, 73, 73),
        style: TextStyle(color: Color.fromARGB(255, 6, 6, 6).withOpacity(0.9)),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color:
                Color.fromARGB(255, 170, 145, 182), // Set the color of the icon
          ),
          labelText: labelText,
          labelStyle: TextStyle(
              color: Color.fromARGB(
                  255, 201, 178, 213)), // Set the color of the label text
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: Color.fromARGB(255, 164, 139, 177).withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
          ),
        ),
        keyboardType: isPasswordType
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
      ),
    ],
  );
}

bool isValidEmail(String email) {
  // Regular expression for a simple email validation
  final RegExp emailRegex =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  return emailRegex.hasMatch(email);
}

Container firebaseUIButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: const TextStyle(
            color: Color.fromARGB(255, 78, 50, 91),
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Color.fromARGB(
                  255, 190, 153, 209); // Set the color when pressed
            }
            return Color.fromARGB(255, 190, 153, 209); // Set the default color
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}
