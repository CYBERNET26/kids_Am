class StoryQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const StoryQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory StoryQuestion.fromJson(Map<String, dynamic> json) => StoryQuestion(
        id: json['id'] as String,
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String? ?? '',
      );
}

class StoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int readingTimeMinutes;
  final List<String> paragraphs;
  final List<StoryQuestion> questions;
  final String moral;

  const StoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.readingTimeMinutes,
    required this.paragraphs,
    required this.questions,
    required this.moral,
  });
}
