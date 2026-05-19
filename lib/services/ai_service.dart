import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AIService {

  static Future<List<String>> generateSubtasks(String task) async {

    final response = await http.post(
      Uri.parse("${APIConfig.baseUrl}/api/ai/break-task/"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "task": task,
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return List<String>.from(data["subtasks"]);

    } else {
      throw Exception("Failed to generate subtasks");
    }
  }
}