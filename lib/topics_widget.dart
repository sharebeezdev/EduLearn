import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TopicsWidget extends StatelessWidget {
  final List<String> savedTopics;
  final bool isLoading;
  final List<String> selectedTopics;
  final ValueChanged<String> onToggle;
  final VoidCallback onUnfollow;

  const TopicsWidget({
    required this.savedTopics,
    required this.isLoading,
    required this.selectedTopics,
    required this.onToggle,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Topic',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: onUnfollow,
              child: const Text('Unfollow'),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Wrap(
                  spacing: 8.0,
                  children: List.generate(
                    10,
                    (index) => const Chip(label: Text('')),
                  ),
                ),
              )
            : Wrap(
                spacing: 8.0,
                children: savedTopics.map((topic) => FilterChip(
                      label: Text(topic),
                      selected: selectedTopics.contains(topic),
                      onSelected: (selected) => onToggle(topic),
                    )).toList(),
              ),
      ],
    );
  }
}
