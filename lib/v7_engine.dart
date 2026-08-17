import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'v6_curriculum_data.dart';

const v7BlueprintModes = <String>[
  'متوازن',
  'حسب اتساع المنهاج',
  'علاجي حسب الضعف',
];

const v7DifficultyProfiles = <String>[
  'تكيفي',
  'تأسيسي',
  'متوازن',
  'تحدي',
];

Map<String, double> unitTrainingWeights({
  required String subject,
  required String mode,
  required AppController controller,
}) {
  final units = allUnitsForSubject(subject);
  if (units.isEmpty) return const {};

  final raw = <String, double>{};
  for (final unit in units) {
    var value = 1.0;
    if (mode == 'حسب اتساع المنهاج') {
      value = math.max(1, unit.lessons.length).toDouble();
    } else if (mode == 'علاجي حسب الضعف') {
      final attempts = controller.questionAttempts
          .where((a) => a.subject == subject && a.unit == unit.title)
          .length;
      if (attempts > 0) {
        final mastery = controller.masteryForUnit(subject, unit.title);
        final weaknessBoost = ((100 - mastery.score) / 100) * 6.0;
        value = math.max(1, unit.lessons.length).toDouble() + weaknessBoost;
      } else {
        final mistakes = controller.mistakes
            .where((m) => m.subject == subject && m.unit == unit.title)
            .length;
        value = math.max(1, unit.lessons.length).toDouble() + mistakes * 1.8;
      }
    }
    raw[unit.title] = value;
  }

  final total = raw.values.fold<double>(0, (sum, v) => sum + v);
  if (total <= 0) return raw;
  return raw.map((key, value) => MapEntry(key, value / total));
}

String resolvedDifficultyProfile({
  required String requested,
  required String subject,
  required AppController controller,
}) {
  if (requested != 'تكيفي') return requested;
  final mastery = controller.masteryForSubject(subject);
  if (mastery.attempts >= 3) {
    if (mastery.score < 55) return 'تأسيسي';
    if (mastery.score < 80) return 'متوازن';
    return 'تحدي';
  }
  final average = controller.performanceForSubject(subject);
  if (average == null || average < 55) return 'تأسيسي';
  if (average < 78) return 'متوازن';
  return 'تحدي';
}

List<String> _difficultyCycle(String profile) {
  switch (profile) {
    case 'تأسيسي':
      return const ['سهل', 'سهل', 'متوسط', 'متوسط', 'صعب'];
    case 'تحدي':
      return const ['متوسط', 'صعب', 'صعب', 'متقدم', 'متقدم'];
    default:
      return const ['سهل', 'متوسط', 'متوسط', 'صعب', 'متقدم'];
  }
}

ExamDefinition buildV7AdaptiveExam({
  required AppController controller,
  required String subject,
  required int count,
  required int minutes,
  required String blueprintMode,
  required String difficultyProfile,
}) {
  final pool = allCurriculumQuestions
      .where((q) => q.subject == subject)
      .toList(growable: false);
  if (pool.isEmpty) {
    return ExamDefinition(
      title: 'اختبار تكيفي - $subject',
      subtitle: 'لا توجد أسئلة كافية لهذا المبحث حاليًا.',
      subject: subject,
      icon: _iconForSubject(subject),
      questions: const [],
      unit: 'متعدد الوحدات',
      difficulty: 'تكيفي',
      durationMinutes: minutes,
      examType: 'adaptive-v8',
    );
  }

  final actualCount = math.min(count, pool.length);
  final weights = unitTrainingWeights(
    subject: subject,
    mode: blueprintMode,
    controller: controller,
  );
  final profile = resolvedDifficultyProfile(
    requested: difficultyProfile,
    subject: subject,
    controller: controller,
  );
  final cycle = _difficultyCycle(profile);
  final random = math.Random();

  final quotas = <String, int>{};
  final remainders = <MapEntry<String, double>>[];
  var allocated = 0;
  for (final entry in weights.entries) {
    final exact = entry.value * actualCount;
    final base = exact.floor();
    quotas[entry.key] = base;
    allocated += base;
    remainders.add(MapEntry(entry.key, exact - base));
  }
  remainders.sort((a, b) => b.value.compareTo(a.value));
  var remainderIndex = 0;
  while (allocated < actualCount && remainders.isNotEmpty) {
    final key = remainders[remainderIndex % remainders.length].key;
    quotas[key] = (quotas[key] ?? 0) + 1;
    allocated++;
    remainderIndex++;
  }

  final selected = <ExamQuestion>[];
  final used = <String>{};
  var difficultyIndex = 0;

  for (final unit in quotas.keys) {
    final quota = quotas[unit] ?? 0;
    if (quota <= 0) continue;
    final unitPool = pool.where((q) => q.unit == unit).toList()..shuffle(random);
    for (var i = 0; i < quota; i++) {
      final target = cycle[difficultyIndex % cycle.length];
      difficultyIndex++;
      ExamQuestion? pick;
      for (final q in unitPool) {
        final key = q.id.isEmpty ? q.text : q.id;
        if (!used.contains(key) && q.difficulty == target) {
          pick = q;
          break;
        }
      }
      if (pick == null) {
        for (final q in unitPool) {
          final key = q.id.isEmpty ? q.text : q.id;
          if (!used.contains(key)) {
            pick = q;
            break;
          }
        }
      }
      if (pick != null) {
        selected.add(pick);
        used.add(pick.id.isEmpty ? pick.text : pick.id);
      }
    }
  }

  final fallback = pool.toList()..shuffle(random);
  for (final q in fallback) {
    if (selected.length >= actualCount) break;
    final key = q.id.isEmpty ? q.text : q.id;
    if (used.add(key)) selected.add(q);
  }
  selected.shuffle(random);

  return ExamDefinition(
    title: 'اختبار تكيفي V8 - $subject',
    subtitle: 'توزيع $blueprintMode • صعوبة $profile • يستخدم Mastery Score عند توافر بيانات كافية.',
    subject: subject,
    icon: _iconForSubject(subject),
    questions: selected,
    unit: 'متعدد الوحدات',
    difficulty: profile,
    durationMinutes: minutes,
    examType: 'adaptive-v8',
  );
}

IconData _iconForSubject(String subject) {
  switch (subject) {
    case 'الكيمياء':
      return Icons.science_outlined;
    case 'الفيزياء':
      return Icons.bolt_outlined;
    case 'الرياضيات':
      return Icons.calculate_outlined;
    case 'الأحياء':
      return Icons.biotech_outlined;
    case 'اللغة الإنجليزية':
      return Icons.translate_outlined;
    default:
      return Icons.quiz_outlined;
  }
}
