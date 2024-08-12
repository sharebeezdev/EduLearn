import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_utils.dart';

class Gemini {
  // Define the base URL at the class level for easy modification
  // static const String _baseUrl = 'https://google-gemini-hackathon.onrender.com';
  static const String _baseUrl =
      'https://codelab-gemini-ai-2r5l3cycfq-uc.a.run.app';

  // Common method to handle GET requests
  static Future<Map<String, String>> fetchAIResponse(String text) async {
    final String apiUrl = '$_baseUrl/gemini?prompt=$text';

    return _handleGetRequest(apiUrl, 'Gemini');
  }

  // Common method to handle POST requests with JSON responses
  static Future<Map<String, dynamic>> postJsonRequest(
      String endpoint, Map<String, dynamic> payload) async {
    final String apiUrl = '$_baseUrl$endpoint';
    final response = await _handlePostRequest(apiUrl, payload);
    return _parseJsonResponse(response);
  }

  static Future<Map<String, dynamic>> getQuizzes({
    required List<String> topics,
  }) async {
    final Map<String, dynamic> requestPayload = {"topics": topics};
    return postJsonRequest('/gemini/quiz', requestPayload);
  }

  static Future<Map<String, dynamic>> getLearningPaths({
    required String topic,
  }) async {
    final Map<String, dynamic> requestPayload = {"title": topic};
    return postJsonRequest('/gemini/learningpath', requestPayload);
  }

  static Future<Map<String, dynamic>> getIdeas() async {
    final requestPayload = await DBUtils().createJsonRequestBody();

    printPayloadInChunks(requestPayload);
    return postJsonRequest('/gemini/ideas', jsonDecode(requestPayload));
  }

  static Future<Map<String, dynamic>> getQuizByTopic(String topic) async {
    final Map<String, String> requestPayload = {"topic": topic};
    return postJsonRequest('/gemini-quiz', requestPayload);
  }

  // Private method to handle GET requests
  static Future<Map<String, String>> _handleGetRequest(
      String url, String sender) async {
    try {
      final response = await http.get(Uri.parse(url));
      _logResponse(response);

      if (response.statusCode == 200) {
        return {'sender': sender, 'text': response.body};
      } else {
        return _defaultErrorResponse(sender);
      }
    } catch (error) {
      print('Error fetching $sender response: $error');
      return _defaultErrorResponse(sender);
    }
  }

  // Private method to handle POST requests
  static Future<http.Response> _handlePostRequest(
      String url, Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      _logResponse(response);
      return response;
    } catch (error) {
      print('Error posting request to $url: $error');
      throw Exception('Failed to complete request.');
    }
  }

  // Private method to parse JSON responses
  static Map<String, dynamic> _parseJsonResponse(http.Response response) {
    if (response.statusCode == 200) {
      String cleanResponseBody =
          response.body.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanResponseBody) as Map<String, dynamic>;
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to fetch data');
    }
  }

  // Utility method to log the response
  static void _logResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    // Uncomment the line below to log the full response body if needed
    // _printPayloadInChunks(response.body);
  }

  // Utility method to print payload in chunks for large responses
  static void printPayloadInChunks(String payload) {
    const int chunkSize = 1000;
    for (int i = 0; i < payload.length; i += chunkSize) {
      print(payload.substring(
          i, i + chunkSize > payload.length ? payload.length : i + chunkSize));
    }
  }

  // Utility method to return a default error response
  static Map<String, String> _defaultErrorResponse(String sender) {
    return {
      'sender': sender,
      'text': 'Oops! Something went wrong. Please try again.',
    };
  }
}
