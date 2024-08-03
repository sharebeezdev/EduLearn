import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubjectsWidget extends StatelessWidget {
  final List<String> savedSubjects;
  final bool isLoading;
  final List<String> selectedSubjects;
  final ValueChanged<String> onToggle;
  final VoidCallback onUnfollow;

  const SubjectsWidget({
    required this.savedSubjects,
    required this.isLoading,
    required this.selectedSubjects,
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
              'Subject',
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
                children: savedSubjects
                    .map((subject) => FilterChip(
                          label: Text(subject),
                          selected: selectedSubjects.contains(subject),
                          onSelected: (selected) => onToggle(subject),
                        ))
                    .toList(),
              ),
      ],
    );
  }
}
