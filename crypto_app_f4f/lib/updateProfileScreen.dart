

import 'package:crypto_app_f4f/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController age = TextEditingController();

  Future<void> saveData(String key, String value) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(key, value);
  }

  void saveUserDetails() async {
    await saveData('name', name.text);
    await saveData('email', email.text);
    await saveData('age', age.text);
    print("Data Saved");
  }

  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
       iconTheme: IconThemeData(
        color: isDarkModeEnabled ? Colors.black : Colors.white,
       ),
        title:  Text("Profile Update",style: TextStyle(
          color: isDarkModeEnabled ? Colors.black : Colors.white,
        ),),
      ),
      body: Column(
        children: [
          
          customTextField("Name", name, false),
          customTextField("Email", email, false),
          customTextField("Age", age, true),
          ElevatedButton(
            onPressed: () {
              saveUserDetails();
            },
            child:  Text("Save Details",style: TextStyle(
              color: isDarkModeEnabled ? Colors.black : Colors.white,
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customTextField(
      String title, TextEditingController controller, bool isAgeTextField) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        style: TextStyle(
          color: isDarkModeEnabled ? Colors.white : Colors.black,
        ),
        controller: controller,
        decoration: InputDecoration(
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkModeEnabled ? Colors.white : Colors.grey,
            ),
          ),
          hintText: title,
          hintStyle: TextStyle(
            color: isDarkModeEnabled ? Colors.white : null,
          ),
        ),
        keyboardType: isAgeTextField ? TextInputType.number : null,
      ),
    );
  }
}
