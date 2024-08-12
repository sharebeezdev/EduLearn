import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_helper.dart';
import 'databaseutils/db_utils.dart';
import 'databaseutils/dbutils_sql.dart';
import 'recommendation_screen.dart';
import 'widgets/custom_appbar.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
    _loadSubjects();
    _loadTopics();
  }

  Future<void> _loadSurveyData() async {
    final db = await DBUtilsSQL().database;
    final List<Map<String, dynamic>> surveyData =
        await db.query('SurveyData', limit: 1);

    if (surveyData.isNotEmpty) {
      setState(() {
        areaOfDifficulty = surveyData[0]['areaOfDifficulty'] ?? '';
        preferredLearningStyle = surveyData[0]['preferredLearningStyle'] ?? '';
      });
    }
  }

  Future<void> _loadSubjects() async {
    final db = await DBUtilsSQL().database;
    _favoriteSubjects.clear();
    final subjects = await db.query('subjects', columns: ['name']);
    setState(() {
      _favoriteSubjects.addAll(subjects.map((s) => s['name'].toString()));
    });
  }

  Future<void> _loadTopics() async {
    final db = await DBUtilsSQL().database;
    _favoriteTopics.clear(); // Clear the existing list first
    final topics = await db.query('topics', columns: ['title']);
    setState(() {
      _favoriteTopics.addAll(topics.map((t) => t['title'].toString()));
    });
  }

  void _submitSurvey() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

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

  void _deleteSubject(String subject) async {
    final db = await DBUtilsSQL().database;
    await db.delete('subjects', where: 'name = ?', whereArgs: [subject]);
    setState(() {
      _favoriteSubjects.remove(subject);
    });
  }

  void _deleteTopic(String topic) async {
    final db = await DBUtilsSQL().database;
    await db.delete('topics', where: 'title = ?', whereArgs: [topic]);
    setState(() {
      _favoriteTopics.remove(topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(title: 'Survey'),
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
                      decoration:
                          const InputDecoration(labelText: 'Add a Subject'),
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
                    onDeleted: () => _deleteSubject(subject),
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
                      decoration:
                          const InputDecoration(labelText: 'Add a Topic'),
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
                    onDeleted: () => _deleteTopic(topic),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: areaOfDifficulty.isNotEmpty ? areaOfDifficulty : null,
                decoration:
                    const InputDecoration(labelText: 'Area of Difficulty'),
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
                value: preferredLearningStyle.isNotEmpty
                    ? preferredLearningStyle
                    : null,
                decoration: const InputDecoration(
                    labelText: 'Preferred Learning Style'),
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
