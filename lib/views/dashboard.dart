import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/group_chats/group_chat_screen.dart';
import 'package:talk_tube_o9/views/home_screen.dart';

import '../config/setting.dart';
import '../models/user_model.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  final UserModel userModel;
  final User firebaseUser;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Setting.themeColor,
        fixedColor: Colors.white,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_rounded),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
          const GroupChatHomeScreen(),
          const Center(child: Text('Setting')),
        ],
      ),
    );
  }
}
