import 'dart:math' as math;

import 'app_controller.dart';
import 'v14_schedule_models.dart';

class WeeklyScheduleEngine {
  const WeeklyScheduleEngine._();

  static WeeklyPlanResult generate({
    required AppController controller,
    required WeeklyPlannerSettings settings,
  }) {
    final studyTargets = settings.subjects.where((s) => s.enabled && s.sessionsPerWeek > 0).toList();
    final requested = studyTargets.fold<int>(0, (sum, item) => sum + item.sessionsPerWeek);

    final blocks = <WeeklyPlanBlock>[
      for (final activity in settings.activities)
        WeeklyPlanBlock(
          dayIndex: activity.dayIndex,
          startMinute: activity.startMinute,
          endMinute: activity.endMinute,
          title: activity.title,
          kind: PlannerBlockKind.activity,
        ),
    ];

    final remaining = <String, int>{
      for (final target in studyTargets) target.subject: target.sessionsPerWeek,
    };
    final targetBySubject = {for (final target in studyTargets) target.subject: target};
    final placedByDay = <int, int>{for (final day in plannerDays) day.index: 0};
    final placedSubjectDays = <String, Set<int>>{
      for (final target in studyTargets) target.subject: <int>{},
    };

    var guard = 0;
    while (remaining.values.any((value) => value > 0) && guard < 500) {
      guard++;
      final subjects = remaining.entries.where((e) => e.value > 0).map((e) => e.key).toList();
      subjects.sort((a, b) {
        final aScore = _subjectPriorityScore(controller, settings, targetBySubject[a]!, remaining[a]!);
        final bScore = _subjectPriorityScore(controller, settings, targetBySubject[b]!, remaining[b]!);
        return bScore.compareTo(aScore);
      });

      var placedSomething = false;
      for (final subject in subjects) {
        final target = targetBySubject[subject]!;
        final dayChoices = settings.availableDays.toList();
        dayChoices.sort((a, b) {
          final aPenalty = _dayPenalty(
            dayIndex: a,
            subject: subject,
            placedByDay: placedByDay,
            subjectDays: placedSubjectDays[subject]!,
          );
          final bPenalty = _dayPenalty(
            dayIndex: b,
            subject: subject,
            placedByDay: placedByDay,
            subjectDays: placedSubjectDays[subject]!,
          );
          return aPenalty.compareTo(bPenalty);
        });

        for (final dayIndex in dayChoices) {
          if ((placedByDay[dayIndex] ?? 0) >= settings.maxSessionsPerDay) continue;
          final slot = _findFreeSlot(
            dayIndex: dayIndex,
            settings: settings,
            existing: blocks,
          );
          if (slot == null) continue;

          final weaknessText = _priorityReason(controller, settings, target);
          blocks.add(
            WeeklyPlanBlock(
              dayIndex: dayIndex,
              startMinute: slot.$1,
              endMinute: slot.$2,
              title: 'دراسة ${target.subject}',
              subject: target.subject,
              kind: PlannerBlockKind.study,
              reason: weaknessText,
            ),
          );
          remaining[subject] = math.max(0, (remaining[subject] ?? 1) - 1);
          placedByDay[dayIndex] = (placedByDay[dayIndex] ?? 0) + 1;
          placedSubjectDays[subject]!.add(dayIndex);
          placedSomething = true;
          break;
        }

        if (placedSomething) break;
      }

      if (!placedSomething) break;
    }

    blocks.sort((a, b) {
      final dayOrder = a.dayIndex.compareTo(b.dayIndex);
      return dayOrder != 0 ? dayOrder : a.startMinute.compareTo(b.startMinute);
    });

    final placed = blocks.where((b) => b.kind == PlannerBlockKind.study).length;
    final warnings = <String>[];
    if (placed < requested) {
      warnings.add(
        'تم توزيع $placed من أصل $requested جلسة فقط. وسّع وقت الدراسة، أضف يومًا متاحًا، أو قلّل عدد الجلسات المطلوبة.',
      );
    }
    for (final entry in remaining.entries.where((e) => e.value > 0)) {
      warnings.add('بقيت ${entry.value} جلسة غير موزعة لمادة ${entry.key}.');
    }

    return WeeklyPlanResult(
      settings: settings,
      blocks: blocks,
      quote: _motivationalQuote(settings.studentName),
      requestedStudySessions: requested,
      placedStudySessions: placed,
      warnings: warnings,
    );
  }

  static double _subjectPriorityScore(
    AppController controller,
    WeeklyPlannerSettings settings,
    WeeklySubjectTarget target,
    int remaining,
  ) {
    final userPriority = target.priority * 2.0;
    var weaknessBoost = 0.0;
    if (settings.useMuwajjehPriority) {
      final mastery = controller.masteryForSubject(target.subject);
      if (mastery.attempts > 0) {
        weaknessBoost = (100 - mastery.score) / 22.0;
      } else {
        final performance = controller.performanceForSubject(target.subject);
        weaknessBoost = performance == null ? 1.4 : (100 - performance) / 25.0;
      }
      weaknessBoost += math.min(controller.mistakeCountForSubject(target.subject), 6) * 0.18;
    }
    return userPriority + weaknessBoost + (remaining * 0.22);
  }

  static double _dayPenalty({
    required int dayIndex,
    required String subject,
    required Map<int, int> placedByDay,
    required Set<int> subjectDays,
  }) {
    var penalty = (placedByDay[dayIndex] ?? 0) * 4.0;
    if (subjectDays.contains(dayIndex)) penalty += 7.0;
    if (dayIndex == 5) penalty += 0.6; // اترك الجمعة أخف قليلًا عندما تتساوى الخيارات.
    return penalty;
  }

  static (int, int)? _findFreeSlot({
    required int dayIndex,
    required WeeklyPlannerSettings settings,
    required List<WeeklyPlanBlock> existing,
  }) {
    final duration = settings.sessionMinutes;
    final reserved = existing.where((b) => b.dayIndex == dayIndex).toList();

    for (var start = settings.studyStartMinute;
        start + duration <= settings.studyEndMinute;
        start += 10) {
      final end = start + duration;
      var conflict = false;
      for (final block in reserved) {
        final buffer = block.kind == PlannerBlockKind.study ? settings.breakMinutes : 0;
        if (_overlaps(start, end + settings.breakMinutes, block.startMinute, block.endMinute + buffer)) {
          conflict = true;
          break;
        }
      }
      if (!conflict) return (start, end);
    }
    return null;
  }

  static bool _overlaps(int aStart, int aEnd, int bStart, int bEnd) =>
      aStart < bEnd && bStart < aEnd;

  static String _priorityReason(
    AppController controller,
    WeeklyPlannerSettings settings,
    WeeklySubjectTarget target,
  ) {
    if (!settings.useMuwajjehPriority) {
      return target.priority == 3
          ? 'أولوية عالية حددها الطالب.'
          : target.priority == 2
              ? 'مادة مهمة ضمن أهداف الأسبوع.'
              : 'جلسة تثبيت ومراجعة منتظمة.';
    }
    final mastery = controller.masteryForSubject(target.subject);
    if (mastery.attempts > 0 && mastery.score < 70) {
      return 'رُفعت الأولوية لأن إتقانك الحالي ${mastery.score.round()}%.';
    }
    final performance = controller.performanceForSubject(target.subject);
    if (performance != null && performance < 70) {
      return 'رُفعت الأولوية لأن متوسطك الحالي ${performance.round()}%.';
    }
    if (controller.mistakeCountForSubject(target.subject) > 0) {
      return 'أولوية إضافية بسبب أخطاء مسجلة في هذا المبحث.';
    }
    return target.priority == 3 ? 'أولوية عالية حددها الطالب.' : 'جلسة متوازنة ضمن أهداف الأسبوع.';
  }

  static String _motivationalQuote(String name) {
    final cleanName = name.trim().isEmpty ? 'بطل التوجيهي' : name.trim();
    final quotes = <String>[
      'يا $cleanName، كل جلسة صغيرة تنجزها اليوم تقرّبك من النتيجة الكبيرة غدًا.',
      'يا $cleanName، لا تبحث عن يوم مثالي؛ التزم بخطوة واضحة كل يوم.',
      'يا $cleanName، الاستمرار الهادئ أقوى من الاندفاع المؤقت.',
      'يا $cleanName، خطتك ليست قيدًا؛ هي طريقك لتدرس بوضوح وراحة.',
      'يا $cleanName، أنجز ما خططت له اليوم، ودع التراكم للوراء.',
    ];
    final seed = cleanName.runes.fold<int>(0, (sum, rune) => sum + rune);
    return quotes[seed % quotes.length];
  }
}
