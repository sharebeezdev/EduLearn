import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_page.dart';
import 'models/quiz_question.dart';
import 'quiz_details.dart';
import 'widgets/custom_appbar.dart';

class DetailedFeedbackPage extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<int, String> selectedAnswers;
  final String quizId;
  final String quizTitle;
  final String quizType;
  final String topicName;
  const DetailedFeedbackPage({
    required this.questions,
    required this.selectedAnswers,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detailed Feedback',
        isBackButtonVisible: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
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
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetails(
                          quizId: quizId,
                          title: quizTitle,
                          quizType: quizType,
                          topicName: topicName,
                        ),
                      ),
                    );
                  },
                  child: Text('Retake'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Text('Explore More'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cleanUrl(String urlString) {
    final match = RegExp(r'\[(.*?)\]\((.*?)\)').firstMatch(urlString);
    if (match != null) {
      return match.group(2)!;
    } else {
      return urlString;
    }
  }

  void _launchURL(String url) async {
    String cleanedUrl = _cleanUrl(url);
    if (cleanedUrl.isNotEmpty &&
        Uri.tryParse(cleanedUrl)?.hasAbsolutePath == true) {
      try {
        if (await canLaunchUrl(Uri.parse(cleanedUrl))) {
          await launchUrl(Uri.parse(cleanedUrl));
        } else {
          throw Exception('Could not launch $cleanedUrl');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      throw Exception('Invalid URL: $cleanedUrl');
    }
  }
}
