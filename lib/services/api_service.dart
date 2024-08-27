import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = "https://hcperuaqp.com/api/users";

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }
}