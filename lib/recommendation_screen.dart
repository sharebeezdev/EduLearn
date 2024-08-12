import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:edu_learn/home_page.dart';
import 'package:edu_learn/databaseutils/db_utils.dart';
import 'package:edu_learn/databaseutils/service_helper.dart';
import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:edu_learn/dataupload_page.dart';
import 'package:edu_learn/databaseutils/gemini.dart';

import 'loading_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  final String subjects;
  final String topics;

  RecommendationsScreen({required this.subjects, required this.topics});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<String> _favoriteSubjects = [];
  List<String> _favoriteTopics = [];
  List<String> _suggestedTopics = [];
  final List<String> _selectedTopics = [];
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _favoriteSubjects =
        widget.subjects.split(',').where((s) => s.isNotEmpty).toList();
    _favoriteTopics =
        widget.topics.split(',').where((t) => t.isNotEmpty).toList();
    _fetchTrendingTopics();
  }

  Future<void> _fetchTrendingTopics() async {
    try {
      final topics = await MyService.fetchTrendingTopics(
        topics: widget.topics,
        subjects: widget.subjects,
      );
      setState(() {
        _suggestedTopics = topics;
        _isLoading = false; // Data fetched, stop loading
      });
    } catch (e) {
      // Handle errors here
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch trending topics')),
      );
    }
  }

  Future<void> _updateTopics(
      {required List<String> topicsToAdd,
      required List<String> topicsToRemove}) async {
    if (topicsToAdd.isNotEmpty) {
      setState(() {
        _favoriteTopics.addAll(topicsToAdd);
      });
    }
    if (topicsToRemove.isNotEmpty) {
      setState(() {
        _favoriteTopics.removeWhere((topic) => topicsToRemove.contains(topic));
      });
    }

    await _fetchTrendingTopics();
  }

  void _addTopics() {
    if (_selectedTopics.isNotEmpty) {
      _updateTopics(topicsToAdd: _selectedTopics, topicsToRemove: []);
      setState(() {
        _selectedTopics.clear(); // Clear selected topics after adding
      });
    }
  }

  void _removeTopics() {
    if (_favoriteTopics.isNotEmpty) {
      _updateTopics(
          topicsToAdd: [],
          topicsToRemove: _favoriteTopics
              .where((t) => _selectedTopics.contains(t))
              .toList());
      setState(() {
        _selectedTopics.clear(); // Clear selected topics after removal
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _favoriteSubjects.remove(subject);
    });
  }

  void _removeTopic(String topic) {
    setState(() {
      _favoriteTopics.remove(topic);
    });
  }

  Future<void> _processAndNavigate(BuildContext context) async {
    // Show the loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingScreen(
          message: 'Personalizing your learning experience. Please wait...',
        ),
      ),
    );

    try {
      // Perform data processing
      await DBUtils().clearSubjects();
      await DBUtils().clearTopics();
      await DBUtils().clearTopicsOfInterest();
      for (var subject in _favoriteSubjects) {
        await DBUtils().insertSubject({'name': subject});
      }

      for (var topic in _favoriteTopics) {
        await DBUtils().insertTopic({'title': topic});
      }
      int i = 0;
      print('suggested topics ' + _suggestedTopics.toString());
      for (var topic in _suggestedTopics) {
        i++;
        if (i < 3) {
          await DBUtils().insertTrendingTopic({'topic': topic});
        }
      }

      // Fetch and insert quiz data
      await Future.wait([
        _processQuizzes('Topics', _favoriteTopics),
        _processQuizzes('Subjects', _favoriteSubjects),
        _processQuizzes('TrendingTopics', _suggestedTopics),
        _processLearningPaths(_favoriteTopics),
        _processLearningPaths(_favoriteSubjects),
        _processLearningPaths(_suggestedTopics),
      ]);

      await DBUtils().setSurveyCompleted();
    } finally {
      // Ensure the loading screen is removed and navigate to DataUploadPage
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the loading screen
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DataUploadPage()),
        );
      }
    }
  }

  Color _getRandomLightColor() {
    List<Color> lightColors = [
      Colors.pink[100]!,
      Colors.purple[100]!,
      Colors.deepPurple[100]!,
      Colors.indigo[100]!,
      Colors.blue[100]!,
      Colors.teal[100]!,
      Colors.green[100]!,
      Colors.lightGreen[100]!,
      Colors.lime[100]!,
      Colors.yellow[100]!,
      Colors.amber[100]!,
      Colors.orange[100]!,
    ];
    return (lightColors..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show loading screen while data is being fetched
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Recommendations',
          isBackButtonVisible: false,
        ),
        body: const LoadingScreen(
          message: 'Preparing personalized recommendations just for you!',
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Recommendations'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader('Favorite Subjects'),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _favoriteSubjects.map((subject) {
                      return Chip(
                        label: Text(subject),
                        backgroundColor: _getRandomLightColor(),
                        deleteIcon: const Icon(Icons.cancel),
                        onDeleted: () {
                          _removeSubject(subject);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(
                    'Favorite Topics',
                    // trailing: IconButton(
                    //   icon: const Icon(Icons.remove_circle),
                    //   onPressed: _removeTopics,
                    // ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _favoriteTopics.map((topic) {
                      return Chip(
                        label: Text(topic),
                        backgroundColor: _getRandomLightColor(),
                        deleteIcon: const Icon(Icons.cancel),
                        onDeleted: () {
                          _removeTopic(topic);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(
                    'Suggested Topics',
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _addTopics,
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _suggestedTopics.map((topic) {
                      return FilterChip(
                        label: Text(topic),
                        selected: _selectedTopics.contains(topic),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _favoriteTopics.add(topic);
                              _suggestedTopics.remove(topic);
                            });

                            // Perform the API call outside of setState
                            _fetchTrendingTopics();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _processAndNavigate(context),
              //  onPressed: () async {
              // Show the loading screen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const LoadingScreen(
              //       message:
              //           'Personalizing your learning experience. Please wait...',
              //     ),
              //   ),
              // );

              // // Perform data processing
              // await DBUtils().clearSubjects();
              // await DBUtils().clearTopics();

              // for (var subject in _favoriteSubjects) {
              //   await DBUtils().insertSubject({'name': subject});
              // }

              // for (var topic in _favoriteTopics) {
              //   await DBUtils().insertTopic({'title': topic});
              // }

              // for (var topic in _suggestedTopics) {
              //   await DBUtils().insertTrendingTopic({'topic': topic});
              // }

              // // Fetch and insert quiz data
              // Future.wait([
              //   _processQuizzes('Topics', _favoriteTopics),
              //   _processQuizzes('Subjects', _favoriteSubjects),
              //   _processQuizzes('TrendingTopics', _suggestedTopics),
              //   _processLearningPaths(_favoriteTopics),
              //   _processLearningPaths(_favoriteSubjects),
              //   _processLearningPaths(_suggestedTopics),
              // ]);

              // await DBUtils().setSurveyCompleted();

              // // Navigate to DataUploadPage
              // if (mounted) {
              //   Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(builder: (context) => DataUploadPage()),
              //   );
              // }
              //   },
              child: const Text('Save Data'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50), // Full width and fixed height
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processQuizzes(String quizType, List<String> topics) async {
    // Limit the loop to the first three topics
    for (var i = 0; i < topics.length && i < 3; i++) {
      var topic = topics[i];
      try {
        print('Inserting quiz for quizzes for quizType $quizType and topoic ' +
            topic);
        Map<String, dynamic> quizData =
            await Gemini.getQuizzes(topics: [topic]);

        String jsonResponse = jsonEncode(quizData);
        await DBUtils().insertQuizzes(jsonResponse, quizType);
        print(
            'Inserting quiz forquizzes for quizType $quizType and topoic end ' +
                topic);
      } catch (e) {
        print(
            'Failed to fetch or insert quizzes for quizType $quizType and topic $topic: $e');
      }
    }
  }

  Future<void> _processLearningPaths(List<String> topics) async {
    for (var i = 0; i < topics.length && i < 3; i++) {
      print('_processLearningPaths topics are ' + topics.toString());
      var topic = topics[i];
      try {
        print('Getting learning paths for topics $topic');
        Map<String, dynamic> quizData =
            await Gemini.getLearningPaths(topic: topic);

        String jsonResponse = jsonEncode(quizData);
        Gemini.printPayloadInChunks(jsonResponse);
        await DBUtils().insertLearningPathData(jsonResponse);
      } catch (e) {
        print(
            'Failed to fetch or insert _processLearningPaths for topic $topics: $e');
      }
    }
  }

  Widget _buildHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
