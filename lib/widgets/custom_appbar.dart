import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool
      isBackButtonVisible; // Optional parameter to control back button visibility

  CustomAppBar({
    required this.title,
    this.isBackButtonVisible = true, // Default to true if not provided
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitleWithSubtitle(title),
      backgroundColor: Colors.white, // Light background color
      elevation: 4.0, // Add elevation for a better look
      leading: isBackButtonVisible
          ? IconButton(
              icon: _buildGradientBackButton(),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(80); // Increased height to accommodate subtitle

  Widget _buildTitleWithSubtitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientText(title),
        Text(
          'Powered by Gemini AI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.grey[600], // Lighter color for the subtitle
          ),
        ),
      ],
    );
  }

  Widget _buildGradientText(String text) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Colors.red,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 34, // Increased font size
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple
              ],
              tileMode: TileMode.mirror,
            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
        ),
      ),
    );
  }

  Widget _buildGradientBackButton() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Colors.red,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: const Icon(
        Icons.arrow_back,
        size: 30,
        color: Colors.white, // Icon color
      ),
    );
  }
}
