class Quiz {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  final String topicName;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.topicName,
  });

  @override
  String toString() {
    return 'Quiz{id: $id, title: $title, description: $description, imageUrl: $imageUrl, type: $type, topicName: $topicName}';
  }
}
