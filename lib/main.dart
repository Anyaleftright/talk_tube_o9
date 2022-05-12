import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/models/firebase_helper.dart';
import 'package:talk_tube_o9/models/user_model.dart';
import 'package:talk_tube_o9/views/dashboard.dart';
import 'package:talk_tube_o9/views/home_screen.dart';
import 'package:talk_tube_o9/views/signin.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? thisUser = await FirebaseHelper.getUserModelById(currentUser.uid);
    thisUser != null
        ? runApp(MyAppLoggedIn(userModel: thisUser, firebaseUser: currentUser))
        : runApp(const MyApp());
  } else {
    runApp(const MyApp());
  }
  // runApp(const MyApp());
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1f1f1f),
      ),
      // home: HomeScreen(userModel: userModel, firebaseUser: firebaseUser),
      home: Dashboard(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1f1f1f),
      ),
      home: const SignIn(),
    );
  }
}
