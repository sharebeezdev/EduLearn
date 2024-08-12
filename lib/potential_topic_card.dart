import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PotentialTopicCard extends StatelessWidget {
  final Map<String, dynamic> topic;

  const PotentialTopicCard({Key? key, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topicTitle = topic['topic'] as String;
    final reason = topic['reason'] as String;

    // Properly cast the list of recommended resources
    final recommendedResources = (topic['recommended_resources'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topicTitle,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              reason,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 16),
            Text(
              'Recommended Resources:',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...recommendedResources.map((resource) {
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