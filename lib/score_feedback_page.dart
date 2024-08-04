import 'package:flutter/material.dart';

import 'detailed_feedback_page.dart';
import 'models/quiz_question.dart';

class ScoreFeedbackPage extends StatelessWidget {
  final double score;
  final List<QuizQuestion> questions;
  final Map<int, String> selectedAnswers;

  const ScoreFeedbackPage({
    required this.score,
    required this.questions,
    required this.selectedAnswers,
  });

  String _getFeedbackMessage(double score) {
    if (score == 100) return "Great job!";
    if (score >= 80) return "Excellent work!";
    if (score >= 50) return "Good effort, but there's room for improvement.";
    return "Keep trying!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${score.toStringAsFixed(2)}%",
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      score == 100 ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 50,
                    ),
                    Text(
                      _getFeedbackMessage(score),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailedFeedbackPage(
                    questions: questions,
                    selectedAnswers: selectedAnswers,
                  ),
                ));
              },
              child: const Text('See Detailed Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
