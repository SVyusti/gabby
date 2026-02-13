enum QuestionType { text, dateRange, budget, preferences, miscellaneous }

class Question {
  final String text;
  final QuestionType type;
  final List<String>? suggestions;
  String? answer;

  Question({
    required this.text,
    required this.type,
    this.suggestions,
    this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.toString(),
      'suggestions': suggestions,
      'answer': answer,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == json['type'] || e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.text,
      ),
      suggestions: (json['suggestions'] as List?)?.map((e) => e.toString()).toList(),
      answer: json['answer'],
    );
  }
}
