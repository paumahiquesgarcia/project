import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/comps/animated-dialog.dart';
import 'package:project/comps/styles.dart';
import 'package:project/profile_page.dart';

import '../groupspage.dart';

class ChatWidgets {
  static Map<String, String> _profilePictureCache = {};

  static Future<String> _fetchProfilePictureUrl(String userId) async {
    if (!_profilePictureCache.containsKey(userId)) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(userId)
          .get();
      _profilePictureCache[userId] = snapshot.data()!['profile_picture'];
    }
    return _profilePictureCache[userId]!;
  }

  static Widget card({title, time, subtitle, onTap, String imageUrl = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Card(
        elevation: 0,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(5),
          leading: Padding(
            padding: EdgeInsets.all(0.0),
            child: CircleAvatar(
              radius: 25,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(time),
          ),
        ),
      ),
    );
  }

  static Widget circleProfile({onTap, name, String imageUrl = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(
                width: 50,
                child: Center(
                    child: Text(
                  name,
                  style:
                      TextStyle(height: 1.5, fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )))
          ],
        ),
      ),
    );
  }

  static Widget messagesCard(
      bool check, String message, String time, String userId,
      {String? imageUrl}) {
    return FutureBuilder<String>(
      future: _fetchProfilePictureUrl(userId),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          String imageUrlprofile = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (check) const Spacer(),
                if (!check)
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 10,
                    backgroundImage:
                        imageUrl != '' ? NetworkImage(imageUrlprofile) : null,
                    child: imageUrl != ''
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 13,
                            color: Colors.white,
                          ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),
                    decoration: Styles.messagesCardStyle(check),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        Text(
                          '$message\n\n$time',
                          style: TextStyle(
                              color: check ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                if (check)
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 10,
                    backgroundImage:
                        imageUrl != '' ? NetworkImage(imageUrlprofile) : null,
                    child: imageUrl != ''
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 13,
                            color: Colors.white,
                          ),
                  ),
                if (!check) const Spacer(),
              ],
            ),
          );
        } else {
          // Muestra un indicador de carga mientras se obtiene la información del usuario.
          return CircularProgressIndicator();
        }
      },
    );
  }

  static messageField({required onSubmit}) {
    final con = TextEditingController();
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.attach_file),
          onPressed: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? imageFile =
                await _picker.pickImage(source: ImageSource.gallery);
            if (imageFile != null) {
              onSubmit(con, imageFile: File(imageFile.path));
            }
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: TextField(
              controller: con,
              onChanged: (value) async {
                // Cuando el usuario escribe, actualiza el estado de isTyping en Firestore
                if (value.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({'isTyping': true});
                } else {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({'isTyping': false});
                }
              },
              decoration: Styles.messageTextFieldStyle(onSubmit: () {
                onSubmit(con);
              }),
            ),
            decoration: Styles.messageFieldCardStyle(),
          ),
        ),
      ],
    );
  }

  static drawer(context) {
    return Drawer(
      backgroundColor: Colors.indigo.shade400,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
          child: Theme(
            data: ThemeData.dark(),
            child: Column(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                  radius: 60,
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Colors.white,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.groups),
                  title: Text('Groups'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GroupsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async => await FirebaseAuth.instance.signOut(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static searchBar(
    bool open,
  ) {
    return AnimatedDialog(
      height: open ? 800 : 0,
      width: open ? 400 : 0,
    );
  }

  static searchField({Function(String)? onChange}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        onChanged: onChange,
        decoration: Styles.searchTextFieldStyle(),
      ),
      decoration: Styles.messageFieldCardStyle(),
    );
  }
}
