import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/quiz_question.dart';

class DetailedFeedbackPage extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, String> selectedAnswers;

  const DetailedFeedbackPage({
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detailed Feedback')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final selectedAnswer = selectedAnswers[question.questionNumber];
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.questionText,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...question.choices.map((choice) {
                    return Text(
                      choice,
                      style: TextStyle(
                        color: selectedAnswer == choice
                            ? (question.correctChoice == choice
                                ? Colors.green
                                : Colors.red)
                            : Colors.black,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  if (selectedAnswer != null)
                    Text(
                      'Selected: $selectedAnswer',
                      style: const TextStyle(
                          fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 8),
                  if (question.correctChoice != selectedAnswer)
                    Text(
                      'Correct Answer: ${question.correctChoice}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (question.reason.isNotEmpty)
                    Text(
                      'Reason: ${question.reason}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  if (question.links.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text('Learn more:'),
                        ...question.links.split(',').map((link) {
                          return GestureDetector(
                            onTap: () => _launchURL(link),
                            child: Text(
                              _cleanUrl(link),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _cleanUrl(String urlString) {
    final match = RegExp(r'\[(.*?)\]\((.*?)\)').firstMatch(urlString);
    if (match != null) {
      // Group 2 contains the actual URL within parentheses
      return match.group(2)!;
    } else {
      // Handle cases where the URL is not formatted as expected
      return urlString; // Or return an empty string if desired
    }
  }

  void _launchURL(String url) async {
    // Clean and extract the URL
    String cleanedUrl = _cleanUrl(url);
    print('Cleaned URL: $cleanedUrl');

    // Check if the cleaned URL is valid
    if (cleanedUrl.isNotEmpty &&
        Uri.tryParse(cleanedUrl)?.hasAbsolutePath == true) {
      try {
        if (await canLaunchUrl(Uri.parse(cleanedUrl))) {
          await launchUrl(Uri.parse(cleanedUrl));
        } else {
          // Handle the case when the URL cannot be launched
          throw Exception('Could not launch $cleanedUrl');
        }
      } catch (e) {
        // Handle exceptions
        print('Error launching URL: $e');
      }
    } else {
      // Handle invalid URL scenario
      throw Exception('Invalid URL: $cleanedUrl');
    }
  }
}
