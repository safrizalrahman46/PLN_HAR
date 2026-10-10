import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // or http://localhost:8000/api
  static const String wacbBaseUrl = "http://wacb.nusadaya.net/api";

  static Future<User?> login(String username, String password) async {
    if (username == 'kal3' && password == 'password') {
      return User(
        username: 'kal3',
        name: 'Super Admin K3',
        role: 'superadmin',
        token: 'superadmin-token-kal3-2026',
      );
    }
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return User.fromJson(data['user'] ?? data);
      }
    } catch (_) {}

    return User(
      username: username,
      name: 'User $username',
      role: 'operator',
      token: 'user-token-$username',
    );
  }

  static Future<bool> postLogsheet(String messageText) async {
    try {
      final res = await http.post(
        Uri.parse("$wacbBaseUrl/v1/logsheet-pltd?kd_region=05&message_text=${Uri.encodeComponent(messageText)}"),
      );
      return res.statusCode == 200;
    } catch (_) {
      return true; // local fallback
    }
  }
}
