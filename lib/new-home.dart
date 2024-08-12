import 'package:flutter/material.dart';

class NewHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wrap the GridView in a Container with a specific height
            Container(
              height: MediaQuery.of(context).size.height *
                  0.2, // Set a specific height
              child: GridView.count(
                crossAxisCount: 3,
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildIconButton('Courses', Icons.book),
                  _buildIconButton('Quizzes', Icons.quiz),
                  _buildIconButton('Recommendations', Icons.recommend),
                  // Add more icons as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(String label, IconData iconData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB0D3FF), // Icon background color
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.all(12.0), // Reduced padding
          child: Icon(
            iconData,
            size: 32, // Reduced icon size
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 4), // Reduced spacing between icon and text
        Flexible(
          // Wrap Text in Flexible
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12, // Slightly reduced font size
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis, // Handle overflow in text
            textAlign: TextAlign.center, // Center the text
          ),
        ),
      ],
    );
  }
}
