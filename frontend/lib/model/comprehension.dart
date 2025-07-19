class ComprehensionItem {
  final String passage;
  final List<Question> questions;

  ComprehensionItem({
    required this.passage,
    required this.questions,
  });

  factory ComprehensionItem.fromJson(Map<String, dynamic> json) {
    // 1) questions 파싱은 그대로
    var qs = (json['questions'] as List)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    // ★ 수정된 부분: 서버에서 "text" 키로 내려오는 지문을 우선 읽고,
    //    없으면 기존 "passage" 키를 사용하도록 합니다.
    final raw = (json['text'] as String?)
              ?? (json['passage'] as String?)
              ?? '';
    final text = raw.isNotEmpty
        ? raw
        : '[지문을 불러오는 데 실패했습니다]';

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
    // question/options/answerIndex 는 보통 null 이 아니니 기존 로직 유지
    return Question(
      question: json['question'] as String? ?? '[질문 오류]',
      options: List<String>.from(json['options'] as List<dynamic>? ?? []),
      answerIndex: json['answer'] as int? ?? 0,
    );
  }
}