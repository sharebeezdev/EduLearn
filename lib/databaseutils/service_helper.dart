import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'db_helper.dart';

class MyService {
  static Future<List<String>> fetchTrendingTopics({
    required String topics,
    required String subjects,
  }) async {
    // Create base instructions
    List<String> instructions = [
      "Please suggest some trendy topics to learn.",
      "If user provides any topics that he already have then suggest some more topics based on his input else suggest trendy topics for learning purpose",
      "Response should return top 10 topics names only",
      "response should contain topic names as comma separate values, such that i can parse. generate a json response with topics as key and value as your suggestions"
    ];

    // Add custom instructions if topics or subjects are provided
    if (topics.isNotEmpty) {
      instructions.insert(0, "User is interested in these topics: $topics");
    }
    if (subjects.isNotEmpty) {
      instructions.insert(0, "User is interested in these subjects: $subjects");
    }

    // Construct the request payload
    final requestPayload = {
      "instructions": instructions,
    };

    final String requestPayloadJson = jsonEncode(requestPayload);
    final String apiUrl =
        'https://google-gemini-hackathon.onrender.com/gemini?promt=${Uri.encodeComponent(requestPayloadJson)}';

    print('Sending request to API URL: $apiUrl');
    final response = await http.get(Uri.parse(apiUrl));

    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      String cleanedResponse =
          response.body.replaceAll('```json', '').replaceAll('```', '').trim();
      Map<String, dynamic> data = json.decode(cleanedResponse);
      String topicsString = data['topics'];
      List<String> topics =
          topicsString.split(',').map((topic) => topic.trim()).toList();
      return topics;
    } else {
      throw Exception('Failed to load trending topics');
    }
  }

  static Future<List<String>> fetchSuggestionsFromExamData(
      String jsonData) async {
    final apiUrl = 'https://google-gemini-hackathon.onrender.com/gemini';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['suggestions']);
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
