class QuizQuestion {
  final int questionId;
  final int quizId;
  final int questionNumber;
  final String questionText;
  final List<String> choices;
  final String correctChoice;
  final String reason;
  final String links;

  QuizQuestion({
    required this.questionId,
    required this.quizId,
    required this.questionNumber,
    required this.questionText,
    required this.choices,
    required this.correctChoice,
    required this.reason,
    required this.links,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    // Extract the choices string
    String choicesString = map['choices'] as String;
    print('choicies string si ' + choicesString);
    // Use a regular expression to split the choices correctly
    // This regex assumes that choices are separated by commas and enclosed in double quotes
    final RegExp choiceRegex = RegExp(r'"(.*?)"');
    Iterable<Match> matches = choiceRegex.allMatches(choicesString);

    // Extract choices from the matches
    List<String> parsedChoices =
        matches.map((match) => match.group(1)!).toList();
    print('parsedChoices string si ' + parsedChoices.toString());
    return QuizQuestion(
      questionId: map['questionId'],
      quizId: map['quizId'],
      questionNumber: map['questionNumber'],
      questionText: map['questionText'],
      choices: parsedChoices,
      correctChoice: map['correctChoice'],
      reason: map['reason'],
      links: map['links'],
    );
  }
}
