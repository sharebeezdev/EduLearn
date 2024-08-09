import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/trending_topicprovider.dart';
import 'widgets/quiz_card.dart';

class ViewAllPage extends StatefulWidget {
  final String quizType;

  const ViewAllPage({Key? key, required this.quizType}) : super(key: key);

  @override
  _ViewAllPageState createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  @override
  void initState() {
    super.initState();
    _loadAllQuizzes();
  }

  Future<void> _loadAllQuizzes() async {
    final provider = _getProvider();
    if (provider != null) {
      await provider.fetchQuizzes(fetchAll: true);
    }
  }

  dynamic _getProvider() {
    switch (widget.quizType) {
      case 'TrendingTopic':
        return Provider.of<TrendingTopicProvider>(context, listen: false);
      case 'Topics':
        return Provider.of<TopicsProvider>(context, listen: false);
      case 'Subject':
        return Provider.of<SubjectsProvider>(context, listen: false);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _getProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.quizType} Quizzes'),
      ),
      body: Consumer<TrendingTopicProvider>(
        builder: (context, provider, _) {
          final quizzes = provider.quizzes;

          if (quizzes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.network(
                    quizzes[index].imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                  title: Text(quizzes[index].title),
                  subtitle: Text(
                    quizzes[index].description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Navigate to quiz details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
