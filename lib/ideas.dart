import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_learn/widgets/custom_appbar.dart';
import 'databaseutils/gemini.dart';
import 'improvement_card.dart';
import 'potential_topic_card.dart'; // Import the new PotentialTopicCard

class IdeasPage extends StatefulWidget {
  @override
  _IdeasPageState createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  Future<Map<String, dynamic>>? _ideasFuture;

  @override
  void initState() {
    super.initState();
    _ideasFuture = Gemini.getIdeas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _ideasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load ideas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final recommendations = snapshot.data!['recommendations'];
          final learningPaths = recommendations['learningPaths'];
          final areasForImprovement = recommendations['areas_for_improvement'];
          final potentialTopicsOfInterest =
              recommendations['potential_topics_of_interest'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (learningPaths != null) ...[
                    Text(
                      'Learning Paths',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        title: Text(learningPaths['title']),
                        subtitle: Text(learningPaths['briefDescription']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LearningPathDetailsPage(
                                learningPath: learningPaths['learningPath'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (areasForImprovement != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Areas for Improvement',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 10),
                    ...areasForImprovement.map<Widget>((area) {
                      return ImprovementCard(area: area);
                    }).toList(),
                  ],
                  if (potentialTopicsOfInterest != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Potential Topics of Interest',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 10),
                    ...potentialTopicsOfInterest.map<Widget>((topic) {
                      return PotentialTopicCard(topic: topic);
                    }).toList(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LearningPathDetailsPage extends StatelessWidget {
  final List<dynamic> learningPath;

  LearningPathDetailsPage({required this.learningPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: learningPath.length,
        itemBuilder: (context, index) {
          final path = learningPath[index];
          return Card(
            child: ListTile(
              title: Text(path['topicTitle']),
              subtitle: Text(path['topicBrief']),
              onTap: () {
                // Handle link navigation
              },
            ),
          );
        },
      ),
    );
  }
}
