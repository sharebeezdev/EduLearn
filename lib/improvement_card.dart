import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImprovementCard extends StatelessWidget {
  final Map<String, dynamic> area;

  const ImprovementCard({Key? key, required this.area}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topic = area['topic'] as String;
    final currentPerformance = area['current_performance'] as String;

    // Properly cast the list of recommended actions and resource suggestions
    final recommendedActions = (area['recommended_actions'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
    final resourceSuggestions = (area['resource_suggestions'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Determine the color based on the current performance
    Color performanceColor;
    String performanceDescription;

    switch (currentPerformance.toLowerCase()) {
      case 'below average':
        performanceColor = Colors.redAccent;
        performanceDescription = 'Needs Significant Improvement';
        break;
      case 'average':
        performanceColor = Colors.amber;
        performanceDescription = 'Satisfactory Performance';
        break;
      case 'above average':
        performanceColor = Colors.green;
        performanceDescription = 'Good Performance';
        break;
      default:
        performanceColor = Colors.grey;
        performanceDescription = 'Unknown Performance';
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: performanceColor.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: performanceColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Performance: $currentPerformance ($performanceDescription)',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: performanceColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Recommended Actions:',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...recommendedActions.map((action) => ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(action),
                )),
            SizedBox(height: 16),
            Text(
              'Resource Suggestions:',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...resourceSuggestions.map((resource) {
              final resourceName = resource['resource_name'] as String;
              final resourceLink = resource['resource_link'] as String;
              final resourceType = resource['type'] as String;
              return ListTile(
                leading: Icon(Icons.bookmark),
                title: Text(resourceName),
                subtitle: Text('Type: $resourceType'),
                trailing: IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () => _launchURL(resourceLink),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
