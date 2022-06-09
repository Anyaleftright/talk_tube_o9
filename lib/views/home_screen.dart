import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:talk_tube_o9/config/setting.dart';
import 'package:talk_tube_o9/models/chat_room_model.dart';
import 'package:talk_tube_o9/models/firebase_helper.dart';
import 'package:talk_tube_o9/widgets/ui_helper.dart';
import 'package:talk_tube_o9/models/user_model.dart';
import 'package:talk_tube_o9/views/search_screen.dart';
import 'package:talk_tube_o9/widgets/widget.dart';
import 'package:flutter/material.dart';

import '../group_chats/group_chat_screen.dart';
import 'chat_room_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const HomeScreen(
      {Key? key, this.userModel, this.firebaseUser})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      floatingActionButton: SpeedDial(
        backgroundColor: Setting.themeColor,
        overlayOpacity: 0,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GroupChatHomeScreen(),
              ),
            ),
            child: const Icon(Icons.group),
            label: 'Group chat',
            backgroundColor: Setting.themeColor,
            foregroundColor: Colors.white,
          ),
          SpeedDialChild(
            onTap: () {
              // UIHelper.showLoadingDialog(context, 'Loading');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    userModel: widget.userModel!,
                    firebaseUser: widget.firebaseUser!,
                  ),
                ),
              );
            },
            child: const Icon(Icons.search),
            label: 'Search',
            backgroundColor: Setting.themeColor,
            foregroundColor: Colors.white,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        backgroundColor: Setting.themeColor,
        color: Colors.white,
        child: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatRooms')
                .where('participants.${widget.userModel!.uid}', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  return ListView.builder(
                    itemCount: dataSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          dataSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel!.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;
                              return ListTile(
                                onTap: () async {
                                  if (chatRoomModel != null) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomScreen(
                                          userModel: widget.userModel!,
                                          firebaseUser: widget.firebaseUser!,
                                          targetUser: targetUser,
                                          chatRoom: chatRoomModel);
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      targetUser.avatar!.toString() == ''
                                          ? const AssetImage(
                                              'assets/images/default.png')
                                          : NetworkImage(targetUser.avatar!)
                                              as ImageProvider,
                                ),
                                title: Text(
                                  targetUser.name.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(
                                  chatRoomModel.lastMessage.toString(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            } else {
                              return const isLoading();
                            }
                          } else {
                            return const isLoading();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(child: Text("Empty."));
                }
              } else {
                return const isLoading();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }
}
