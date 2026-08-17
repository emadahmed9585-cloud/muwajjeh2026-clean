import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'exam_data.dart';
import 'curriculum_data.dart';
import 'models.dart';
import 'v13_question_card.dart';
import 'v13_theme.dart';

class SmartPlanScreen extends StatelessWidget {
  const SmartPlanScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final daily = controller.dailyStudyPlan;
        final weekly = controller.weeklyStudyPlan;
        final goal = controller.profile?.dailyGoalMinutes ?? 0;
        final done = controller.todayPlanCompletedMinutes;
        final progress = goal == 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
        final recommendation = controller.nextRecommendation;

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'خطة اليوم', icon: Icon(Icons.today_outlined)),
                    Tab(text: 'خطة الأسبوع', icon: Icon(Icons.calendar_view_week_outlined)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        _PlanHeader(
                          completedMinutes: done,
                          goalMinutes: goal,
                          progress: progress,
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(recommendation.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(recommendation.message),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('مهام اليوم', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        if (daily.isEmpty)
                          const _V4EmptyState(
                            icon: Icons.event_note_outlined,
                            text: 'أضف مباحثك وهدفك اليومي حتى يبني مُوَجِّه خطة مناسبة.',
                          )
                        else
                          ...daily.map(
                            (task) => _StudyTaskCard(
                              task: task,
                              completed: controller.isStudyTaskCompleted(task.id),
                              onChanged: () => controller.toggleStudyTask(task.id),
                            ),
                          ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MistakesScreen(controller: controller),
                              ),
                            );
                          },
                          icon: const Icon(Icons.folder_open_outlined),
                          label: Text('سجل الأخطاء (${controller.mistakes.length})'),
                        ),
                      ],
                    ),
                    ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        const Text(
                          'الخطة الأسبوعية الذكية',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'تُعاد موازنة الأولويات تلقائياً كلما أضفت نتيجة أو خطأ جديداً.',
                          style: TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        ...weekly.map(
                          (day) => _WeeklyDayCard(day: day, controller: controller),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.completedMinutes,
    required this.goalMinutes,
    required this.progress,
  });

  final int completedMinutes;
  final int goalMinutes;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MuwajjehPalette.navy, Color(0xFF215A67)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تقدّم خطة اليوم', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),
          const SizedBox(height: 9),
          Text(
            '$completedMinutes من $goalMinutes دقيقة مخططة',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StudyTaskCard extends StatelessWidget {
  const _StudyTaskCard({
    required this.task,
    required this.completed,
    required this.onChanged,
  });

  final StudyTask task;
  final bool completed;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: completed, onChanged: (_) => onChanged()),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Chip(label: Text('${task.minutes} د')),
                    ],
                  ),
                  Text(task.description, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    'لماذا؟ ${task.reason}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyDayCard extends StatelessWidget {
  const _WeeklyDayCard({required this.day, required this.controller});

  final WeeklyPlanDay day;
  final AppController controller;

  static const _weekdayNames = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  @override
  Widget build(BuildContext context) {
    final name = _weekdayNames[day.date.weekday - 1];
    return Card(
      child: ExpansionTile(
        initiallyExpanded: _isToday(day.date),
        leading: CircleAvatar(child: Text('${day.date.day}')),
        title: Text('$name • ${day.date.day}/${day.date.month}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${day.tasks.fold<int>(0, (sum, task) => sum + task.minutes)} دقيقة'),
        children: [
          ...day.tasks.map(
            (task) => CheckboxListTile(
              value: controller.isStudyTaskCompleted(task.id),
              onChanged: (_) => controller.toggleStudyTask(task.id),
              title: Text(task.title),
              subtitle: Text('${task.minutes} دقيقة • ${task.description}'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _subject = 'الكل';
  String _unit = 'الكل';
  String _difficulty = 'الكل';
  String _sourceFilter = 'الكل';
  int _questionCount = 10;

  List<ExamQuestion> get _baseQuestions => allBankQuestions;

  List<String> get _subjects {
    final values = _baseQuestions.map((q) => q.subject).where((e) => e.isNotEmpty).toSet().toList()..sort();
    return ['الكل', ...values];
  }

  List<String> get _units {
    final source = _subject == 'الكل'
        ? _baseQuestions
        : _baseQuestions.where((q) => q.subject == _subject).toList();
    final values = source.map((q) => q.unit).toSet().toList()..sort();
    return ['الكل', ...values];
  }

  List<ExamQuestion> get _filtered {
    return _baseQuestions.where((question) {
      final subjectOk = _subject == 'الكل' || question.subject == _subject;
      final unitOk = _unit == 'الكل' || question.unit == _unit;
      final difficultyOk = _difficulty == 'الكل' || question.difficulty == _difficulty;
      final sourceOk = _sourceFilter == 'الكل' ||
          (_sourceFilter == 'من الكتاب الرسمي' && question.isOfficialBookQuestion && !question.isTransferQuestion) ||
          (_sourceFilter == 'نقل وفهم' && question.isTransferQuestion) ||
          (_sourceFilter == 'تجريبي/قديم' && !question.verifiedFromOfficialCurriculum);
      return subjectOk && unitOk && difficultyOk && sourceOk;
    }).toList();
  }

  void _startPractice() {
    final questions = List<ExamQuestion>.from(_filtered)..shuffle(math.Random());
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أسئلة مطابقة لهذه المرشحات.')),
      );
      return;
    }
    final selected = questions.take(math.min(_questionCount, questions.length)).toList();
    final subjectName = _subject == 'الكل' ? 'تدريب مخصص' : _subject;
    final exam = ExamDefinition(
      title: 'تدريب مخصص - $subjectName',
      subtitle: 'تم إنشاؤه من بنك الأسئلة وفق المرشحات التي اخترتها.',
      subject: subjectName,
      icon: Icons.tune,
      questions: selected,
      unit: _unit,
      difficulty: _difficulty,
      durationMinutes: math.max(10, selected.length * 2),
      examType: 'custom',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdaptiveQuizScreen(
          controller: widget.controller,
          exam: exam,
          timed: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('بنك الأسئلة')), 
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('أنشئ تدريبك', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('اختر المبحث والوحدة والصعوبة، وسيبني التطبيق اختباراً قصيراً من الأسئلة المطابقة.'),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(labelText: 'المبحث'),
            items: _subjects.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _subject = value;
                _unit = 'الكل';
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _units.contains(_unit) ? _unit : 'الكل',
            decoration: const InputDecoration(labelText: 'الوحدة'),
            items: _units.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) => setState(() => _unit = value ?? 'الكل'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _difficulty,
            decoration: const InputDecoration(labelText: 'الصعوبة'),
            items: const ['الكل', 'سهل', 'متوسط', 'صعب', 'متقدم']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _difficulty = value ?? 'الكل'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _sourceFilter,
            decoration: const InputDecoration(labelText: 'المصدر'),
            items: const ['الكل', 'من الكتاب الرسمي', 'نقل وفهم', 'تجريبي/قديم']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _sourceFilter = value ?? 'الكل'),
          ),
          const SizedBox(height: 18),
          Text('عدد الأسئلة: ${math.min(_questionCount, math.max(1, filtered.length))}'),
          Slider(
            value: _questionCount.toDouble().clamp(5.0, 20.0).toDouble(),
            min: 5,
            max: 20,
            divisions: 3,
            label: '$_questionCount',
            onChanged: (value) => setState(() => _questionCount = value.round()),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.filter_alt_outlined),
              title: Text('${filtered.length} سؤال متاح'),
              subtitle: Text('${filtered.where((q) => q.isOfficialBookQuestion && !q.isTransferQuestion).length} من الكتاب • ${filtered.where((q) => q.isTransferQuestion).length} نقل وفهم • ${filtered.where((q) => !q.verifiedFromOfficialCurriculum).length} قديم/تجريبي'),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _startPractice,
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ابدأ التدريب المخصص'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('معاينة الأسئلة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...filtered.take(8).map(
            (question) => Card(
              child: ListTile(
                title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${question.subject} • ${question.unit} • ${question.lesson}\n${question.isTransferQuestion ? 'نقل وفهم – من مهارة المنهاج $currentCurriculumYear' : question.verifiedFromOfficialCurriculum ? 'من الكتاب/المنهاج الرسمي $currentCurriculumYear' : 'سؤال تجريبي قديم'}'),
                isThreeLine: true,
                trailing: Chip(label: Text(question.difficulty)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TawjihiMockSetupScreen extends StatefulWidget {
  const TawjihiMockSetupScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<TawjihiMockSetupScreen> createState() => _TawjihiMockSetupScreenState();
}

class _TawjihiMockSetupScreenState extends State<TawjihiMockSetupScreen> {
  int _count = 20;
  int _minutes = 40;

  void _start() {
    final questions = List<ExamQuestion>.from(allBankQuestions)..shuffle(math.Random());
    final selected = questions.take(math.min(_count, questions.length)).toList();
    final exam = ExamDefinition(
      title: 'محاكاة توجيهي تدريبية',
      subtitle: 'اختبار مختلط بزمن محدد من بنك التطبيق.',
      subject: 'محاكاة شاملة',
      icon: Icons.emoji_events_outlined,
      questions: selected,
      unit: 'متعدد الوحدات',
      difficulty: 'مختلط',
      durationMinutes: _minutes,
      examType: 'mock',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdaptiveQuizScreen(
          controller: widget.controller,
          exam: exam,
          timed: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاكاة التوجيهي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.emoji_events_outlined, size: 72, color: MuwajjehPalette.teal),
          const SizedBox(height: 12),
          const Text('اختبار محاكاة تدريبي', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'محاكاة تدريبية داخلية تضم أسئلة منشأة وفق المنهاج وأخرى تجريبية؛ وليست نموذجاً وزارياً رسمياً.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 24),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 10, label: Text('10 أسئلة')),
              ButtonSegment(value: 20, label: Text('20 سؤالاً')),
              ButtonSegment(value: 30, label: Text('30 سؤالاً')),
            ],
            selected: {_count},
            onSelectionChanged: (selection) => setState(() => _count = selection.first),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<int>(
            value: _minutes,
            decoration: const InputDecoration(labelText: 'الوقت'),
            items: const [20, 30, 40, 60]
                .map((minutes) => DropdownMenuItem(value: minutes, child: Text('$minutes دقيقة')))
                .toList(),
            onChanged: (value) => setState(() => _minutes = value ?? 40),
          ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: const [
                ListTile(leading: Icon(Icons.shuffle), title: Text('أسئلة مختلطة وعشوائية')),
                Divider(height: 1),
                ListTile(leading: Icon(Icons.timer_outlined), title: Text('مؤقت حقيقي ينهي الاختبار عند انتهاء الوقت')),
                Divider(height: 1),
                ListTile(leading: Icon(Icons.analytics_outlined), title: Text('حفظ النتيجة والأخطاء والتوصية تلقائياً')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_circle_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ابدأ المحاكاة'),
            ),
          ),
        ],
      ),
    );
  }
}

class MistakesScreen extends StatefulWidget {
  const MistakesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MistakesScreen> createState() => _MistakesScreenState();
}

class _MistakesScreenState extends State<MistakesScreen> {
  String _subject = 'الكل';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final subjects = widget.controller.mistakes.map((e) => e.subject).toSet().toList()..sort();
        if (_subject != 'الكل' && !subjects.contains(_subject)) _subject = 'الكل';
        final records = widget.controller.mistakes
            .where((item) => _subject == 'الكل' || item.subject == _subject)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('سجل الأخطاء'),
            actions: [
              if (widget.controller.mistakes.isNotEmpty)
                IconButton(
                  tooltip: 'مسح السجل',
                  onPressed: () => _confirmClear(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: records.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: _V4EmptyState(
                      icon: Icons.task_alt,
                      text: 'لا توجد أخطاء مسجلة في هذا القسم. أكمل اختباراً لتظهر الأخطاء هنا.',
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DropdownButtonFormField<String>(
                      value: _subject,
                      decoration: const InputDecoration(labelText: 'تصفية حسب المبحث'),
                      items: ['الكل', ...subjects]
                          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => _subject = value ?? 'الكل'),
                    ),
                    const SizedBox(height: 14),
                    Text('${records.length} خطأ للمراجعة', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...records.map((record) => _MistakeCard(record: record, controller: widget.controller)),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح سجل الأخطاء؟'),
        content: const Text('سيُحذف سجل الأخطاء المحلي. نتائج الاختبارات لن تُحذف.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('مسح')),
        ],
      ),
    );
    if (confirmed == true) await widget.controller.clearMistakes();
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.record, required this.controller});

  final MistakeRecord record;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const CircleAvatar(child: Icon(Icons.close)),
        title: Text(record.questionText, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${record.subject} • ${record.unit} • ${record.difficulty} • ${record.errorType == 'غير مصنف' ? classifyErrorType(record.skill) : record.errorType}'
            '${record.verifiedFromOfficialCurriculum && record.curriculumYear.isNotEmpty ? ' • منهاج ${record.curriculumYear}' : ''}'),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        children: [
          Align(alignment: Alignment.centerRight, child: Text('إجابتك: ${record.selectedOption}')),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text('الصحيح: ${record.correctOption}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: Text(record.explanation, style: const TextStyle(height: 1.5))),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => controller.dismissMistake(record),
              icon: const Icon(Icons.done),
              label: const Text('راجعت هذا الخطأ'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdaptiveQuizScreen extends StatefulWidget {
  const AdaptiveQuizScreen({
    super.key,
    required this.controller,
    required this.exam,
    required this.timed,
  });

  final AppController controller;
  final ExamDefinition exam;
  final bool timed;

  @override
  State<AdaptiveQuizScreen> createState() => _AdaptiveQuizScreenState();
}

class _AdaptiveQuizScreenState extends State<AdaptiveQuizScreen> {
  late final List<int?> _answers;
  late final List<int> _responseSeconds;
  late DateTime _lastInteractionAt;
  Timer? _timer;
  late int _remainingSeconds;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.exam.questions.length, null);
    _responseSeconds = List<int>.filled(widget.exam.questions.length, 0);
    _lastInteractionAt = DateTime.now();
    _remainingSeconds = widget.exam.durationMinutes * 60;
    if (widget.timed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_remainingSeconds <= 1) {
          timer.cancel();
          setState(() => _remainingSeconds = 0);
          _submit(force: true);
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _recordAnswer(int questionIndex, int? value) {
    if (value == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(_lastInteractionAt).inSeconds.clamp(1, 300).toInt();
    _responseSeconds[questionIndex] =
        (_responseSeconds[questionIndex] + elapsed).clamp(1, 600).toInt();
    _lastInteractionAt = now;
    setState(() => _answers[questionIndex] = value);
  }

  Future<void> _submit({bool force = false}) async {
    if (_submitting) return;
    final unanswered = _answers.where((answer) => answer == null).length;
    if (!force && unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بقي $unanswered سؤال/أسئلة دون إجابة.')),
      );
      return;
    }
    _submitting = true;
    _timer?.cancel();

    var score = 0;
    final wrong = <MistakeRecord>[];
    final attempts = <QuestionAttemptRecord>[];
    final now = DateTime.now();
    for (var i = 0; i < widget.exam.questions.length; i++) {
      final question = widget.exam.questions[i];
      final selected = _answers[i];
      final isCorrect = selected == question.correctIndex;
      attempts.add(
        QuestionAttemptRecord(
          questionId: question.id.isEmpty ? '${widget.exam.title}-$i' : question.id,
          examTitle: widget.exam.title,
          examType: widget.exam.examType,
          subject: question.subject.isEmpty ? widget.exam.subject : question.subject,
          unit: question.unit,
          lesson: question.lesson,
          skill: question.skill,
          difficulty: question.difficulty,
          isCorrect: isCorrect,
          selectedIndex: selected,
          correctIndex: question.correctIndex,
          responseSeconds: _responseSeconds[i],
          completedAt: now,
          sourceLabel: question.sourceLabel,
          curriculumYear: question.curriculumYear,
          verifiedFromOfficialCurriculum: question.verifiedFromOfficialCurriculum,
        ),
      );
      if (isCorrect) {
        score++;
      } else {
        wrong.add(
          MistakeRecord(
            questionId: question.id.isEmpty ? '${widget.exam.title}-$i' : question.id,
            examTitle: widget.exam.title,
            subject: question.subject.isEmpty ? widget.exam.subject : question.subject,
            unit: question.unit,
            lesson: question.lesson,
            difficulty: question.difficulty,
            questionText: question.text,
            selectedOption: selected == null ? 'لم تتم الإجابة' : question.options[selected],
            correctOption: question.options[question.correctIndex],
            explanation: question.explanation,
            completedAt: now,
            skill: question.skill,
            sourceLabel: question.sourceLabel,
            curriculumYear: question.curriculumYear,
            verifiedFromOfficialCurriculum:
                question.verifiedFromOfficialCurriculum,
            errorType: classifyErrorType(question.skill),
          ),
        );
      }
    }

    await widget.controller.addExamResult(
      ExamResultRecord(
        examTitle: widget.exam.title,
        subject: widget.exam.subject,
        score: score,
        total: widget.exam.questions.length,
        completedAt: now,
        examType: widget.exam.examType,
      ),
    );
    await widget.controller.addMistakes(wrong);
    await widget.controller.addQuestionAttempts(attempts);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdaptiveResultScreen(
          controller: widget.controller,
          exam: widget.exam,
          answers: _answers,
          score: score,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        actions: [
          if (widget.timed)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(_timeText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.exam.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.exam.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: FilledButton.icon(
                onPressed: _submitting ? null : () => _submit(),
                icon: const Icon(Icons.check_circle_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('إنهاء الاختبار'),
                ),
              ),
            );
          }
          final question = widget.exam.questions[index];
          return QuestionCardV13(
            number: index + 1,
            question: question,
            selectedIndex: _answers[index],
            showDifficulty: true,
            onSelected: (value) => _recordAnswer(index, value),
          );
        },
      ),
    );
  }
}

class AdaptiveResultScreen extends StatelessWidget {
  const AdaptiveResultScreen({
    super.key,
    required this.controller,
    required this.exam,
    required this.answers,
    required this.score,
  });

  final AppController controller;
  final ExamDefinition exam;
  final List<int?> answers;
  final int score;

  @override
  Widget build(BuildContext context) {
    final percentage = exam.questions.isEmpty ? 0 : (score / exam.questions.length * 100).round();
    final isProfileSubject = controller.profile?.subjects.contains(exam.subject) ?? false;
    final recommendation = isProfileSubject
        ? controller.recommendationAfterExam(exam.subject, percentage)
        : controller.nextRecommendation;

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة والتوصية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.insights,
                    size: 64,
                    color: percentage >= 70 ? Colors.amber.shade700 : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text('$percentage%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  Text('$score من ${exam.questions.length} إجابة صحيحة'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text('توصية مُوَجِّه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(recommendation.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(recommendation.message, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MistakesScreen(controller: controller)),
                          );
                        },
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('سجل الأخطاء'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(title: const Text('الخطة الذكية')),
                                body: SmartPlanScreen(controller: controller),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.event_note_outlined),
                        label: const Text('الخطة الذكية'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('التصحيح', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(exam.questions.length, (index) {
            final question = exam.questions[index];
            final selected = answers[index];
            final correct = selected == question.correctIndex;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${index + 1}. ${question.text}', style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('إجابتك: ${selected == null ? 'لم تتم الإجابة' : question.options[selected]}'),
                    if (!correct)
                      Text('الصحيح: ${question.options[question.correctIndex]}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 7),
                    Text(question.explanation, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _V4EmptyState extends StatelessWidget {
  const _V4EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}
