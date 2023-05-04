import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:project/paginas/login_screen.dart';
import 'paginas/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureOneSignal();
  requestNotificationPermission();
  runApp(const MyApp());
}

void requestNotificationPermission() async {
  await OneSignal.shared.promptUserForPushNotificationPermission();
}

void configureOneSignal() async {
  await OneSignal.shared.setAppId("4cfb71c8-b361-4850-9d5c-35b258ecb176");

  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    // Controla cómo se muestran las notificaciones en primer plano
    event.complete(event.notification);
  });

  OneSignal.shared.setNotificationOpenedHandler(
    (OSNotificationOpenedResult result) {
      // Maneja la acción al abrir una notificación
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MyHomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
