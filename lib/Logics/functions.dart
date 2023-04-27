import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print(e);
    }
  }
}
