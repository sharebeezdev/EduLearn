import 'dart:convert';

import 'package:http/http.dart' as http;

class Gemini {
  static Future<Map<String, String>> fetchAIResponse(String text) async {
    final String apiUrl =
        'https://google-gemini-hackathon.onrender.com/gemini?promt=$text';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('response code ' + response.statusCode.toString());
      print('response body ' + response.body.toString());

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Process the response as plain text
        return {
          'sender': 'Gemini',
          'text': responseBody,
        };
      } else {
        print(
            'Failed to fetch AI response. Status code: ${response.statusCode}');
        return {
          'sender': 'AI Tutor',
          'text': 'Oops! Something went wrong. Please try again.',
        };
      }
    } catch (error) {
      print('Error fetching AI response: $error');
      return {
        'sender': 'AI Tutor',
        'text': 'Oops! Something went wrong. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getQuizes({
    required List<String> topics,
  }) async {
    // Define the API endpoint
    final String apiUrl =
        'https://google-gemini-hackathon.onrender.com/gemini/quiz';

    // Construct the request payload
    final Map<String, dynamic> requestPayload = {
      "topics": topics,
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    // Print the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle the response
    if (response.statusCode == 200) {
      // Clean the response body by removing backticks and other extraneous content
      String cleanResponseBody =
          response.body.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parse the cleaned JSON response

      Map<String, dynamic> result =
          jsonDecode(cleanResponseBody) as Map<String, dynamic>;

      return result;
    } else {
      throw Exception('Failed to create quiz');
    }
  }

  static Future<Map<String, dynamic>> getLearningPaths({
    required String topic,
  }) async {
    // Define the API endpoint
    final String apiUrl =
        'https://google-gemini-hackathon.onrender.com/gemini/learningpath';

    // Construct the request payload
    final Map<String, dynamic> requestPayload = {
      "title": topic,
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    // Print the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle the response
    if (response.statusCode == 200) {
      // Clean the response body by removing backticks and other extraneous content
      String cleanResponseBody =
          response.body.replaceAll('```json', '').replaceAll('```', '').trim();

      // Parse the cleaned JSON response

      Map<String, dynamic> result =
          jsonDecode(cleanResponseBody) as Map<String, dynamic>;

      return result;
    } else {
      throw Exception('Failed to create quiz');
    }
  }
}
