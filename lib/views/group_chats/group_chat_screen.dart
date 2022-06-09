import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/widgets/widget.dart';

import '../../config/setting.dart';
import 'create_group/add_members.dart';
import 'group_chat_room.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? AlertDialog(
              backgroundColor: Colors.transparent,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Setting.themeColor)),
                  const SizedBox(height: 6),
                  Text('loading', style: simpleTextStyle()),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupChatRoom(
                        groupName: groupList[index]['name'],
                        groupChatId: groupList[index]['id'],
                      ),
                    ),
                  ),
                  leading: const Icon(Icons.group),
                  title: Text(
                    groupList[index]['name'],
                  ),
                  iconColor: Colors.white,
                  textColor: Colors.white,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.create),
        backgroundColor: Setting.themeColor,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ),
    );
  }
}
