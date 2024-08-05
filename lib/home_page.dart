import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/topic_provider.dart';
import 'profile_setup_page.dart';
import 'quiz_suggestion_page.dart';
import 'widgets/quiz_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileSetupPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final ideaProvider = Provider.of<IdeaProvider>(context);
    final topicProvider = Provider.of<TopicProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (quizProvider.quizzes.isEmpty) quizProvider.loadQuizzes();
      if (ideaProvider.ideas.isEmpty) ideaProvider.fetchIdeas();
      if (topicProvider.topics.isEmpty) topicProvider.fetchTopics();
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'EduLearn',
        isBackButtonVisible: false,
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
              const SizedBox(height: 8),
              quizProvider.quizzes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: quizProvider.quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizProvider.quizzes[index];
                          return QuizCard(quiz: quiz);
                        },
                      ),
                    ),
              const SizedBox(height: 16),
              QuizSuggestionsWidget(), // Add the new quiz suggestions widget here
              const SizedBox(height: 16),
              Text(
                'Ideas & Suggestions',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              ideaProvider.ideas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ideaProvider.ideas.length,
                      itemBuilder: (context, index) {
                        final idea = ideaProvider.ideas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(idea.title),
                            subtitle: Text(idea.description),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),
              Text(
                'Topics to Explore',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              topicProvider.topics.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topicProvider.topics.length,
                      itemBuilder: (context, index) {
                        final topic = topicProvider.topics[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
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
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.purple,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.help,
              ),
              label: 'Help'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.lightbulb,
              ),
              label: 'Ideas'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              label: 'Settings'),
        ],
      ),
    );
  }
}
