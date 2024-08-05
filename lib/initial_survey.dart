import 'package:edu_learn/databaseutils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_helper.dart';
import 'recommendation_screen.dart'; // Assuming you have DBHelper configured

class InitialSurveyScreen extends StatefulWidget {
  @override
  _InitialSurveyScreenState createState() => _InitialSurveyScreenState();
}

class _InitialSurveyScreenState extends State<InitialSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final List<String> _favoriteSubjects = [];
  final List<String> _favoriteTopics = [];
  String areaOfDifficulty = '';
  String preferredLearningStyle = '';

  void _submitSurvey() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save BuildContext in a local variable
      final context = this.context;

      await DBHelper().insertSurveyData({
        'areaOfDifficulty': areaOfDifficulty,
        'preferredLearningStyle': preferredLearningStyle,
      });

      for (var subject in _favoriteSubjects) {
        await DBUtils().insertSubject({'name': subject});
      }

      for (var topic in _favoriteTopics) {
        await DBUtils().insertTopic({'title': topic});
      }

      // Perform navigation after async operations are complete
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationsScreen(
              subjects: _favoriteSubjects.join(', '),
              topics: _favoriteTopics.join(', '),
            ),
          ),
        );
      }
    }
  }

  void _addSubject() {
    if (_subjectController.text.isNotEmpty && _favoriteSubjects.length < 10) {
      setState(() {
        _favoriteSubjects.add(_subjectController.text);
        _subjectController.clear();
      });
    }
  }

  void _addTopic() {
    if (_topicController.text.isNotEmpty && _favoriteTopics.length < 10) {
      setState(() {
        _favoriteTopics.add(_topicController.text);
        _topicController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Survey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Favorite Subjects'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Add a Subject'),
                      validator: (value) {
                        if (_favoriteSubjects.isEmpty) {
                          return 'Please add at least one favorite subject';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSubject,
                  ),
                ],
              ),
              Wrap(
                children: _favoriteSubjects.map((subject) {
                  return Chip(
                    label: Text(subject),
                    backgroundColor: Colors.primaries[
                        _favoriteSubjects.indexOf(subject) %
                            Colors.primaries.length][200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Favorite Topics'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(labelText: 'Add a Topic'),
                      validator: (value) {
                        if (_favoriteTopics.isEmpty) {
                          return 'Please add at least one favorite topic';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTopic,
                  ),
                ],
              ),
              Wrap(
                children: _favoriteTopics.map((topic) {
                  return Chip(
                    label: Text(topic),
                    backgroundColor: Colors.primaries[
                        _favoriteTopics.indexOf(topic) %
                            Colors.primaries.length][200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Area of Difficulty'),
                items: [
                  'Mathematics',
                  'Science',
                  'History',
                  'Language Arts',
                  'Other'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    areaOfDifficulty = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an area of difficulty';
                  }
                  return null;
                },
                onSaved: (value) {
                  areaOfDifficulty = value!;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Preferred Learning Style'),
                items: [
                  'Visual',
                  'Auditory',
                  'Reading/Writing',
                  'Kinesthetic',
                  'Other'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    preferredLearningStyle = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a preferred learning style';
                  }
                  return null;
                },
                onSaved: (value) {
                  preferredLearningStyle = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitSurvey,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
