import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_tube_o9/authenticate/login_screen.dart';
import 'package:talk_tube_o9/config/setting.dart';
import 'package:flutter/material.dart';

PreferredSize appBarMain(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(50),
    child: AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Talk', style: TextStyle(color: Setting.themeColor)),
          Text('Tube™', style: TextStyle(color: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          // onPressed: () => logOut(context),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          icon: const Icon(Icons.exit_to_app),
        ),
      ],
    ),
  );
}

InputDecoration textFieldInputDecoration(String title) {
  return InputDecoration(
    hintText: title,
    hintStyle: const TextStyle(
      color: Colors.white54,
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    ),
  );
}

InputDecoration textFieldMessage(VoidCallback onPress) {
  return InputDecoration(
    hintText: 'Enter message',
    hintStyle: const TextStyle(
      color: Colors.white54,
    ),
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    fillColor: Colors.grey.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    suffixIcon: IconButton(
      onPressed: onPress,
      icon: const Icon(Icons.emoji_emotions, size: 28, color: Colors.grey),
    ),
  );
}


TextStyle simpleTextStyle(){
  return const TextStyle(
    color: Colors.white,
  );
}

Widget appBrand() {
  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Talk',
          style: TextStyle(
              fontSize: 60, color: Setting.themeColor),
        ),
        Text(
          'Tube™',
          style:
          TextStyle(fontSize: 60, color: Colors.white),
        ),
      ],
    ),
  );
}