import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/comps/styles.dart';
import 'package:project/comps/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String id;
  final String name;
  const ChatPage({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? currentUserProfileImageUrl;
  String? otherUserProfileImageUrl;
  var roomId;

  Future<void> fetchProfileImages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      final otherUserDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.id)
          .get();

      setState(() {
        currentUserProfileImageUrl = currentUserDoc['profile_picture'];
        otherUserProfileImageUrl = otherUserDoc['profile_picture'];
      });
    }
  }

  @override
  void initState() {
    fetchProfileImages();
    super.initState();
  }

  Future<void> sendNotification(String message, String recipientId) async {
    const String onesignalAppId = '4cfb71c8-b361-4850-9d5c-35b258ecb176';
    const String onesignalApiKey =
        'ZTI2MzcxYmYtY2IyOS00NDJmLTljMDYtYjk3N2YzNTgyZjQ5';

    // Obtén el playerId del destinatario desde Firestore
    final recipientDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(recipientId)
        .get();
    String recipientPlayerId = recipientDoc['playerId'];

    String name = recipientDoc['name'];

    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Basic $onesignalApiKey',
      },
      body: json.encode({
        'app_id': onesignalAppId,
        'include_player_ids': [recipientPlayerId],
        'headings': {'en': 'Nuevo mensaje de $name'},
        'contents': {'en': message},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar la notificación: ${response.body}');
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.id)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                bool isTyping = snapshot.data!['isTyping'] ?? false;
                return Text(
                  isTyping ? "${widget.name} está escribiendo..." : "",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                );
              },
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chats',
                  style: Styles.h1(),
                ),
                const Spacer(),
                StreamBuilder(
                    stream: firestore
                        .collection('Users')
                        .doc(widget.id)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                            snapshot) {
                      return !snapshot.hasData
                          ? Container()
                          : Text(
                              'Last seen : ${DateFormat('hh:mm a').format(snapshot.data!['date_time'].toDate())}',
                              style: Styles.h1().copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white70),
                            );
                    }),
                const Spacer(),
                const SizedBox(
                  width: 50,
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: Styles.friendsBox(),
              child: StreamBuilder(
                  stream: firestore.collection('Rooms').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        List<QueryDocumentSnapshot?> allData = snapshot
                            .data!.docs
                            .where((element) =>
                                element['users'].contains(widget.id) &&
                                element['users'].contains(
                                    FirebaseAuth.instance.currentUser!.uid))
                            .toList();
                        QueryDocumentSnapshot? data =
                            allData.isNotEmpty ? allData.first : null;
                        if (data != null) {
                          roomId = data.id;
                        }
                        return data == null
                            ? Container()
                            : StreamBuilder(
                                stream: data.reference
                                    .collection('messages')
                                    .orderBy('datetime', descending: true)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snap) {
                                  return !snap.hasData
                                      ? Container()
                                      : ListView.builder(
                                          itemCount: snap.data!.docs.length,
                                          reverse: true,
                                          itemBuilder: (context, i) {
                                            return ChatWidgets.messagesCard(
                                                snap.data!.docs[i]['sent_by'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                snap.data!.docs[i]['message'],
                                                DateFormat('hh:mm a').format(
                                                    snap.data!
                                                        .docs[i]['datetime']
                                                        .toDate()),
                                                snap.data!.docs[i]['sent_by'],
                                                imageUrl: snap.data!.docs[i]
                                                    ['image_url'],
                                                currentUserProfileImageUrl:
                                                    currentUserProfileImageUrl,
                                                otherUserProfileImageUrl:
                                                    otherUserProfileImageUrl);
                                          },
                                        );
                                });
                      } else {
                        return Center(
                          child: Text(
                            'No conversion found',
                            style: Styles.h1()
                                .copyWith(color: Colors.indigo.shade400),
                          ),
                        );
                      }
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

                  await sendNotification(controller.text.trim(), widget.id);

                  Map<String, dynamic> data = {
                    'message': controller.text.trim(),
                    'sent_by': FirebaseAuth.instance.currentUser!.uid,
                    'datetime': DateTime.now(),
                    'image_url':
                        imageUrl, // Añade la URL de la imagen al mensaje (si hay alguna)
                  };

                  if (roomId != null) {
                    firestore.collection('Rooms').doc(roomId).update({
                      'last_message_time': DateTime.now(),
                      'last_message': controller.text,
                    });
                    firestore
                        .collection('Rooms')
                        .doc(roomId)
                        .collection('messages')
                        .add(data);
                  } else {
                    firestore.collection('Rooms').add({
                      'users': [
                        widget.id,
                        FirebaseAuth.instance.currentUser!.uid,
                      ],
                      'last_message': controller.text,
                      'last_message_time': DateTime.now(),
                    }).then((value) async {
                      value.collection('messages').add(data);
                    });
                  }
                }

                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'isTyping': false});

                controller.clear();
              },
            ),
          )
        ],
      ),
    );
  }
}
