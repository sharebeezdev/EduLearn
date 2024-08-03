import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/topic_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final ideaProvider = Provider.of<IdeaProvider>(context);
    final topicProvider = Provider.of<TopicProvider>(context);

    // Fetch data when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (quizProvider.quizzes.isEmpty) quizProvider.loadQuizzes();
      if (ideaProvider.ideas.isEmpty) ideaProvider.fetchIdeas();
      if (topicProvider.topics.isEmpty) topicProvider.fetchTopics();
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EduLearn',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              'Powered by Gemini AI',
              style: Theme.of(context).textTheme.caption?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        toolbarHeight: 80, // Adjust height to fit content
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Quizzes',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              quizProvider.quizzes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      height: 200, // Adjusted height to accommodate text
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: quizProvider.quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizProvider.quizzes[index];
                          return Card(
                            margin: EdgeInsets.only(right: 16),
                            child: Container(
                              width: 200, // Fixed width for the card
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    quiz.imageUrl,
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          quiz.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          quiz.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                          // Removed overflow and maxLines to allow wrapping
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(height: 16),
              Text(
                'Ideas & Suggestions',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              ideaProvider.ideas.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: ideaProvider.ideas.length,
                      itemBuilder: (context, index) {
                        final idea = ideaProvider.ideas[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(idea.title),
                            subtitle: Text(idea.description),
                          ),
                        );
                      },
                    ),
              SizedBox(height: 16),
              Text(
                'Topics to Explore',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              topicProvider.topics.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: topicProvider.topics.length,
                      itemBuilder: (context, index) {
                        final topic = topicProvider.topics[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(topic.title),
                            subtitle: Text(
                              topic.description,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Help'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Ideas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
