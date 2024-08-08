import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/quiz_card.dart';
import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/trending_topicprovider.dart';

class QuizListHorizontalView extends StatelessWidget {
  final String quizType;

  const QuizListHorizontalView({
    Key? key,
    required this.quizType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, watch, child) {
        List quizzes = [];
        if (quizType == 'TrendingTopic') {
          quizzes = Provider.of<TrendingTopicProvider>(context).quizzes;
        } else if (quizType == 'Topics') {
          quizzes = Provider.of<TopicsProvider>(context).quizzes;
        } else if (quizType == 'Subject') {
          quizzes = Provider.of<SubjectsProvider>(context).quizzes;
        }

        if (quizzes.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quizzes.map((quiz) => QuizCard(quiz: quiz)).toList(),
          ),
        );
      },
    );
  }
}
