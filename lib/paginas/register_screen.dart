import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
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
              "https://firebasestorage.googleapis.com/v0/b/userdatabase030501.appspot.com/o/%E2%80%94Pngtree%E2%80%94outline%20user%20icon_5045523.png?alt=media&token=5d7525b6-d49f-4969-9094-2b400e3730f6&_gl=1*14cxpdx*_ga*NzA2MDcxOTQ5LjE2ODYyNDQ2ODg.*_ga_CW55HF8NVT*MTY4NjUzMDg1Ny44LjEuMTY4NjUzMTAzNi4wLjAuMA..",
        });

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: screenHeight * .12),
                  const Text(
                    'Registro',
                    style: TextStyle(
                        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: screenHeight * .05),
                  MaterialTextField(
                    keyboardType: TextInputType.name,
                    hint: 'Name',
                    theme: FilledOrOutlinedTextTheme(
                      enabledColor: Colors.grey,
                      focusedColor: Colors.blue,
                      fillColor: Colors.white70,
                      // You can use all properties of FilledOrOutlinedTextTheme
                      // to decor text field
                    ),
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      _name = value!;
                    },
                  ),
                  SizedBox(height: screenHeight * .01),
                  MaterialTextField(
                    keyboardType: TextInputType.emailAddress,
                    hint: 'Email',
                    theme: FilledOrOutlinedTextTheme(
                      enabledColor: Colors.grey,
                      focusedColor: Colors.blue,
                      fillColor: Colors.white70,
                      // You can use all properties of FilledOrOutlinedTextTheme
                      // to decor text field
                    ),
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      _email = value!;
                    },
                  ),
                  SizedBox(height: screenHeight * .01),
                  MaterialTextField(
                    keyboardType: TextInputType.visiblePassword,
                    hint: 'Password',
                    obscureText: true,
                    theme: FilledOrOutlinedTextTheme(
                      enabledColor: Colors.grey,
                      focusedColor: Colors.blue,
                      fillColor: Colors.white70,
                      // You can use all properties of FilledOrOutlinedTextTheme
                      // to decor text field
                    ),
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (String? value) {
                      _password = value!;
                    },
                  ),
                  SizedBox(height: screenHeight * .02),
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
        ));
  }
}
