import 'package:flutter/material.dart';

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.branch,
    required this.gradeYear,
    required this.subjects,
    required this.dailyGoalMinutes,
  });

  final String name;
  final String branch;
  final String gradeYear;
  final List<String> subjects;
  final int dailyGoalMinutes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'branch': branch,
        'gradeYear': gradeYear,
        'subjects': subjects,
        'dailyGoalMinutes': dailyGoalMinutes,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'] as String? ?? '',
      branch: json['branch'] as String? ?? 'العلمي',
      gradeYear: json['gradeYear'] as String? ?? 'الثاني عشر',
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 120,
    );
  }
}

class ExamResultRecord {
  const ExamResultRecord({
    required this.examTitle,
    required this.subject,
    required this.score,
    required this.total,
    required this.completedAt,
    this.examType = 'practice',
  });

  final String examTitle;
  final String subject;
  final int score;
  final int total;
  final DateTime completedAt;
  final String examType;

  int get percentage => total == 0 ? 0 : ((score / total) * 100).round();

  Map<String, dynamic> toJson() => {
        'examTitle': examTitle,
        'subject': subject,
        'score': score,
        'total': total,
        'completedAt': completedAt.toIso8601String(),
        'examType': examType,
      };

  factory ExamResultRecord.fromJson(Map<String, dynamic> json) {
    return ExamResultRecord(
      examTitle: json['examTitle'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      examType: json['examType'] as String? ?? 'practice',
    );
  }
}

class FocusSessionRecord {
  const FocusSessionRecord({
    required this.minutes,
    required this.completedAt,
  });

  final int minutes;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'minutes': minutes,
        'completedAt': completedAt.toIso8601String(),
      };

  factory FocusSessionRecord.fromJson(Map<String, dynamic> json) {
    return FocusSessionRecord(
      minutes: json['minutes'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
class MistakeRecord {
  const MistakeRecord({
    required this.questionId,
    required this.examTitle,
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.difficulty,
    required this.questionText,
    required this.selectedOption,
    required this.correctOption,
    required this.explanation,
    required this.completedAt,
    this.skill = 'فهم',
    this.sourceLabel = 'بنك تجريبي',
    this.curriculumYear = '',
    this.verifiedFromOfficialCurriculum = false,
    this.errorType = 'غير مصنف',
  });

  final String questionId;
  final String examTitle;
  final String subject;
  final String unit;
  final String lesson;
  final String difficulty;
  final String questionText;
  final String selectedOption;
  final String correctOption;
  final String explanation;
  final DateTime completedAt;
  final String skill;
  final String sourceLabel;
  final String curriculumYear;
  final bool verifiedFromOfficialCurriculum;
  final String errorType;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'examTitle': examTitle,
        'subject': subject,
        'unit': unit,
        'lesson': lesson,
        'difficulty': difficulty,
        'questionText': questionText,
        'selectedOption': selectedOption,
        'correctOption': correctOption,
        'explanation': explanation,
        'completedAt': completedAt.toIso8601String(),
        'skill': skill,
        'sourceLabel': sourceLabel,
        'curriculumYear': curriculumYear,
        'verifiedFromOfficialCurriculum': verifiedFromOfficialCurriculum,
        'errorType': errorType,
      };

  factory MistakeRecord.fromJson(Map<String, dynamic> json) {
    return MistakeRecord(
      questionId: json['questionId'] as String? ?? '',
      examTitle: json['examTitle'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      unit: json['unit'] as String? ?? 'عام',
      lesson: json['lesson'] as String? ?? 'عام',
      difficulty: json['difficulty'] as String? ?? 'متوسط',
      questionText: json['questionText'] as String? ?? '',
      selectedOption: json['selectedOption'] as String? ?? '',
      correctOption: json['correctOption'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      skill: json['skill'] as String? ?? 'فهم',
      sourceLabel: json['sourceLabel'] as String? ?? 'بنك تجريبي',
      curriculumYear: json['curriculumYear'] as String? ?? '',
      verifiedFromOfficialCurriculum:
          json['verifiedFromOfficialCurriculum'] as bool? ?? false,
      errorType: json['errorType'] as String? ?? 'غير مصنف',
    );
  }
}
String classifyErrorType(String skill) {
  final value = skill.trim().toLowerCase();
  if (value.contains('حساب') || value.contains('اشتقاق') || value.contains('معادلات') || value.contains('تمثيل جبري')) {
    return 'خطأ حسابي/إجرائي';
  }
  if (value.contains('قواعد') || value.contains('مفردات') || value.contains('كتابة') || value.contains('استخدام اللغة') || value.contains('وظائف لغوية')) {
    return 'خطأ لغوي';
  }
  if (value.contains('استنتاج') || value.contains('تحليل') || value.contains('تمييز') || value.contains('مقارنة') || value.contains('تحويل')) {
    return 'خطأ استدلالي';
  }
  if (value.contains('تطبيق') || value.contains('تقنيات') || value.contains('تسلسل') || value.contains('وظائف')) {
    return 'خطأ تطبيقي';
  }
  return 'خطأ مفاهيمي';
}

class SubjectPerformance {
  const SubjectPerformance({
    required this.subject,
    required this.average,
    required this.attempts,
  });

  final String subject;
  final double average;
  final int attempts;
}

class StudyTask {
  const StudyTask({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.minutes,
    required this.priority,
    required this.reason,
  });

  final String id;
  final String subject;
  final String title;
  final String description;
  final int minutes;
  final int priority;
  final String reason;
}

class WeeklyPlanDay {
  const WeeklyPlanDay({
    required this.date,
    required this.tasks,
  });

  final DateTime date;
  final List<StudyTask> tasks;
}

class StudyRecommendation {
  const StudyRecommendation({
    required this.title,
    required this.message,
    required this.subject,
    required this.actionLabel,
  });

  final String title;
  final String message;
  final String subject;
  final String actionLabel;
}

class StudyPlan {
  const StudyPlan({
    required this.subject,
    required this.problemType,
    required this.diagnosis,
    required this.firstAction,
    required this.details,
    required this.steps,
  });

  final String subject;
  final String problemType;
  final String diagnosis;
  final String firstAction;
  final String details;
  final List<String> steps;
}

class ExamDefinition {
  const ExamDefinition({
    required this.title,
    required this.subtitle,
    required this.subject,
    required this.icon,
    required this.questions,
    this.unit = 'عام',
    this.difficulty = 'متوسط',
    this.durationMinutes = 15,
    this.examType = 'practice',
  });

  final String title;
  final String subtitle;
  final String subject;
  final IconData icon;
  final List<ExamQuestion> questions;
  final String unit;
  final String difficulty;
  final int durationMinutes;
  final String examType;
}

class ExamQuestion {
  const ExamQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.id = '',
    this.subject = '',
    this.unit = 'عام',
    this.lesson = 'عام',
    this.difficulty = 'متوسط',
    this.skill = 'فهم',
    this.sourceLabel = 'بنك تجريبي',
    this.curriculumYear = '',
    this.verifiedFromOfficialCurriculum = false,
    this.questionOrigin = 'legacy',
    this.sourceReference = '',
    this.tawjihiStyleYear = '',
    this.distractorDesign = '',
  });

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String subject;
  final String unit;
  final String lesson;
  final String difficulty;
  final String skill;
  final String sourceLabel;
  final String curriculumYear;
  final bool verifiedFromOfficialCurriculum;

  /// V11 source taxonomy:
  /// officialBook = question grounded directly in the official textbook/workbook.
  /// transfer = new context/data that measures the same official curriculum skill.
  /// legacy = older bank item retained for backward compatibility.
  final String questionOrigin;
  final String sourceReference;
  final String tawjihiStyleYear;
  final String distractorDesign;

  bool get isTransferQuestion => questionOrigin == 'transfer';
  bool get isOfficialBookQuestion =>
      questionOrigin == 'officialBook' ||
      (questionOrigin == 'legacy' && verifiedFromOfficialCurriculum);
}

class CurriculumSource {
  const CurriculumSource({
    required this.id,
    required this.subject,
    required this.title,
    required this.semester,
    required this.academicYear,
    required this.publisher,
    required this.status,
    this.note = '',
  });

  final String id;
  final String subject;
  final String title;
  final String semester;
  final String academicYear;
  final String publisher;
  final String status;
  final String note;
}

class CurriculumUnit {
  const CurriculumUnit({
    required this.subject,
    required this.number,
    required this.title,
    required this.lessons,
    required this.sourceId,
  });

  final String subject;
  final int number;
  final String title;
  final List<String> lessons;
  final String sourceId;
}

class QuestionAttemptRecord {
  const QuestionAttemptRecord({
    required this.questionId,
    required this.examTitle,
    required this.examType,
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.difficulty,
    required this.isCorrect,
    required this.selectedIndex,
    required this.correctIndex,
    required this.responseSeconds,
    required this.completedAt,
    this.sourceLabel = 'بنك تجريبي',
    this.curriculumYear = '',
    this.verifiedFromOfficialCurriculum = false,
  });

  final String questionId;
  final String examTitle;
  final String examType;
  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final String difficulty;
  final bool isCorrect;
  final int? selectedIndex;
  final int correctIndex;
  final int responseSeconds;
  final DateTime completedAt;
  final String sourceLabel;
  final String curriculumYear;
  final bool verifiedFromOfficialCurriculum;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'examTitle': examTitle,
        'examType': examType,
        'subject': subject,
        'unit': unit,
        'lesson': lesson,
        'skill': skill,
        'difficulty': difficulty,
        'isCorrect': isCorrect,
        'selectedIndex': selectedIndex,
        'correctIndex': correctIndex,
        'responseSeconds': responseSeconds,
        'completedAt': completedAt.toIso8601String(),
        'sourceLabel': sourceLabel,
        'curriculumYear': curriculumYear,
        'verifiedFromOfficialCurriculum': verifiedFromOfficialCurriculum,
      };

  factory QuestionAttemptRecord.fromJson(Map<String, dynamic> json) {
    return QuestionAttemptRecord(
      questionId: json['questionId'] as String? ?? '',
      examTitle: json['examTitle'] as String? ?? '',
      examType: json['examType'] as String? ?? 'practice',
      subject: json['subject'] as String? ?? '',
      unit: json['unit'] as String? ?? 'عام',
      lesson: json['lesson'] as String? ?? 'عام',
      skill: json['skill'] as String? ?? 'فهم',
      difficulty: json['difficulty'] as String? ?? 'متوسط',
      isCorrect: json['isCorrect'] as bool? ?? false,
      selectedIndex: json['selectedIndex'] as int?,
      correctIndex: json['correctIndex'] as int? ?? 0,
      responseSeconds: json['responseSeconds'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      sourceLabel: json['sourceLabel'] as String? ?? 'بنك تجريبي',
      curriculumYear: json['curriculumYear'] as String? ?? '',
      verifiedFromOfficialCurriculum:
          json['verifiedFromOfficialCurriculum'] as bool? ?? false,
    );
  }
}

class MasteryMetric {
  const MasteryMetric({
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.score,
    required this.confidence,
    required this.attempts,
    required this.correct,
    required this.averageResponseSeconds,
    required this.lastAttemptAt,
  });

  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final double score;
  final double confidence;
  final int attempts;
  final int correct;
  final double averageResponseSeconds;
  final DateTime? lastAttemptAt;

  String get status {
    if (attempts == 0) return 'غير مقاس';
    if (score < 45) return 'يحتاج تأسيس';
    if (score < 65) return 'قيد التطور';
    if (score < 80) return 'جيد';
    if (score < 92) return 'متقن';
    return 'متقن جدًا';
  }
}

class MasteryReviewTarget {
  const MasteryReviewTarget({
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.score,
    required this.reason,
  });

  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final double score;
  final String reason;
}


// -----------------------------------------------------------------------------
// V9 — Learning Path
// -----------------------------------------------------------------------------

class LearningPathRecord {
  const LearningPathRecord({
    required this.id,
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.createdAt,
    required this.updatedAt,
    required this.baselineMastery,
    this.conceptReviewed = false,
    this.archived = false,
  });

  final String id;
  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double baselineMastery;
  final bool conceptReviewed;
  final bool archived;

  LearningPathRecord copyWith({
    DateTime? updatedAt,
    bool? conceptReviewed,
    bool? archived,
  }) {
    return LearningPathRecord(
      id: id,
      subject: subject,
      unit: unit,
      lesson: lesson,
      skill: skill,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      baselineMastery: baselineMastery,
      conceptReviewed: conceptReviewed ?? this.conceptReviewed,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'unit': unit,
        'lesson': lesson,
        'skill': skill,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'baselineMastery': baselineMastery,
        'conceptReviewed': conceptReviewed,
        'archived': archived,
      };

  factory LearningPathRecord.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return LearningPathRecord(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      lesson: json['lesson'] as String? ?? '',
      skill: json['skill'] as String? ?? '',
      createdAt: created,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? created,
      baselineMastery: (json['baselineMastery'] as num?)?.toDouble() ?? 55,
      conceptReviewed: json['conceptReviewed'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
    );
  }
}

class LearningPathSnapshot {
  const LearningPathSnapshot({
    required this.record,
    required this.currentMastery,
    required this.foundationAttempts,
    required this.foundationCorrect,
    required this.checkpointAttempts,
    required this.checkpointCorrect,
    required this.stage,
    required this.isCompleted,
    required this.needsRemediation,
  });

  final LearningPathRecord record;
  final MasteryMetric currentMastery;
  final int foundationAttempts;
  final int foundationCorrect;
  final int checkpointAttempts;
  final int checkpointCorrect;
  final int stage;
  final bool isCompleted;
  final bool needsRemediation;

  int get foundationPercentage => foundationAttempts == 0
      ? 0
      : ((foundationCorrect / foundationAttempts) * 100).round();

  int get checkpointPercentage => checkpointAttempts == 0
      ? 0
      : ((checkpointCorrect / checkpointAttempts) * 100).round();

  String get stageLabel {
    if (isCompleted) return 'مكتمل';
    if (!record.conceptReviewed) return 'فهم المفهوم';
    if (foundationAttempts < 5 || foundationPercentage < 60) return 'تدريب تأسيسي';
    if (needsRemediation) return 'علاج وإعادة تحقق';
    return 'اختبار تحقق';
  }
}

// -----------------------------------------------------------------------------
// V12 — textbook-anchored beginner tutor
// -----------------------------------------------------------------------------

class BookPageReference {
  const BookPageReference({
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.bookTitle,
    required this.publisher,
    this.pageNumber,
    this.pageEnd,
    this.assetPath = '',
    this.referenceStatus = 'متحقق',
    this.note = '',
  });

  final String subject;
  final String unit;
  final String lesson;
  final String bookTitle;
  final String publisher;
  final int? pageNumber;
  final int? pageEnd;

  /// Optional licensed/local preview asset. The public release must only bundle
  /// textbook page images when redistribution permission is available.
  final String assetPath;
  final String referenceStatus;
  final String note;

  bool get hasVerifiedPage => pageNumber != null;
  bool get hasImage => assetPath.trim().isNotEmpty;

  String get pageLabel {
    if (pageNumber == null) return 'قيد التحقق';
    if (pageEnd != null && pageEnd != pageNumber) {
      return '$pageNumber–$pageEnd';
    }
    return '$pageNumber';
  }
}

class BeginnerTutorLesson {
  const BeginnerTutorLesson({
    required this.startFromZero,
    required this.simpleExample,
    required this.commonMistake,
    required this.memoryTip,
    required this.quickCheck,
  });

  final String startFromZero;
  final String simpleExample;
  final String commonMistake;
  final String memoryTip;
  final String quickCheck;
}

// -----------------------------------------------------------------------------
// V10 — Smart Tutor & mastery progress map
// -----------------------------------------------------------------------------

class TutorAdvice {
  const TutorAdvice({
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.errorType,
    required this.title,
    required this.diagnosis,
    required this.microLesson,
    required this.strategySteps,
    required this.selfCheckQuestions,
    required this.recommendedDifficulty,
    this.lastMistakeExplanation = '',
  });

  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final String errorType;
  final String title;
  final String diagnosis;
  final String microLesson;
  final List<String> strategySteps;
  final List<String> selfCheckQuestions;
  final String recommendedDifficulty;
  final String lastMistakeExplanation;
}

class MasteryTrendPoint {
  const MasteryTrendPoint({
    required this.label,
    required this.score,
    required this.attempts,
    required this.completedAt,
  });

  final String label;
  final double score;
  final int attempts;
  final DateTime completedAt;
}

class CurriculumProgressNode {
  const CurriculumProgressNode({
    required this.subject,
    required this.unit,
    required this.lesson,
    required this.skill,
    required this.score,
    required this.confidence,
    required this.attempts,
    required this.trend,
    required this.questionCount,
  });

  final String subject;
  final String unit;
  final String lesson;
  final String skill;
  final double score;
  final double confidence;
  final int attempts;
  final double trend;
  final int questionCount;

  bool get isMeasured => attempts > 0;

  String get status {
    if (!isMeasured) return 'غير مقاس';
    if (score < 45) return 'يحتاج تأسيس';
    if (score < 65) return 'قيد التطور';
    if (score < 80) return 'جيد';
    if (score < 92) return 'متقن';
    return 'متقن جدًا';
  }

  String get trendLabel {
    if (attempts < 4 || trend.abs() < 2.5) return 'ثابت/بيانات محدودة';
    return trend > 0 ? 'يتحسن' : 'يتراجع';
  }
}
