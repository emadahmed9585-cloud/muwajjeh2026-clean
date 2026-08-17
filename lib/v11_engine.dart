import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'exam_data.dart';
import 'models.dart';

const v11MinisterialSubjects = <String>[
  'اللغة الإنجليزية',
  'الرياضيات',
  'الكيمياء',
  'الفيزياء',
  'الأحياء',
];

class MinisterialStyleProfile {
  const MinisterialStyleProfile({
    required this.subject,
    required this.displayName,
    required this.defaultMinutes,
    required this.timeStatus,
    required this.easy,
    required this.medium,
    required this.hard,
    required this.advanced,
    required this.styleSummary,
  });

  final String subject;
  final String displayName;
  final int defaultMinutes;
  final String timeStatus;
  final int easy;
  final int medium;
  final int hard;
  final int advanced;
  final String styleSummary;

  int get total => easy + medium + hard + advanced;
  Map<String, int> get difficultyTargets => {
        'سهل': easy,
        'متوسط': medium,
        'صعب': hard,
        'متقدم': advanced,
      };
}

const ministerial2026Profiles = <String, MinisterialStyleProfile>{
  'اللغة الإنجليزية': MinisterialStyleProfile(
    subject: 'اللغة الإنجليزية',
    displayName: 'اللغة الإنجليزية (متقدم)',
    defaultMinutes: 120,
    timeStatus: 'مدة امتحان 2026 المنشورة: ساعتان',
    easy: 8,
    medium: 26,
    hard: 12,
    advanced: 4,
    styleSummary: 'سياق طويل نسبيًا، بدائل متقاربة، استنتاج، paraphrasing، vocabulary in context، وقواعد داخل سياق.',
  ),
  'الرياضيات': MinisterialStyleProfile(
    subject: 'الرياضيات',
    displayName: 'الرياضيات',
    defaultMinutes: 180,
    timeStatus: 'مدة امتحان 2026 المنشورة: 3 ساعات',
    easy: 15,
    medium: 25,
    hard: 7,
    advanced: 3,
    styleSummary: 'نحو 80% سهل–متوسط كهدف تدريبي موافق لما أعلن عن امتحان 2026، مع مسائل تمييزية متعددة الخطوات.',
  ),
  'الكيمياء': MinisterialStyleProfile(
    subject: 'الكيمياء',
    displayName: 'الكيمياء',
    defaultMinutes: 150,
    timeStatus: 'زمن تدريبي افتراضي قابل للتعديل',
    easy: 12,
    medium: 26,
    hard: 9,
    advanced: 3,
    styleSummary: 'قريب من أمثلة وأنشطة الكتاب، مع حسابات واستنتاج وعلاقات بين المتغيرات ومشتتات تمثل أخطاء شائعة.',
  ),
  'الفيزياء': MinisterialStyleProfile(
    subject: 'الفيزياء',
    displayName: 'الفيزياء',
    defaultMinutes: 150,
    timeStatus: 'مدة امتحان 2026 المنشورة: ساعتان ونصف',
    easy: 14,
    medium: 24,
    hard: 9,
    advanced: 3,
    styleSummary: 'مفهوم ثم تطبيق؛ مسائل قصيرة ودقيقة، تفسير ظواهر، قوانين، ووحدات ومشتتات أخطاء الإشارة/القانون.',
  ),
  'الأحياء': MinisterialStyleProfile(
    subject: 'الأحياء',
    displayName: 'العلوم الحياتية',
    defaultMinutes: 150,
    timeStatus: 'زمن تدريبي افتراضي قابل للتعديل',
    easy: 14,
    medium: 25,
    hard: 8,
    advanced: 3,
    styleSummary: 'ربط العمليات الحيوية، تحليل مواقف ونتائج، وراثة وتسلسل سببي بدل الاعتماد على تعريفات الحفظ فقط.',
  ),
};

class MinisterialMockBuild {
  const MinisterialMockBuild({required this.exam, required this.profile});
  final ExamDefinition exam;
  final MinisterialStyleProfile profile;
}

class MinisterialMockEngine {
  static const int questionCount = 50;
  static const int bookGroundedCount = 40;
  static const int transferCount = 10;

  static bool _isValidFourChoiceMcq(ExamQuestion q) =>
      q.options.length == 4 &&
      q.correctIndex >= 0 &&
      q.correctIndex < 4 &&
      q.text.trim().isNotEmpty;

  static List<ExamQuestion> subjectPool(String subject) => allBankQuestions
      .where((q) =>
          q.subject == subject &&
          q.verifiedFromOfficialCurriculum &&
          _isValidFourChoiceMcq(q))
      .toList();

  static List<ExamQuestion> transferPool(String subject) => subjectPool(subject)
      .where((q) => q.isTransferQuestion)
      .toList();

  static List<ExamQuestion> bookPool(String subject) => subjectPool(subject)
      .where((q) => q.isOfficialBookQuestion && !q.isTransferQuestion)
      .toList();

  static Map<String, int> poolStats(String subject) => {
        'book': bookPool(subject).length,
        'transfer': transferPool(subject).length,
        'total': subjectPool(subject).length,
      };

  static MinisterialMockBuild build({
    required String subject,
    int? durationMinutes,
    math.Random? random,
  }) {
    final profile = ministerial2026Profiles[subject]!;
    final rng = random ?? math.Random();
    final book = List<ExamQuestion>.from(bookPool(subject))..shuffle(rng);
    final transfer = List<ExamQuestion>.from(transferPool(subject))..shuffle(rng);

    if (book.length < bookGroundedCount || transfer.length < transferCount) {
      throw StateError(
        'بنك $subject غير مكتمل لمحاكاة 50 سؤالًا: '
        '${book.length} من الكتاب، ${transfer.length} نقل وفهم.',
      );
    }

    final selectedTransfer = transfer.take(transferCount).toList();
    final selected = <ExamQuestion>[...selectedTransfer];

    final currentDifficulty = <String, int>{};
    for (final q in selectedTransfer) {
      currentDifficulty[q.difficulty] = (currentDifficulty[q.difficulty] ?? 0) + 1;
    }

    final remainingBook = List<ExamQuestion>.from(book);
    for (final entry in profile.difficultyTargets.entries) {
      final need = math.max(0, entry.value - (currentDifficulty[entry.key] ?? 0));
      final matches = remainingBook.where((q) => q.difficulty == entry.key).toList()..shuffle(rng);
      final take = math.min(need, matches.length);
      final chosen = matches.take(take).toList();
      selected.addAll(chosen);
      remainingBook.removeWhere((q) => chosen.any((c) => c.id == q.id));
    }

    // Fill any deficit while keeping exactly 40 book-grounded questions.
    final neededBookTotal = bookGroundedCount - (selected.length - transferCount);
    if (neededBookTotal > 0) {
      remainingBook.shuffle(rng);
      selected.addAll(remainingBook.take(neededBookTotal));
    }

    // Safety normalization if difficulty matching ever over-selected.
    final transferSelected = selected.where((q) => q.isTransferQuestion).toList();
    final bookSelected = selected.where((q) => !q.isTransferQuestion).take(bookGroundedCount).toList();
    final normalized = <ExamQuestion>[...bookSelected, ...transferSelected.take(transferCount)]..shuffle(rng);

    if (normalized.length != questionCount ||
        normalized.any((q) => !_isValidFourChoiceMcq(q))) {
      throw StateError(
        'تعذر بناء محاكاة MCQ مكتملة لـ $subject: يجب أن تتكون من 50 سؤالًا، '
        'وكل سؤال أربعة بدائل وإجابة صحيحة واحدة.',
      );
    }

    final exam = ExamDefinition(
      title: 'محاكاة وزارية 2026 – ${profile.displayName}',
      subtitle: '50 سؤال اختيار من متعدد: 40 من محتوى الكتاب الرسمي + 10 نقل وفهم في سياقات جديدة.',
      subject: subject,
      icon: _iconForSubject(subject),
      questions: normalized.take(questionCount).toList(),
      unit: 'المنهاج الكامل',
      difficulty: 'تدرج 2026',
      durationMinutes: durationMinutes ?? profile.defaultMinutes,
      examType: 'ministerial_2026',
    );
    return MinisterialMockBuild(exam: exam, profile: profile);
  }

  static IconData _iconForSubject(String subject) {
    switch (subject) {
      case 'اللغة الإنجليزية': return Icons.translate;
      case 'الرياضيات': return Icons.calculate;
      case 'الكيمياء': return Icons.science;
      case 'الفيزياء': return Icons.bolt;
      case 'الأحياء': return Icons.biotech;
      default: return Icons.assignment_outlined;
    }
  }
}
