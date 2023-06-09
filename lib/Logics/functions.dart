import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Functions {
  static void updateAvailability() {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final data = {
      'date_time': DateTime.now(),
    };
    try {
      firestore.collection('Users').doc(auth.currentUser!.uid).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
