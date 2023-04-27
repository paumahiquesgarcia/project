import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  final firebase = FirebaseAuth.instance;
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImage() async {
    if (_imageFile != null) {
      String fileName = "${firebase.currentUser!.uid}_profile_picture";
      Reference storageRef =
          FirebaseStorage.instance.ref().child("profile_pictures/$fileName");
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      await uploadTask.whenComplete(() {});
      return storageRef.getDownloadURL();
    }
    return null;
  }

  Future<void> _updateProfileData(String newName, String? newImageUrl) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    Map<String, dynamic> updatedData = {'name': newName};
    if (newImageUrl != null && newImageUrl != "") {
      updatedData['profile_picture'] = newImageUrl;
    }

    return users
        .doc(firebase.currentUser!.uid)
        .update(updatedData)
        .then((value) => print('Profile Updated'))
        .catchError((error) => print('Failed to update user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(firebase.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            _nameController.text = data['name'];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (data['profile_picture'] != null
                                    ? CachedNetworkImageProvider(
                                        data['profile_picture'])
                                    : const AssetImage(
                                        'assets/images/default_avatar.png'))
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String newName = _nameController.text.trim();
                        String? newImageUrl = await _uploadImage();
                        await _updateProfileData(newName, newImageUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado con éxito.'),
                          ),
                        );
                      },
                      child: const Text('Actualizar perfil'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
