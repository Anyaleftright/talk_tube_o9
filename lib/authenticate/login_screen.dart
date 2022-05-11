import 'package:talk_tube_o9/authenticate/create_account.dart';
import 'package:talk_tube_o9/screens/home_screen.dart';
import 'package:talk_tube_o9/authenticate/methods.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/widgets/ui_helper.dart';

import '../config/setting.dart';
import '../widgets/widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: isLoading
            ? SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      appBrand(),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _email,
                        decoration: textFieldInputDecoration('Email'),
                        style: simpleTextStyle(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: textFieldInputDecoration('Password'),
                        style: simpleTextStyle(),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: InkWell(
                            onTap: () {},
                            child: Text('Forgot password?',
                                style: simpleTextStyle())),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_email.text.isNotEmpty &&
                                _password.text.isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });

                              logIn(_email.text, _password.text).then((user) {
                                if (user != null) {
                                  print("Login Sucessfull");
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                          (route) => false);
                                } else {
                                  UIHelper.showAlertDialog(
                                      context,
                                      'Login Failed',
                                      'Please corrected all fields');
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              });
                            } else {
                              UIHelper.showAlertDialog(context, 'Login Failed',
                                  'Please corrected all fields');
                            }
                          },
                          child: const Text('Sign In'),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Setting.themeColor),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Sign In with Google',
                              style: TextStyle(color: Colors.black)),
                          style: ButtonStyle(
                              // overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.1)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xffe0e0e0)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have a account?\t",
                                style: simpleTextStyle()),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateAccount())),
                              child: const Text("Register now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              print("Login Sucessfull");
              setState(() {
                isLoading = false;
              });
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => HomeScreen()),
                      (route) => false);
            } else {
              UIHelper.showAlertDialog(
                  context, 'Login Failed', 'Please corrected all fields');
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
          UIHelper.showAlertDialog(
              context, 'Login Failed', 'Please corrected all fields');
        }
      },
      child: Container(
          height: size.height / 14,
          width: size.width / 1.2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }

  Widget field(
      Size size, String hintText, IconData icon, TextEditingController cont) {
    return SizedBox(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
