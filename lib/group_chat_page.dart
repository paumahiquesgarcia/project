import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/comps/styles.dart';
import 'package:project/comps/widgets.dart';
import 'package:intl/intl.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  const GroupChatPage(
      {Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  Map<String, String> _userProfileImages = {};

  @override
  void initState() {
    super.initState();
    getGroupUserProfileImages(widget.groupId).then((profileImages) {
      setState(() {
        _userProfileImages = profileImages;
      });
    });
  }

  Future<Map<String, String>> getGroupUserProfileImages(String groupId) async {
    final firestore = FirebaseFirestore.instance;
    final groupDoc = await firestore.collection('Groups').doc(groupId).get();
    List<String> userIds = List<String>.from(groupDoc.data()!['members']);

    Map<String, String> userProfileImages = {};
    for (String userId in userIds) {
      final userDoc = await firestore.collection('Users').doc(userId).get();
      userProfileImages[userId] = userDoc.data()!['profile_picture'];
      print(userProfileImages[userId]);
    }

    return userProfileImages;
  }

  Future<String?> _uploadImage(File imageFile) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}_message_image";
    Reference storageRef =
        FirebaseStorage.instance.ref().child("message_images/$fileName");
    UploadTask uploadTask = storageRef.putFile(imageFile);
    await uploadTask.whenComplete(() {});
    return storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Scaffold(
      backgroundColor: Colors.indigo.shade400,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: Text(widget.groupName),
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: Styles.friendsBox(),
              child: StreamBuilder(
                  stream: firestore
                      .collection('GroupRooms')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('datetime', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        reverse: true,
                        itemBuilder: (context, i) {
                          return ChatWidgets.messagesCardGroups(
                            snapshot.data!.docs[i]['sent_by'] ==
                                FirebaseAuth.instance.currentUser!.uid,
                            snapshot.data!.docs[i]['message'],
                            DateFormat('hh:mm a').format(
                                snapshot.data!.docs[i]['datetime'].toDate()),
                            snapshot.data!.docs[i]['sent_by'],
                            imageUrl: snapshot.data!.docs[i]['image_url'],
                            userProfileImages: _userProfileImages,
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.indigo,
                        ),
                      );
                    }
                  }),
            ),
          ),
          Container(
            color: Colors.white,
            child: ChatWidgets.messageField(
              onSubmit: (controller, {File? imageFile}) async {
                if (controller.text.trim() != '' || imageFile != null) {
                  String? imageUrl;
                  if (imageFile != null) {
                    imageUrl = await _uploadImage(imageFile);
                  }

                  Map<String, dynamic> data = {
                    'message': controller.text.trim(),
                    'sent_by': FirebaseAuth.instance.currentUser!.uid,
                    'datetime': DateTime.now(),
                    'image_url':
                        imageUrl, // Añade la URL de la imagen al mensaje (si hay alguna)
                  };
                  await firestore
                      .collection('GroupRooms')
                      .doc(widget.groupId)
                      .collection('messages')
                      .add(data);

                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
