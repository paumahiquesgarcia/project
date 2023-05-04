import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> sendNotification(String userId, String message) async {
  final response = await http.post(
    Uri.parse('http://192.168.56.1:3000/sendNotification'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'message': message}),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al enviar la notificación.');
  }
}
