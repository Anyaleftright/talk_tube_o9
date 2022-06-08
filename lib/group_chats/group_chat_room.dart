import 'dart:developer';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:emoji_picker_2/emoji_picker_2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_tube_o9/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_tube_o9/config/setting.dart';
import 'package:talk_tube_o9/widgets/widget.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../views/extend_video.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  const GroupChatRoom({
    required this.groupName,
    required this.groupChatId,
    Key? key,
  }) : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isShowEmoji = false;
  final FocusNode _keyboard = FocusNode();
  File? image;
  File? video;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // isShowEmoji = false;
    _keyboard.addListener(() {
      if (_keyboard.hasFocus) {
        setState(() {
          isShowEmoji = false;
        });
      }
    });
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        editImage(pickedFile);
      });
    }
  }

  void editImage(XFile file) async {
    File? editedImage = await ImageCropper().cropImage(sourcePath: file.path);
    if (editedImage != null) {
      setState(() {
        image = editedImage;
      });
    }
  }

  void uploadImage() async {
    if (image != null) {
      ///Lấy tên file
      String? fileName = image?.path.split('/').last;

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("imageMessage")
          .child('/$fileName')
          .putFile(image!);
      TaskSnapshot snapshot = await uploadTask;
      String? imageUrl = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> chatData = {
        "messageId": uuid.v1(),
        "sendBy": _auth.currentUser!.displayName,
        "message": imageUrl,
        "seen": false,
        "type": "image",
        "time": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);

      log('Image uploaded');
      // image!.delete();
      setState(() {
        image = null;
      });
    }
  }

  void selectVideo(ImageSource source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    video = File(pickedFile!.path);

    // print(pickedFile.path.toString());

    _videoPlayerController = VideoPlayerController.file(video!)
      ..initialize().then((value) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  void uploadVideo() async {
    if (video != null) {
      ///Lấy tên file
      String? fileName = video?.path.split('/').last;

      UploadTask uploadTask = FirebaseStorage.instance
          .ref("videoMessage")
          .child('/$fileName')
          .putFile(video!);
      TaskSnapshot snapshot = await uploadTask;
      String? videoUrl = await snapshot.ref.getDownloadURL();

      // print(videoUrl);
      // print(fileName);

      Map<String, dynamic> chatData = {
        "messageId": uuid.v1(),
        "sendBy": _auth.currentUser!.displayName,
        "message": videoUrl,
        "seen": false,
        "type": "video",
        "time": FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
      log('video uploaded');
      // image!.delete();
      setState(() {
        video = null;
      });
    }
  }

  void onSendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      messageController.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    MediaQueryData queryData = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                      ),
                    ),
                  ),
              icon: const Icon(Icons.info)),
        ],
      ),
      body: WillPopScope(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: queryData.size.height * 0.1,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        onPressed: () {
                          selectImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo,
                            size: 32, color: Colors.grey),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        onPressed: () {
                          selectVideo(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.video_library,
                            size: 32, color: Colors.grey),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        focusNode: _keyboard,
                        controller: messageController,
                        style: simpleTextStyle(),
                        maxLines: null,
                        decoration: textFieldMessage(
                          () {
                            setState(() {
                              /// when keyboard is opened, click emoji btn can dispose the keyboard
                              isShowEmoji = !isShowEmoji;
                              _keyboard.unfocus();
                              _keyboard.canRequestFocus = false;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () {
                          onSendMessage();
                          uploadImage();
                          uploadVideo();
                        },
                        icon: Icon(
                          Icons.send,
                          size: 30,
                          color: messageController.text.isEmpty
                              ? Colors.grey
                              : Setting.themeColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              isShowEmoji == true
                  ? EmojiPicker2(
                      rows: 3,
                      columns: 7,
                      bgColor: Colors.black,
                      indicatorColor: Setting.themeColor,
                      onEmojiSelected: (emoji, category) {
                        messageController.text =
                            messageController.text + emoji.emoji;
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        onWillPop: () {
          if (isShowEmoji == true) {
            setState(() {
              isShowEmoji = false;
            });
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    log('VJP LOG: ' + chatMap['message']);
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: chatMap['sendBy'] == _auth.currentUser!.displayName
                    ? Setting.themeColor
                    : Colors.grey.withOpacity(0.5),
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "video") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: size.height * 0.5,
              maxWidth: size.width * 0.7,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ExtendVideo(videoUrl: chatMap['message'].toString()))),
              child: Image.network(
                  'https://scontent.fhan3-5.fna.fbcdn.net/v/t39.30808-1/277568074_3103451473306656_4454676768461377826_n.jpg?stp=dst-jpg_p160x160&_nc_cat=110&ccb=1-7&_nc_sid=7206a8&_nc_ohc=XztwfH8fN_4AX9eZGhw&_nc_ht=scontent.fhan3-5.fna&oh=00_AT_YVHsDBfQ5h0mwAlk-3uwdOkCNNyD4Uj1GsZWz7Ev--g&oe=62A54B9D'),
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}
