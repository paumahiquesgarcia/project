import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/creategrouppage.dart';
import 'package:project/group_chat_page.dart';

import 'comps/widgets.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final firestore = FirebaseFirestore.instance;

  Widget buildGroupList(BuildContext context, List data) {
    // El código del método buildGroupList copiado desde MyHomePage
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        var group = data[i];
        return ChatWidgets.card(
          title: group['name'],
          subtitle: group['last_message'],
          time:
              DateFormat('hh:mm a').format(group['last_message_time'].toDate()),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return GroupChatPage(
                    groupId: group.id,
                    groupName: group['name'],
                  );
                },
              ),
            );
          },
          imageUrl: group['group_picture'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: StreamBuilder(
                          stream: firestore.collection('Groups').snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            List data = !snapshot.hasData
                                ? []
                                : snapshot.data!.docs
                                    .where((element) => element['members']
                                        .toString()
                                        .contains(FirebaseAuth
                                            .instance.currentUser!.uid))
                                    .toList();
                            return buildGroupList(context, data);
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupPage()),
          );
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
