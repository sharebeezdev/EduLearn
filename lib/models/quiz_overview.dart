class QuizOverview {
  final int quizId;
  final String quizTitle;
  final String quizDescription;
  final String quizType;
  final String imageUrl;
  final String status;
  final String creationDate;

  QuizOverview({
    required this.quizId,
    required this.quizTitle,
    required this.quizDescription,
    required this.quizType,
    required this.imageUrl,
    required this.status,
    required this.creationDate,
  });

  factory QuizOverview.fromMap(Map<String, dynamic> map) {
    return QuizOverview(
      quizId: map['quizId'],
      quizTitle: map['quizTitle'],
      quizDescription: map['quizDescription'],
      quizType: map['quizType'],
      imageUrl: map['imageUrl'],
      status: map['status'],
      creationDate: map['creationDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizDescription': quizDescription,
      'quizType': quizType,
      'imageUrl': imageUrl,
      'status': status,
      'creationDate': creationDate,
    };
  }
}
