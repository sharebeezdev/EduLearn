import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_helper.dart';
import 'databaseutils/dbutils_sql.dart';
import 'initial_survey.dart';

class ProfileCreationPage extends StatefulWidget {
  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for capturing user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  String _gender = 'Male';
  String _educationLevel = 'High School';

  // Submit profile data
  void _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Insert profile data into the Profile table
      final db = await DBUtilsSQL().database;
      await db.insert('Profile', {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'gender': _gender,
        'email': _emailController.text,
        'school': _schoolController.text,
        'educationLevel': _educationLevel,
      });

      // Navigate to InitialSurveyScreen after saving data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InitialSurveyScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile Setup',
        isBackButtonVisible: false,
        isSubHeaderVisible: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(labelText: 'School/College'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your school/college';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _educationLevel,
                decoration: InputDecoration(labelText: 'Education Level'),
                items: ['High School', 'Undergraduate', 'Postgraduate', 'Other']
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _educationLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProfile,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
