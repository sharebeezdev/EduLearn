import 'package:flutter/material.dart';
import 'detailed_feedback_page.dart';
import 'models/quiz_question.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/custom_button.dart';
import 'home_page.dart';

class ScoreFeedbackPage extends StatelessWidget {
  final double score;
  final List<QuizQuestion> questions;
  final Map<int, String> selectedAnswers;
  final String quizId;
  final String quizTitle;
  final String quizType;
  final String topicName;

  const ScoreFeedbackPage({
    required this.score,
    required this.questions,
    required this.selectedAnswers,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
    required this.topicName,
  });

  String _getFeedbackMessage(double score) {
    if (score == 100) return "Great job!";
    if (score >= 80) return "Excellent work!";
    if (score >= 50) return "Good effort, but there's room for improvement.";
    return "Keep trying!";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Quiz Results',
          isBackButtonVisible: false,
        ),
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
                        style:
                            const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        score == 100 ? Icons.star : Icons.star_border,
                        color: Colors.yellow,
                        size: 50,
                      ),
                      Text(
                        _getFeedbackMessage(score),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DetailedFeedbackPage(
                      questions: questions,
                      selectedAnswers: selectedAnswers,
                      quizId: quizId,
                      quizTitle: quizTitle,
                      quizType: quizType,
                      topicName: topicName,
                    ),
                  ));
                },
                text: 'See Detailed Feedback',
              ),
              const SizedBox(height: 10),
              CustomButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                text: 'Explore More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
