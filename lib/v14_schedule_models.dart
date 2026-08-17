class WeeklyPlannerDay {
  const WeeklyPlannerDay(this.index, this.label, this.shortLabel);

  final int index;
  final String label;
  final String shortLabel;
}

const plannerDays = <WeeklyPlannerDay>[
  WeeklyPlannerDay(0, 'الأحد', 'أحد'),
  WeeklyPlannerDay(1, 'الاثنين', 'اثنين'),
  WeeklyPlannerDay(2, 'الثلاثاء', 'ثلاثاء'),
  WeeklyPlannerDay(3, 'الأربعاء', 'أربعاء'),
  WeeklyPlannerDay(4, 'الخميس', 'خميس'),
  WeeklyPlannerDay(5, 'الجمعة', 'جمعة'),
  WeeklyPlannerDay(6, 'السبت', 'سبت'),
];

class WeeklySubjectTarget {
  const WeeklySubjectTarget({
    required this.subject,
    required this.sessionsPerWeek,
    required this.priority,
    this.enabled = true,
  });

  final String subject;
  final int sessionsPerWeek;
  final int priority; // 1 normal, 2 important, 3 high priority
  final bool enabled;

  WeeklySubjectTarget copyWith({
    String? subject,
    int? sessionsPerWeek,
    int? priority,
    bool? enabled,
  }) {
    return WeeklySubjectTarget(
      subject: subject ?? this.subject,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'sessionsPerWeek': sessionsPerWeek,
        'priority': priority,
        'enabled': enabled,
      };

  factory WeeklySubjectTarget.fromJson(Map<String, dynamic> json) {
    return WeeklySubjectTarget(
      subject: json['subject']?.toString() ?? '',
      sessionsPerWeek: json['sessionsPerWeek'] as int? ?? 2,
      priority: json['priority'] as int? ?? 2,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class PlannerFixedActivity {
  const PlannerFixedActivity({
    required this.id,
    required this.dayIndex,
    required this.title,
    required this.startMinute,
    required this.endMinute,
  });

  final String id;
  final int dayIndex;
  final String title;
  final int startMinute;
  final int endMinute;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayIndex': dayIndex,
        'title': title,
        'startMinute': startMinute,
        'endMinute': endMinute,
      };

  factory PlannerFixedActivity.fromJson(Map<String, dynamic> json) {
    return PlannerFixedActivity(
      id: json['id']?.toString() ?? '',
      dayIndex: json['dayIndex'] as int? ?? 0,
      title: json['title']?.toString() ?? 'نشاط',
      startMinute: json['startMinute'] as int? ?? 480,
      endMinute: json['endMinute'] as int? ?? 540,
    );
  }
}

class WeeklyPlannerSettings {
  const WeeklyPlannerSettings({
    required this.studentName,
    required this.weekStart,
    required this.subjects,
    required this.activities,
    required this.availableDays,
    required this.studyStartMinute,
    required this.studyEndMinute,
    required this.sessionMinutes,
    required this.breakMinutes,
    required this.maxSessionsPerDay,
    required this.useMuwajjehPriority,
  });

  final String studentName;
  final DateTime weekStart;
  final List<WeeklySubjectTarget> subjects;
  final List<PlannerFixedActivity> activities;
  final Set<int> availableDays;
  final int studyStartMinute;
  final int studyEndMinute;
  final int sessionMinutes;
  final int breakMinutes;
  final int maxSessionsPerDay;
  final bool useMuwajjehPriority;

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        'weekStart': weekStart.toIso8601String(),
        'subjects': subjects.map((e) => e.toJson()).toList(),
        'activities': activities.map((e) => e.toJson()).toList(),
        'availableDays': availableDays.toList(),
        'studyStartMinute': studyStartMinute,
        'studyEndMinute': studyEndMinute,
        'sessionMinutes': sessionMinutes,
        'breakMinutes': breakMinutes,
        'maxSessionsPerDay': maxSessionsPerDay,
        'useMuwajjehPriority': useMuwajjehPriority,
      };

  factory WeeklyPlannerSettings.fromJson(Map<String, dynamic> json) {
    return WeeklyPlannerSettings(
      studentName: json['studentName']?.toString() ?? '',
      weekStart: DateTime.tryParse(json['weekStart']?.toString() ?? '') ?? DateTime.now(),
      subjects: (json['subjects'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => WeeklySubjectTarget.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      activities: (json['activities'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => PlannerFixedActivity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      availableDays: (json['availableDays'] as List<dynamic>? ?? const [0, 1, 2, 3, 4, 5, 6])
          .whereType<int>()
          .toSet(),
      studyStartMinute: json['studyStartMinute'] as int? ?? 960,
      studyEndMinute: json['studyEndMinute'] as int? ?? 1320,
      sessionMinutes: json['sessionMinutes'] as int? ?? 50,
      breakMinutes: json['breakMinutes'] as int? ?? 10,
      maxSessionsPerDay: json['maxSessionsPerDay'] as int? ?? 4,
      useMuwajjehPriority: json['useMuwajjehPriority'] as bool? ?? true,
    );
  }
}

enum PlannerBlockKind { study, activity }

class WeeklyPlanBlock {
  const WeeklyPlanBlock({
    required this.dayIndex,
    required this.startMinute,
    required this.endMinute,
    required this.title,
    required this.kind,
    this.subject = '',
    this.reason = '',
  });

  final int dayIndex;
  final int startMinute;
  final int endMinute;
  final String title;
  final PlannerBlockKind kind;
  final String subject;
  final String reason;
}

class WeeklyPlanResult {
  const WeeklyPlanResult({
    required this.settings,
    required this.blocks,
    required this.quote,
    required this.requestedStudySessions,
    required this.placedStudySessions,
    required this.warnings,
  });

  final WeeklyPlannerSettings settings;
  final List<WeeklyPlanBlock> blocks;
  final String quote;
  final int requestedStudySessions;
  final int placedStudySessions;
  final List<String> warnings;

  List<WeeklyPlanBlock> blocksForDay(int dayIndex) {
    final output = blocks.where((b) => b.dayIndex == dayIndex).toList()
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return output;
  }

  int sessionsForSubject(String subject) => blocks
      .where((b) => b.kind == PlannerBlockKind.study && b.subject == subject)
      .length;
}

String plannerTimeLabel(int minute) {
  final h = minute ~/ 60;
  final m = minute % 60;
  final period = h >= 12 ? 'م' : 'ص';
  var displayHour = h % 12;
  if (displayHour == 0) displayHour = 12;
  return '$displayHour:${m.toString().padLeft(2, '0')} $period';
}

String plannerDateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
