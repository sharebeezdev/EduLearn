import 'dart:convert';
import 'package:edu_learn/home_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:edu_learn/databaseutils/db_helper.dart';

class DataUploadPage extends StatefulWidget {
  @override
  _DataUploadPageState createState() => _DataUploadPageState();
}

class _DataUploadPageState extends State<DataUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  int _score = 0;
  String _projectName = '';
  String _grade = '';
  String _feedback = '';
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      String content = utf8.decode(file.bytes!);
      Map<String, dynamic> data = jsonDecode(content);
      await _uploadJsonData(data);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  Future<void> _uploadJsonData(Map<String, dynamic> data) async {
    final db = await DBHelper().database;
    for (var item in data['exam_scores']) {
      await db.insert('exam_scores', {
        'subject': item['subject'],
        'score': item['score'],
        'date': item['date'],
      });
    }
    for (var item in data['project_grades']) {
      await db.insert('project_grades', {
        'projectName': item['projectName'],
        'grade': item['grade'],
        'date': item['date'],
      });
    }
    for (var item in data['teacher_feedback']) {
      await db.insert('teacher_feedback', {
        'feedback': item['feedback'],
        'date': item['date'],
      });
    }
  }

  Future<void> _saveData() async {
    final db = await DBHelper().database;
    await db.insert('exam_scores', {
      'subject': _subject,
      'score': _score,
      'date': _selectedDate.toIso8601String(),
    });
    await db.insert('project_grades', {
      'projectName': _projectName,
      'grade': _grade,
      'date': _selectedDate.toIso8601String(),
    });
    await db.insert('teacher_feedback', {
      'feedback': _feedback,
      'date': _selectedDate.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Upload'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject'),
                onChanged: (value) {
                  _subject = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Score'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _score = int.tryParse(value) ?? 0;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Project Name'),
                onChanged: (value) {
                  _projectName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Grade'),
                onChanged: (value) {
                  _grade = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Teacher Feedback'),
                onChanged: (value) {
                  _feedback = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data saved successfully')),
                    );
                  }
                },
                child: Text('Save Data'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Skip'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('Upload JSON File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
