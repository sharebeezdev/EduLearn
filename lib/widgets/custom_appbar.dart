import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonVisible;

  CustomAppBar({
    required this.title,
    this.isBackButtonVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: _buildTitleWithSubtitle(title),
      ),
      backgroundColor: Colors.white,
      elevation: 10.0,
      leading: isBackButtonVisible
          ? IconButton(
              icon: _buildGradientBackButton(),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      titleSpacing: 0, // Ensure title does not have default padding
      toolbarHeight: preferredSize.height, // Match the preferred height
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);

  Widget _buildTitleWithSubtitle(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGradientText(title),
              SizedBox(height: 4), // Add spacing between title and subtitle
              Text(
                'Powered by Gemini AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
            Colors.purple,
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: AutoSizeText(
        text,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ],
              tileMode: TileMode.mirror,
            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
        ),
        maxLines: 1,
        minFontSize: 12, // Set a minimum font size to ensure readability
        overflow: TextOverflow.ellipsis,
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
            Colors.purple,
          ],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: const Icon(
        Icons.arrow_back,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}
