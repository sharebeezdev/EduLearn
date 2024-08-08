import 'package:edu_learn/dataupload_page.dart';
import 'package:flutter/material.dart';
import 'package:edu_learn/home_page.dart';
import 'package:edu_learn/databaseutils/db_utils.dart';
import 'package:edu_learn/databaseutils/service_helper.dart';
import 'package:edu_learn/widgets/custom_appbar.dart';

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
        appBar: CustomAppBar(title: 'Recommendations'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 50, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'We are generating personalized recommendations for you!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please bear with us as we analyze your preferences and find the best topics to enhance your learning experience.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
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
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(
                    'Favorite Topics',
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: _removeTopics,
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _favoriteTopics.map((topic) {
                      return FilterChip(
                        label: Text(topic),
                        selected: _selectedTopics.contains(topic),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTopics.add(topic);
                            } else {
                              _selectedTopics.remove(topic);
                            }
                          });
                        },
                        backgroundColor: _getRandomLightColor(),
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
                          setState(() {
                            if (selected) {
                              _selectedTopics.add(topic);
                            } else {
                              _selectedTopics.remove(topic);
                            }
                          });
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
              onPressed: () async {
                await DBUtils().clearSubjects();
                await DBUtils().clearTopics();
                // await DBUtils().clearTopicsOfInterest();
                // Insert new data
                for (var subject in _favoriteSubjects) {
                  await DBUtils().insertSubject({'name': subject});
                }

                for (var topic in _favoriteTopics) {
                  await DBUtils().insertTopic({'title': topic});
                }

                // print('suggested topocics are ' + _suggestedTopics.toString());
                // for (var topic in _suggestedTopics) {
                //   await DBUtils().insertTopicOfInterest({'name': topic});
                // }

                await DBUtils().setSurveyCompleted();

                // Navigate to HomePage immediately
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DataUploadPage()),
                  );
                }
                // Fetch quizzes in the background
                _fetchAndNotifyUser();
              },
              child: const Text('Save Data'),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 50), // Full width and fixed height
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndNotifyUser() async {
    await DBUtils().fetchAndSaveQuizzes();

    // Show an alert dialog after fetching quizzes
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Content Generated'),
            content: const Text(
              'Gemini AI has generated useful content for you based on your interests. Please check the latest updates in your profile.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Optionally, refresh HomePage if needed
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
