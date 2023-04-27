import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          'https://firebasestorage.googleapis.com/v0/b/userdatabase030501.appspot.com/o/profile_pictures%2F5jFwNo0qciXXp4JampICzBlDQER2_profile_picture?alt=media&token=4bed3232-d8c1-4d3f-b48c-df5730ab0b7d', // Puedes proporcionar una URL de imagen predeterminada o dejarla vacía
      'last_message': '',
      'last_message_time': DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                groupName = value;
              },
              decoration: InputDecoration(
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
                  return CircularProgressIndicator();
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
        child: Icon(Icons.check),
      ),
    );
  }
}
