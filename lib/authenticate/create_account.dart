import 'package:talk_tube_o9/authenticate/methods.dart';
import 'package:flutter/material.dart';

import '../Screens/home_screen.dart';
import '../config/setting.dart';
import '../widgets/ui_helper.dart';
import '../widgets/widget.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _name = TextEditingController();
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
                      controller: _name,
                      decoration: textFieldInputDecoration('Name'),
                      style: simpleTextStyle(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      decoration: textFieldInputDecoration('Email'),
                      style: simpleTextStyle(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: textFieldInputDecoration('Password'),
                      style: simpleTextStyle(),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_name.text.isNotEmpty &&
                              _email.text.isNotEmpty &&
                              _password.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            createAccount(_name.text, _email.text, _password.text).then((user) {
                              if (user != null) {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
                                UIHelper.showAlertDialog(context, '', 'Account Created Successful');
                              } else {
                                UIHelper.showAlertDialog(context, 'Error', 'Email already used');
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            });
                          } else {
                            UIHelper.showAlertDialog(context, 'Error', 'Please fill all the fields');
                          }
                        },
                        child: const Text('Sign Up'),
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
                    ),
                  ],
                ),
              ),
            ),
    ));
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_name.text.isNotEmpty &&
            _email.text.isNotEmpty &&
            _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          createAccount(_name.text, _email.text, _password.text).then((user) {
            if (user != null) {
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
              print("Account Created Sucessfull");
            } else {
              print("Login Failed");
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
          print("Please enter Fields");
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
          child: Text(
            "Create Account",
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
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
        controller: cont,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
