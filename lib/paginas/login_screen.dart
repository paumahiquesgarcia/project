import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String _email, _password;

  Future<void> updateOneSignalPlayerId(String userId) async {
    String? playerId = await OneSignal.shared
        .getDeviceState()
        .then((deviceState) => deviceState?.userId);

    if (playerId != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'playerId': playerId});
    }
  }

  Future<void> _login() async {
    final formState = formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);

        // Actualiza el Player ID de OneSignal en la base de datos después de iniciar sesión con éxito
        updateOneSignalPlayerId(userCredential.user!.uid);
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
            key: formKey,
            child: ListView(
              children: [
                SizedBox(height: screenHeight * .12),
                const Text(
                  'Empezemos',
                  style: TextStyle(
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: screenHeight * .05),
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
                  keyboardType: TextInputType.emailAddress,
                  hint: 'Password',
                  theme: FilledOrOutlinedTextTheme(
                    enabledColor: Colors.grey,
                    focusedColor: Colors.blue,
                    fillColor: Colors.white70,
                    // You can use all properties of FilledOrOutlinedTextTheme
                    // to decor text field
                  ),
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  obscureText: true,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onChanged: (String? value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _login();
                    }
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
