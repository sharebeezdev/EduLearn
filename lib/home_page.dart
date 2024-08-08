import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'providers/trending_topicprovider.dart';
import 'widgets/custom_appbar.dart';
import 'profile_setup_page.dart';
import 'quiz_list.dart';
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
                const SizedBox(height: 10),
                const SizedBox(
                  height: 200,
                  child: QuizListHorizontalView(
                    quizType: 'TrendingTopic',
                  ),
                ),
                const SizedBox(height: 16),
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
      ),
    );
  }
}
