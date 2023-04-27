import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password, _name;

  Future<void> _register() async {
    final formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        User? user = userCredential.user;

        FirebaseFirestore.instance.collection('Users').doc(user!.uid).set({
          'name': _name,
          'email': _email,
          'date_time': DateTime.now(),
          'isTyping': false,
          'profile_picture':
              "https://firebasestorage.googleapis.com/v0/b/userdatabase030501.appspot.com/o/profile_pictures%2F5jFwNo0qciXXp4JampICzBlDQER2_profile_picture?alt=media&token=4bed3232-d8c1-4d3f-b48c-df5730ab0b7d",
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
