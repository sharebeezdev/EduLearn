class ExamData {
  final int id;
  final String subject; // Retaining 'subject' as in the schema
  final String examDate; // Use 'examDate' to match existing schema
  final int marks; // Removing 'examName' and 'totalMarks' for schema consistency

  ExamData({
    required this.id,
    required this.subject,
    required this.examDate,
    required this.marks,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      id: json['id'],
      subject: json['subject'],
      examDate: json['examDate'],
      marks: json['marks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'examDate': examDate,
      'marks': marks,
    };
  }
}
