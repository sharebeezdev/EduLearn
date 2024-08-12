import 'package:edu_learn/new-home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ai_suggestions_page.dart';
import 'ideas.dart';
import 'initial_survey.dart';
import 'insights.dart';
import 'learning_path_suggestions.dart';
import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/trending_topicprovider.dart';
import 'widgets/custom_appbar.dart';
import 'quiz_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Titles for each tab
  final List<String> _titles = [
    'EduLearn',
    'Insights',
    'Ideas',
    'Initial Survey',
    'AI Suggestions',
    // Added Insights title
  ];

  // State variable to hold the current title
  String _appBarTitle = 'EduLearn';

  final List<Widget> _pages = [
    HomeContent(),
    InsightsPage(),
    IdeasPage(),
    InitialSurveyScreen(),
    //  AiSuggestionsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle =
          _titles[index]; // Update the title based on the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final trendingTopicProvider = Provider.of<TrendingTopicProvider>(context);
    final topicsProvider = Provider.of<TopicsProvider>(context);
    final subjectsProvider = Provider.of<SubjectsProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (trendingTopicProvider.quizzes.isEmpty)
        trendingTopicProvider.fetchQuizzes();
      if (topicsProvider.quizzes.isEmpty) topicsProvider.fetchQuizzes();
      if (subjectsProvider.quizzes.isEmpty) subjectsProvider.fetchQuizzes();
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CustomAppBar(
          title: _appBarTitle,
          isBackButtonVisible: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AiSuggestionsPage()),
            );
          },
          child: SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/images/ai_icon.png',
            ),
          ),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.purple,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'Insights', // Added Insights tab
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: 'Ideas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trendingTopicProvider = Provider.of<TrendingTopicProvider>(context);
    final topicsProvider = Provider.of<TopicsProvider>(context);
    final subjectsProvider = Provider.of<SubjectsProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quizzes: Topics',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 200,
              child: QuizListHorizontalView(
                quizType: 'Topics',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quizzes: Subjects',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 200,
              child: QuizListHorizontalView(
                quizType: 'Subject',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Featured Quizzes',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            const SizedBox(
              height: 200,
              child: QuizListHorizontalView(
                quizType: 'TrendingTopic',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Learning Paths',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 270,
              child: LearningPathSuggestions(),
            ),
            Text(
              'Topics to Explore',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            topicsProvider.quizzes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topicsProvider.quizzes.length,
                    itemBuilder: (context, index) {
                      final topic = topicsProvider.quizzes[index];
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
    );
  }
}
