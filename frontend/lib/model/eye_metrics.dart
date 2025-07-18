class EyeMetrics {
  final double accuracy;           // 0~100
  final int wordsRead;
  final int durationSeconds;
  final int fixationCount;
  final double avgFixationDuration;
  final int regressionCount;
  final double cognitiveLoad;
  final double fluencyScore;

  EyeMetrics({
    required this.accuracy,
    required this.wordsRead,
    required this.durationSeconds,
    required this.fixationCount,
    required this.avgFixationDuration,
    required this.regressionCount,
    required this.cognitiveLoad,
    required this.fluencyScore,
  });
}