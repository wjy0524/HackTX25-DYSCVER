class ComprehensionItem {
  final String passage;
  final List<Question> questions;

  ComprehensionItem({
    required this.passage,
    required this.questions,
  });

  factory ComprehensionItem.fromJson(Map<String, dynamic> json) {
    // 1) Parse questions (same as before)
    var qs = (json['questions'] as List)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    // 2) Prefer "text" key from server, fallback to "passage"
    final raw = (json['text'] as String?) ??
                (json['passage'] as String?) ??
                '';
    final text = raw.isNotEmpty
        ? raw
        : '[Failed to load passage]';

    return ComprehensionItem(
      passage: text,
      questions: qs,
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int answerIndex;

  Question({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String? ?? '[Question error]',
      options: List<String>.from(json['options'] as List<dynamic>? ?? []),
      answerIndex: json['answer'] as int? ?? 0,
    );
  }
}