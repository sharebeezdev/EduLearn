import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../quiz_details.dart';
import '../models/quiz.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    Key? key,
    required this.quiz,
  }) : super(key: key);

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    // Trimming the description if it's longer than 80 characters
    String trimmedDescription = quiz.description.length > 80
        ? '${quiz.description.substring(0, 80)}...'
        : quiz.description;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetails(
              quizId: quiz.id.toString(),
              title: quiz.title,
              quizType: quiz.type,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: Container(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: quiz.imageUrl.isNotEmpty ? quiz.imageUrl : '',
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Image.asset(
                    'assets/images/gcp.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 100,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Image.asset(
                    'assets/images/gcp.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trimmedDescription,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Colors.black87,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
