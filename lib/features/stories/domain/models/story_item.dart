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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'emoji': emoji,
        'readingTimeMinutes': readingTimeMinutes,
        'paragraphs': paragraphs,
        'questions': questions.map((q) => q.toJson()).toList(),
        'moral': moral,
      };

  factory StoryItem.fromJson(Map<String, dynamic> json) => StoryItem(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '📖',
        readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 3,
        paragraphs: List<String>.from(json['paragraphs'] as List),
        questions: (json['questions'] as List? ?? [])
            .map((q) => StoryQuestion.fromJson(Map<String, dynamic>.from(q as Map)))
            .toList(),
        moral: json['moral'] as String? ?? '',
      );
}
