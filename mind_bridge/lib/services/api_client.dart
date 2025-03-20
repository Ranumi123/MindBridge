import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    final response = await http.get(Uri.parse('$baseUrl/groups'));
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String groupId) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/$groupId/messages'));
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<void> sendMessage(String groupId, String message) async {
    await http.post(
      Uri.parse('$baseUrl/groups/$groupId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );
  }
}
