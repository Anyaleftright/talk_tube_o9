import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/widgets/widget.dart';

import '../../config/setting.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;

  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isGreaterThanOrEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add({
      "name": userMap!['name'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "isAdmin": false,
      "avatar": userMap!['avatar'],
    });

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.account_circle),
                    title: Text(membersList[index]['name']),
                    subtitle: Text(membersList[index]['email']),
                    trailing: const Icon(Icons.close),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                  );
                },
              ),
            ),*/
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: textFieldInputDecoration('Email address'),
                  style: simpleTextStyle(),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSearch,
                      child: const Text('Search'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Setting.themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
