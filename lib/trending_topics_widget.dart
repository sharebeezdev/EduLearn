import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrendingTopicsWidget extends StatelessWidget {
  final List<String> trendingTopics;
  final bool isLoading;
  final List<String> selectedTopics;
  final ValueChanged<String> onToggle;
  final VoidCallback onFollow;

  const TrendingTopicsWidget({
    required this.trendingTopics,
    required this.isLoading,
    required this.selectedTopics,
    required this.onToggle,
    required this.onFollow,
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
              'Trending Topics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: onFollow,
              child: const Text('Follow'),
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
                    6,
                    (index) => const Chip(label: Text('')),
                  ),
                ),
              )
            : Wrap(
                spacing: 8.0,
                children: trendingTopics
                    .map((topic) => ChoiceChip(
                          label: Text(topic),
                          selected: selectedTopics.contains(topic),
                          onSelected: (isSelected) => onToggle(topic),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}
