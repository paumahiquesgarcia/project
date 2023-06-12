import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/paginas/groupspage.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  String groupName = '';
  List<String> selectedMembers = [];
  final firestore = FirebaseFirestore.instance;

  // Método para guardar el grupo en Firestore
  Future<void> saveGroup() async {
    await firestore.collection('Groups').add({
      'name': groupName,
      'members': selectedMembers,
      'group_picture':
          'https://firebasestorage.googleapis.com/v0/b/userdatabase030501.appspot.com/o/group.png?alt=media&token=bd0300bc-100a-4dd5-b236-1675090f1158&_gl=1*pmwgbt*_ga*NzA2MDcxOTQ5LjE2ODYyNDQ2ODg.*_ga_CW55HF8NVT*MTY4NjUzMDg1Ny44LjEuMTY4NjUzMDg3Mi4wLjAuMA..', // Puedes proporcionar una URL de imagen predeterminada o dejarla vacía
      'last_message': '',
      'last_message_time': DateTime.now(),
    });
    if (context.mounted) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: const GroupsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                groupName = value;
              },
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Implementación para seleccionar a los participantes
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('Users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    var user = snapshot.data!.docs[i];
                    return CheckboxListTile(
                      title: Text(user['name']),
                      value: selectedMembers.contains(user.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedMembers.add(user.id);
                          } else {
                            selectedMembers.remove(user.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveGroup,
        child: const Icon(Icons.check),
      ),
    );
  }
}
