import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppController extends ChangeNotifier {
  static const _profileKey = 'student_profile_v1';
  static const _examResultsKey = 'exam_results_v1';
  static const _focusSessionsKey = 'focus_sessions_v1';
  static const _mistakesKey = 'mistakes_v1';
  static const _completedTasksKey = 'completed_study_tasks_v1';
  static const _questionAttemptsKey = 'question_attempts_v1';
  static const _learningPathsKey = 'learning_paths_v1';

  final List<ExamResultRecord> _examResults = [];
  final List<FocusSessionRecord> _focusSessions = [];
  final List<MistakeRecord> _mistakes = [];
  final List<QuestionAttemptRecord> _questionAttempts = [];
  final List<LearningPathRecord> _learningPaths = [];
  final Set<String> _completedStudyTaskIds = {};
  StudentProfile? _profile;

  StudentProfile? get profile => _profile;
  List<ExamResultRecord> get examResults => List.unmodifiable(_examResults);
  List<FocusSessionRecord> get focusSessions => List.unmodifiable(_focusSessions);
  List<MistakeRecord> get mistakes => List.unmodifiable(_mistakes);
  List<QuestionAttemptRecord> get questionAttempts => List.unmodifiable(_questionAttempts);
  List<LearningPathRecord> get learningPaths => List.unmodifiable(_learningPaths);
  bool get hasProfile => _profile != null && _profile!.name.trim().isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final profileRaw = prefs.getString(_profileKey);
    if (profileRaw != null) {
      try {
        _profile = StudentProfile.fromJson(
          jsonDecode(profileRaw) as Map<String, dynamic>,
        );
      } catch (_) {
        _profile = null;
      }
    }

    final resultsRaw = prefs.getStringList(_examResultsKey) ?? const [];
    _examResults
      ..clear()
      ..addAll(_decodeList(resultsRaw, ExamResultRecord.fromJson));

    final sessionsRaw = prefs.getStringList(_focusSessionsKey) ?? const [];
    _focusSessions
      ..clear()
      ..addAll(_decodeList(sessionsRaw, FocusSessionRecord.fromJson));

    final mistakesRaw = prefs.getStringList(_mistakesKey) ?? const [];
    _mistakes
      ..clear()
      ..addAll(_decodeList(mistakesRaw, MistakeRecord.fromJson));

    final attemptsRaw = prefs.getStringList(_questionAttemptsKey) ?? const [];
    _questionAttempts
      ..clear()
      ..addAll(_decodeList(attemptsRaw, QuestionAttemptRecord.fromJson));

    final pathsRaw = prefs.getStringList(_learningPathsKey) ?? const [];
    _learningPaths
      ..clear()
      ..addAll(_decodeList(pathsRaw, LearningPathRecord.fromJson));

    _completedStudyTaskIds
      ..clear()
      ..addAll(prefs.getStringList(_completedTasksKey) ?? const []);

    notifyListeners();
  }

  List<T> _decodeList<T>(
    List<String> raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final output = <T>[];
    for (final item in raw) {
      try {
        output.add(fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // تجاهل السجل التالف بدلاً من تعطيل التطبيق كله.
      }
    }
    return output;
  }

  Future<void> saveProfile(StudentProfile profile) async {
    _profile = profile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> addExamResult(ExamResultRecord result) async {
    _examResults.insert(0, result);
    if (_examResults.length > 150) {
      _examResults.removeRange(150, _examResults.length);
    }
    notifyListeners();
    await _persistExamResults();
  }

  Future<void> _persistExamResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _examResultsKey,
      _examResults.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> addMistakes(List<MistakeRecord> records) async {
    if (records.isEmpty) return;
    _mistakes.insertAll(0, records);
    if (_mistakes.length > 300) {
      _mistakes.removeRange(300, _mistakes.length);
    }
    notifyListeners();
    await _persistMistakes();
  }

  Future<void> dismissMistake(MistakeRecord record) async {
    _mistakes.removeWhere((item) =>
        item.questionId == record.questionId &&
        item.completedAt.toIso8601String() == record.completedAt.toIso8601String());
    notifyListeners();
    await _persistMistakes();
  }

  Future<void> clearMistakes() async {
    _mistakes.clear();
    notifyListeners();
    await _persistMistakes();
  }

  Future<void> _persistMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _mistakesKey,
      _mistakes.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }


  Future<void> addQuestionAttempts(List<QuestionAttemptRecord> records) async {
    if (records.isEmpty) return;
    _questionAttempts.insertAll(0, records);
    if (_questionAttempts.length > 2500) {
      _questionAttempts.removeRange(2500, _questionAttempts.length);
    }
    notifyListeners();
    await _persistQuestionAttempts();
  }

  Future<void> _persistQuestionAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _questionAttemptsKey,
      _questionAttempts.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }


  Future<void> _persistLearningPaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _learningPathsKey,
      _learningPaths.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  LearningPathRecord? get activeLearningPath {
    for (final path in _learningPaths) {
      if (!path.archived) return path;
    }
    return null;
  }

  MasteryReviewTarget? get nextLearningPathTarget {
    final metrics = masteryBySkill();
    if (metrics.isEmpty) return null;
    final measured = metrics.where((m) => m.attempts >= 2 && m.score < 85).toList();
    final earlySignal = metrics.where((m) => m.attempts == 1 && m.score < 65).toList();
    final pool = measured.isNotEmpty ? measured : earlySignal;
    if (pool.isEmpty) return null;
    final chosen = pool.first;
    return MasteryReviewTarget(
      subject: chosen.subject,
      unit: chosen.unit,
      lesson: chosen.lesson,
      skill: chosen.skill,
      score: chosen.score,
      reason: chosen.confidence < 35
          ? 'الإتقان منخفض لكن الثقة ما زالت محدودة؛ سيبدأ المسار بتثبيت المفهوم ثم القياس.'
          : 'هذه من أقل مهاراتك إتقانًا حاليًا (${chosen.score.round()}%)، لذا لها أولوية علاجية.',
    );
  }

  Future<LearningPathRecord?> startLearningPathFromWeakestSkill() async {
    final target = nextLearningPathTarget;
    if (target == null) return null;
    return startLearningPath(
      subject: target.subject,
      unit: target.unit,
      lesson: target.lesson,
      skill: target.skill,
      baselineMastery: target.score,
    );
  }

  Future<LearningPathRecord> startLearningPath({
    required String subject,
    required String unit,
    required String lesson,
    required String skill,
    required double baselineMastery,
  }) async {
    final now = DateTime.now();
    for (var i = 0; i < _learningPaths.length; i++) {
      final old = _learningPaths[i];
      if (!old.archived) {
        _learningPaths[i] = old.copyWith(archived: true, updatedAt: now);
      }
    }
    final record = LearningPathRecord(
      id: 'lp-${now.millisecondsSinceEpoch}',
      subject: subject,
      unit: unit,
      lesson: lesson,
      skill: skill,
      createdAt: now,
      updatedAt: now,
      baselineMastery: baselineMastery,
    );
    _learningPaths.insert(0, record);
    notifyListeners();
    await _persistLearningPaths();
    return record;
  }

  Future<void> markLearningConceptReviewed(String pathId, bool value) async {
    final index = _learningPaths.indexWhere((p) => p.id == pathId);
    if (index < 0) return;
    _learningPaths[index] = _learningPaths[index].copyWith(
      conceptReviewed: value,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistLearningPaths();
  }

  Future<void> archiveLearningPath(String pathId) async {
    final index = _learningPaths.indexWhere((p) => p.id == pathId);
    if (index < 0) return;
    _learningPaths[index] = _learningPaths[index].copyWith(
      archived: true,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistLearningPaths();
  }

  List<QuestionAttemptRecord> _pathAttempts(
    LearningPathRecord path,
    String examType,
  ) {
    return _questionAttempts.where((a) {
      if (a.completedAt.isBefore(path.createdAt)) return false;
      return a.examType == examType &&
          a.examTitle.contains(path.id);
    }).toList();
  }

  LearningPathSnapshot snapshotForLearningPath(LearningPathRecord path) {
    final foundation = _pathAttempts(path, 'learning_foundation');
    final checkpoint = _pathAttempts(path, 'learning_checkpoint');
    final foundationRecent = foundation.take(5).toList();
    final checkpointRecent = checkpoint.take(5).toList();
    final foundationCorrect = foundationRecent.where((a) => a.isCorrect).length;
    final checkpointCorrect = checkpointRecent.where((a) => a.isCorrect).length;
    final foundationPct = foundationRecent.isEmpty
        ? 0
        : ((foundationCorrect / foundationRecent.length) * 100).round();
    final checkpointPct = checkpointRecent.isEmpty
        ? 0
        : ((checkpointCorrect / checkpointRecent.length) * 100).round();
    final checkpointComplete = checkpointRecent.length >= 5;
    final completed = checkpointComplete && checkpointPct >= 80;
    final remediation = checkpointComplete && checkpointPct < 80;

    var stage = 0;
    if (path.conceptReviewed) stage = 1;
    if (path.conceptReviewed && foundationRecent.length >= 5 && foundationPct >= 60) stage = 2;
    if (remediation) stage = 3;
    if (completed) stage = 4;

    final metric = masteryForAttempts(
      _questionAttempts.where((a) =>
          a.subject == path.subject &&
          a.unit == path.unit &&
          a.lesson == path.lesson &&
          a.skill == path.skill),
      subject: path.subject,
      unit: path.unit,
      lesson: path.lesson,
      skill: path.skill,
    );

    return LearningPathSnapshot(
      record: path,
      currentMastery: metric,
      foundationAttempts: foundationRecent.length,
      foundationCorrect: foundationCorrect,
      checkpointAttempts: checkpointRecent.length,
      checkpointCorrect: checkpointCorrect,
      stage: stage,
      isCompleted: completed,
      needsRemediation: remediation,
    );
  }

  LearningPathSnapshot? get activeLearningPathSnapshot {
    final path = activeLearningPath;
    return path == null ? null : snapshotForLearningPath(path);
  }

  int attemptCountForSubject(String subject) =>
      _questionAttempts.where((item) => item.subject == subject).length;

  double _difficultyWeight(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return 0.85;
      case 'صعب':
        return 1.15;
      case 'متقدم':
        return 1.30;
      default:
        return 1.0;
    }
  }

  int _targetSeconds(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return 45;
      case 'صعب':
        return 80;
      case 'متقدم':
        return 100;
      default:
        return 60;
    }
  }

  double _attemptRecencyWeight(DateTime completedAt) {
    final days = DateTime.now().difference(completedAt).inDays;
    if (days <= 0) return 1.0;
    return math.max(0.55, 1.0 - (days * 0.012));
  }

  MasteryMetric masteryForAttempts(
    Iterable<QuestionAttemptRecord> source, {
    String subject = '',
    String unit = '',
    String lesson = '',
    String skill = '',
  }) {
    final attempts = source.toList();
    if (attempts.isEmpty) {
      return MasteryMetric(
        subject: subject,
        unit: unit,
        lesson: lesson,
        skill: skill,
        score: 55,
        confidence: 0,
        attempts: 0,
        correct: 0,
        averageResponseSeconds: 0,
        lastAttemptAt: null,
      );
    }

    var weightedTotal = 0.0;
    var weightedEarned = 0.0;
    var secondsTotal = 0;
    var secondsCount = 0;
    var correct = 0;
    DateTime? latest;

    for (final attempt in attempts) {
      final difficultyWeight = _difficultyWeight(attempt.difficulty);
      final recencyWeight = _attemptRecencyWeight(attempt.completedAt);
      final weight = difficultyWeight * recencyWeight;
      weightedTotal += weight;

      if (attempt.isCorrect) {
        correct++;
        final seconds = attempt.responseSeconds;
        final target = _targetSeconds(attempt.difficulty);
        var speedScore = 0.75;
        if (seconds > 0) {
          speedScore = (target / seconds).clamp(0.55, 1.0).toDouble();
        }
        final correctnessCredit = 0.90 + (0.10 * speedScore);
        weightedEarned += weight * correctnessCredit;
      }

      if (attempt.responseSeconds > 0) {
        secondsTotal += attempt.responseSeconds;
        secondsCount++;
      }
      if (latest == null || attempt.completedAt.isAfter(latest)) {
        latest = attempt.completedAt;
      }
    }

    const priorWeight = 2.0;
    const priorScore = 0.55;
    final score =
        ((weightedEarned + priorWeight * priorScore) / (weightedTotal + priorWeight)) * 100;
    final confidence = (1 - math.exp(-weightedTotal / 5.0)) * 100;

    return MasteryMetric(
      subject: subject.isEmpty ? attempts.first.subject : subject,
      unit: unit,
      lesson: lesson,
      skill: skill,
      score: score.clamp(0, 100).toDouble(),
      confidence: confidence.clamp(0, 100).toDouble(),
      attempts: attempts.length,
      correct: correct,
      averageResponseSeconds:
          secondsCount == 0 ? 0 : secondsTotal / secondsCount,
      lastAttemptAt: latest,
    );
  }

  MasteryMetric masteryForSubject(String subject) {
    return masteryForAttempts(
      _questionAttempts.where((a) => a.subject == subject),
      subject: subject,
    );
  }

  MasteryMetric masteryForUnit(String subject, String unit) {
    return masteryForAttempts(
      _questionAttempts.where((a) => a.subject == subject && a.unit == unit),
      subject: subject,
      unit: unit,
    );
  }

  MasteryMetric masteryForLesson(String subject, String unit, String lesson) {
    return masteryForAttempts(
      _questionAttempts.where(
        (a) => a.subject == subject && a.unit == unit && a.lesson == lesson,
      ),
      subject: subject,
      unit: unit,
      lesson: lesson,
    );
  }

  List<MasteryMetric> masteryBySkill({String? subject}) {
    final grouped = <String, List<QuestionAttemptRecord>>{};
    for (final attempt in _questionAttempts) {
      if (subject != null && attempt.subject != subject) continue;
      final key = '${attempt.subject}|${attempt.unit}|${attempt.lesson}|${attempt.skill}';
      grouped.putIfAbsent(key, () => []).add(attempt);
    }

    final output = <MasteryMetric>[];
    for (final entry in grouped.entries) {
      final parts = entry.key.split('|');
      output.add(
        masteryForAttempts(
          entry.value,
          subject: parts.isNotEmpty ? parts[0] : '',
          unit: parts.length > 1 ? parts[1] : '',
          lesson: parts.length > 2 ? parts[2] : '',
          skill: parts.length > 3 ? parts[3] : '',
        ),
      );
    }
    output.sort((a, b) {
      final scoreOrder = a.score.compareTo(b.score);
      if (scoreOrder != 0) return scoreOrder;
      return b.attempts.compareTo(a.attempts);
    });
    return output;
  }

  MasteryReviewTarget? get nextMasteryTarget {
    final metrics = masteryBySkill();
    if (metrics.isEmpty) return null;

    final candidates = metrics.where((m) => m.attempts >= 2).toList();
    final chosen = candidates.isEmpty ? metrics.first : candidates.first;
    final confidenceText = chosen.confidence < 35
        ? 'البيانات ما زالت محدودة، لذلك نحتاج محاولة إضافية للتأكد.'
        : 'تكررت المحاولات بما يكفي لإعطاء هذه المهارة أولوية مراجعة.';
    return MasteryReviewTarget(
      subject: chosen.subject,
      unit: chosen.unit,
      lesson: chosen.lesson,
      skill: chosen.skill,
      score: chosen.score,
      reason:
          'درجة الإتقان ${chosen.score.round()}% (${chosen.status}). $confidenceText',
    );
  }

  Future<void> addFocusSession(FocusSessionRecord session) async {
    _focusSessions.insert(0, session);
    if (_focusSessions.length > 250) {
      _focusSessions.removeRange(250, _focusSessions.length);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _focusSessionsKey,
      _focusSessions.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> toggleStudyTask(String taskId) async {
    if (_completedStudyTaskIds.contains(taskId)) {
      _completedStudyTaskIds.remove(taskId);
    } else {
      _completedStudyTaskIds.add(taskId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedTasksKey, _completedStudyTaskIds.toList());
  }

  bool isStudyTaskCompleted(String taskId) =>
      _completedStudyTaskIds.contains(taskId);

  double? get overallExamAverage {
    if (_examResults.isEmpty) return null;
    final total = _examResults.fold<int>(0, (sum, item) => sum + item.percentage);
    return total / _examResults.length;
  }

  int get totalFocusMinutes =>
      _focusSessions.fold<int>(0, (sum, session) => sum + session.minutes);

  int get todayFocusMinutes {
    final now = DateTime.now();
    return _focusSessions
        .where((session) => _sameDate(session.completedAt, now))
        .fold<int>(0, (sum, session) => sum + session.minutes);
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<SubjectPerformance> get subjectPerformance {
    final grouped = <String, List<int>>{};
    for (final result in _examResults) {
      if (_profile != null && !_profile!.subjects.contains(result.subject)) continue;
      grouped.putIfAbsent(result.subject, () => []).add(result.percentage);
    }

    final output = grouped.entries.map((entry) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return SubjectPerformance(
        subject: entry.key,
        average: average,
        attempts: entry.value.length,
      );
    }).toList()
      ..sort((a, b) => b.average.compareTo(a.average));

    return output;
  }

  SubjectPerformance? get strongestSubject {
    final data = subjectPerformance;
    return data.isEmpty ? null : data.first;
  }

  SubjectPerformance? get weakestSubject {
    final data = subjectPerformance;
    return data.isEmpty ? null : data.last;
  }

  int mistakeCountForSubject(String subject) =>
      _mistakes.where((item) => item.subject == subject).length;

  String? topWeakUnitForSubject(String subject) {
    final counts = <String, int>{};
    for (final mistake in _mistakes.where((item) => item.subject == subject)) {
      counts[mistake.unit] = (counts[mistake.unit] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double? performanceForSubject(String subject) {
    final values = _examResults
        .where((item) => item.subject == subject)
        .map((item) => item.percentage)
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _priorityScore(String subject) {
    final average = performanceForSubject(subject);
    final mistakesCount = mistakeCountForSubject(subject);
    final weakness = average == null ? 0.55 : (100 - average) / 100;
    final mistakesBoost = math.min(mistakesCount, 8) * 0.07;
    final noDataBoost = average == null ? 0.18 : 0.0;
    return 0.25 + weakness + mistakesBoost + noDataBoost;
  }

  List<String> get subjectsByPriority {
    final subjects = List<String>.from(_profile?.subjects ?? const <String>[]);
    subjects.sort((a, b) => _priorityScore(b).compareTo(_priorityScore(a)));
    return subjects;
  }

  List<StudyTask> get dailyStudyPlan {
    final profile = _profile;
    if (profile == null || profile.subjects.isEmpty) return const [];

    final today = DateTime.now();
    final taskCapacity = math.max(1, profile.dailyGoalMinutes ~/ 30);
    final subjectCount = math.min(math.min(4, taskCapacity), profile.subjects.length);
    final subjects = subjectsByPriority.take(subjectCount).toList();
    final weights = subjects.map(_priorityScore).toList();
    final totalWeight = weights.fold<double>(0, (sum, value) => sum + value);
    var remaining = profile.dailyGoalMinutes;
    final tasks = <StudyTask>[];

    for (var i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final mistakesCount = mistakeCountForSubject(subject);
      final average = performanceForSubject(subject);
      final weakUnit = topWeakUnitForSubject(subject);
      int minutes;
      if (i == subjects.length - 1) {
        minutes = math.max(10, remaining);
      } else {
        minutes = math.max(15, (profile.dailyGoalMinutes * (weights[i] / totalWeight)).round());
        minutes = math.min(minutes, math.max(15, remaining - 10 * (subjects.length - i - 1)));
      }
      remaining -= minutes;

      String title;
      String description;
      String reason;
      if (mistakesCount > 0) {
        title = 'عالج أخطاء $subject';
        description = weakUnit == null
            ? 'راجع أخطاءك الأخيرة ثم أجب عن تدريب قصير موجّه.'
            : 'ابدأ بوحدة «$weakUnit»، راجع الخطأ ثم أعد حل سؤال مشابه.';
        reason = 'لديك $mistakesCount خطأ/أخطاء مسجلة في هذا المبحث.';
      } else if (average == null) {
        title = 'شخّص مستواك في $subject';
        description = 'راجع المفاهيم الأساسية ثم نفّذ اختباراً تشخيصياً قصيراً.';
        reason = 'لا توجد نتائج كافية بعد لبناء تشخيص دقيق.';
      } else if (average < 70) {
        title = 'ثبّت أساسيات $subject';
        description = 'راجع المفاهيم التي سببت انخفاض النتيجة ثم طبّق عليها مباشرة.';
        reason = 'متوسطك الحالي ${average.round()}% ويحتاج إلى تثبيت الأساسيات.';
      } else {
        title = 'تدريب متقدم في $subject';
        description = 'حل أسئلة أصعب مع ضبط الزمن والمحافظة على دقة الإجابة.';
        reason = 'متوسطك الحالي ${average.round()}%؛ الهدف الآن رفع الدقة والسرعة.';
      }

      tasks.add(
        StudyTask(
          id: '${_dateKey(today)}-daily-$i-${_safeId(subject)}',
          subject: subject,
          title: title,
          description: description,
          minutes: minutes,
          priority: i + 1,
          reason: reason,
        ),
      );
    }

    return tasks;
  }

  int get todayPlanCompletedMinutes => dailyStudyPlan
      .where((task) => isStudyTaskCompleted(task.id))
      .fold<int>(0, (sum, task) => sum + task.minutes);

  List<WeeklyPlanDay> get weeklyStudyPlan {
    final profile = _profile;
    if (profile == null || profile.subjects.isEmpty) return const [];
    final ranked = subjectsByPriority;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final days = <WeeklyPlanDay>[];

    for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = start.add(Duration(days: dayOffset));
      final first = ranked[dayOffset % ranked.length];
      final second = ranked.length > 1 ? ranked[(dayOffset + 1) % ranked.length] : first;
      final firstMinutes = (profile.dailyGoalMinutes * 0.6).round();
      final secondMinutes = profile.dailyGoalMinutes - firstMinutes;
      final dayTasks = <StudyTask>[
        _weeklyTask(date, first, firstMinutes, 1, dayOffset),
        if (second != first && secondMinutes > 0)
          _weeklyTask(date, second, secondMinutes, 2, dayOffset),
      ];
      days.add(WeeklyPlanDay(date: date, tasks: dayTasks));
    }
    return days;
  }

  StudyTask _weeklyTask(
    DateTime date,
    String subject,
    int minutes,
    int priority,
    int dayOffset,
  ) {
    final mistakesCount = mistakeCountForSubject(subject);
    final weakUnit = topWeakUnitForSubject(subject);
    final title = mistakesCount > 0 ? 'مراجعة علاجية: $subject' : 'تدريب: $subject';
    final description = mistakesCount > 0
        ? 'راجع ${weakUnit == null ? 'أخطاءك السابقة' : 'وحدة «$weakUnit»'} ثم اختبر نفسك.'
        : 'راجع نقطة رئيسية ثم حل مجموعة أسئلة بزمن محدد.';
    final reason = mistakesCount > 0
        ? 'أولوية بسبب الأخطاء المسجلة.'
        : 'حفاظ على التوازن والاستمرارية الأسبوعية.';
    return StudyTask(
      id: '${_dateKey(date)}-weekly-$dayOffset-$priority-${_safeId(subject)}',
      subject: subject,
      title: title,
      description: description,
      minutes: minutes,
      priority: priority,
      reason: reason,
    );
  }

  StudyRecommendation recommendationAfterExam(String subject, int percentage) {
    final weakUnit = topWeakUnitForSubject(subject);
    final mistakesCount = mistakeCountForSubject(subject);
    if (percentage < 50) {
      return StudyRecommendation(
        title: 'الأولوية: إعادة بناء الأساس',
        subject: subject,
        actionLabel: 'افتح سجل الأخطاء',
        message: weakUnit == null
            ? 'ابدأ بمراجعة المفاهيم الأساسية في $subject قبل اختبار جديد.'
            : 'ركز أولاً على وحدة «$weakUnit». لديك $mistakesCount أخطاء مسجلة تحتاج إلى مراجعة متأنية.',
      );
    }
    if (percentage < 75) {
      return StudyRecommendation(
        title: 'الأولوية: علاج الأخطاء المتكررة',
        subject: subject,
        actionLabel: 'تدريب موجّه',
        message: 'مستواك متوسط. راجع الأخطاء المسجلة في $subject ثم أعد اختباراً قصيراً بعد المراجعة.',
      );
    }
    if (percentage < 90) {
      return StudyRecommendation(
        title: 'الأولوية: رفع الدقة والسرعة',
        subject: subject,
        actionLabel: 'ابدأ تحدياً زمنياً',
        message: 'الأساس جيد. انتقل إلى أسئلة أصعب مع وقت محدد وراجع أي خطأ قبل الانتقال للسؤال التالي.',
      );
    }
    return StudyRecommendation(
      title: 'الأولوية: المحافظة على التفوق',
      subject: subject,
      actionLabel: 'اختبار محاكاة',
      message: 'نتيجتك قوية جداً. اختبر ثبات مستواك في محاكاة أطول ومتنوعة وركز على إدارة الوقت.',
    );
  }

  StudyRecommendation get nextRecommendation {
    final pathSnapshot = activeLearningPathSnapshot;
    if (pathSnapshot != null && !pathSnapshot.isCompleted) {
      return StudyRecommendation(
        title: 'أكمل مسارك: ${pathSnapshot.record.skill}',
        subject: pathSnapshot.record.subject,
        actionLabel: 'افتح المسار',
        message:
            '${pathSnapshot.record.subject} • ${pathSnapshot.record.lesson}: المرحلة الحالية ${pathSnapshot.stageLabel}.',
      );
    }

    final masteryTarget = nextMasteryTarget;
    if (masteryTarget != null && questionAttempts.length >= 3) {
      return StudyRecommendation(
        title: 'الأولوية: ${masteryTarget.skill}',
        subject: masteryTarget.subject,
        actionLabel: 'راجع المهارة',
        message:
            '${masteryTarget.subject} • ${masteryTarget.lesson}: إتقان ${masteryTarget.score.round()}%. ${masteryTarget.reason}',
      );
    }

    final ranked = subjectsByPriority;
    if (ranked.isEmpty) {
      return const StudyRecommendation(
        title: 'ابدأ بالتشخيص',
        subject: '',
        actionLabel: 'اختبار تشخيصي',
        message: 'أضف مباحثك إلى الملف الشخصي حتى يبني مُوَجِّه خطة مناسبة لك.',
      );
    }
    final subject = ranked.first;
    final average = performanceForSubject(subject);
    if (average == null) {
      return StudyRecommendation(
        title: 'الخطوة التالية: قياس المستوى',
        subject: subject,
        actionLabel: 'ابدأ اختباراً',
        message: 'لا توجد بيانات كافية عن $subject. نفّذ اختباراً قصيراً حتى يصبح التخطيط أدق.',
      );
    }
    return recommendationAfterExam(subject, average.round());
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _safeId(String input) => input.replaceAll(RegExp(r'\s+'), '_');
}
