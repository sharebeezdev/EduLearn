import 'package:edu_learn/databaseutils/db_helper.dart';
import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_utils.dart';
import 'models/quiz_question.dart';
import 'score_feedback_page.dart';

class QuizDetails extends StatefulWidget {
  final String quizId;
  final String title;
  final String quizType;
  final String topicName;

  const QuizDetails({
    required this.quizId,
    required this.title,
    required this.quizType,
    required this.topicName,
  });

  @override
  _QuizDetailsState createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  late Future<List<QuizQuestion>> _questionsFuture;
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _questionsFuture =
        DBUtils().fetchQuizQuestions(widget.quizId, widget.quizType);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _submitQuiz() async {
    int correctAnswers = 0;
    for (var question in _questions) {
      if (_selectedAnswers[question.questionNumber] == question.correctChoice) {
        correctAnswers++;
      }
    }
    double score = (correctAnswers / _questions.length) * 100;

    // Insert the score into the database
    await DBUtils()
        .insertQuizScoreDetails(score, widget.quizId, widget.topicName);
    print('topicName is ' + widget.topicName);
    // Navigate to the score feedback page
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScoreFeedbackPage(
        score: score,
        questions: _questions,
        selectedAnswers: _selectedAnswers,
        quizId: widget.quizId,
        quizTitle: widget.title,
        quizType: widget.quizType,
        topicName: widget.topicName,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        isBackButtonVisible: false,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No questions available'));
          } else {
            _questions = snapshot.data!;
            var question = _questions[_currentIndex];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(_currentIndex),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.questionText,
                          style: const TextStyle(fontSize: 18),
                        ),
                        ...question.choices.map((choice) {
                          return RadioListTile(
                            title: Text(choice),
                            value: choice,
                            groupValue:
                                _selectedAnswers[question.questionNumber],
                            onChanged: (value) {
                              setState(() {
                                _selectedAnswers[question.questionNumber] =
                                    value!;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentIndex > 0)
                        ElevatedButton(
                          onPressed: _previousQuestion,
                          child: const Text('Previous'),
                        ),
                      if (_currentIndex < _questions.length - 1)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: const Text('Next'),
                        ),
                      if (_currentIndex == _questions.length - 1)
                        ElevatedButton(
                          onPressed: _submitQuiz,
                          child: const Text('Submit'),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
