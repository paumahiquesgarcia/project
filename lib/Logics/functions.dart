import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Functions {
  static void updateAvailability() {
    final _firestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final data = {
      'date_time': DateTime.now(),
    };
    try {
      _firestore.collection('Users').doc(_auth.currentUser!.uid).update(data);
    } catch (e) {
      print(e);
    }
  }
}
