import 'dart:async';

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'v11_engine.dart';
import 'v13_question_card.dart';

class MinisterialMockSetupScreenV11 extends StatefulWidget {
  const MinisterialMockSetupScreenV11({super.key, required this.controller});
  final AppController controller;

  @override
  State<MinisterialMockSetupScreenV11> createState() => _MinisterialMockSetupScreenV11State();
}

class _MinisterialMockSetupScreenV11State extends State<MinisterialMockSetupScreenV11> {
  String _subject = 'اللغة الإنجليزية';
  late int _minutes = ministerial2026Profiles[_subject]!.defaultMinutes;

  void _changeSubject(String value) {
    setState(() {
      _subject = value;
      _minutes = ministerial2026Profiles[value]!.defaultMinutes;
    });
  }

  void _start() {
    try {
      final built = MinisterialMockEngine.build(subject: _subject, durationMinutes: _minutes);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MinisterialQuizScreenV11(
            controller: widget.controller,
            exam: built.exam,
            profile: built.profile,
          ),
        ),
      );
    } on StateError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ministerial2026Profiles[_subject]!;
    final stats = MinisterialMockEngine.poolStats(_subject);
    return Scaffold(
      appBar: AppBar(title: const Text('محاكاة وزارية 2026')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نمط جيل 2008', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    '50 فقرة اختيار من متعدد. كل سؤال يقيس محتوى أو مهارة من المنهاج الرسمي. '
                    '40 فقرة مرتبطة مباشرة بمحتوى الكتاب، و10 فقرات نقل وفهم تستخدم سياقات أو أرقامًا جديدة.',
                    style: TextStyle(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(labelText: 'المبحث'),
            items: v11MinisterialSubjects
                .map((s) => DropdownMenuItem(value: s, child: Text(ministerial2026Profiles[s]!.displayName)))
                .toList(),
            onChanged: (value) {
              if (value != null) _changeSubject(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _minutes,
            decoration: InputDecoration(labelText: 'الوقت', helperText: profile.timeStatus),
            items: const [120, 150, 180]
                .map((e) => DropdownMenuItem(value: e, child: Text('$e دقيقة')))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _minutes = value);
            },
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 120, label: Text('120 د')),
              ButtonSegment(value: 150, label: Text('150 د')),
              ButtonSegment(value: 180, label: Text('180 د')),
            ],
            selected: {_minutes},
            onSelectionChanged: (v) => setState(() => _minutes = v.first),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('بصمة امتحان 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(profile.styleSummary, style: const TextStyle(height: 1.55)),
                  const Divider(height: 26),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.difficultyTargets.entries
                        .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('من الكتاب الرسمي'),
                  subtitle: Text('${stats['book']} سؤالًا متاحًا • سيختار الامتحان 40'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.psychology_alt_outlined),
                  title: const Text('نقل وفهم'),
                  subtitle: Text('${stats['transfer']} سؤالًا متاحًا • سيختار الامتحان 10'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'تنبيه: هذه محاكاة تدريبية مبنية على الكتب الرسمية وبصمة امتحانات 2026، وليست نسخة من ورقة الوزارة ولا تدّعي أن الأسئلة الخارجية وردت حرفيًا في الكتاب.',
                style: TextStyle(height: 1.55),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: (stats['book'] ?? 0) >= 40 && (stats['transfer'] ?? 0) >= 10 ? _start : null,
            icon: const Icon(Icons.play_circle_outline),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ابدأ محاكاة الـ50 سؤالًا', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}

class MinisterialQuizScreenV11 extends StatefulWidget {
  const MinisterialQuizScreenV11({
    super.key,
    required this.controller,
    required this.exam,
    required this.profile,
  });

  final AppController controller;
  final ExamDefinition exam;
  final MinisterialStyleProfile profile;

  @override
  State<MinisterialQuizScreenV11> createState() => _MinisterialQuizScreenV11State();
}

class _MinisterialQuizScreenV11State extends State<MinisterialQuizScreenV11> {
  late final List<int?> _answers;
  late final List<int> _responseSeconds;
  late final List<DateTime?> _questionStartedAt;
  late int _remainingSeconds;
  Timer? _timer;
  bool _submitting = false;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.exam.questions.length, null);
    _responseSeconds = List<int>.filled(widget.exam.questions.length, 0);
    _questionStartedAt = List<DateTime?>.filled(widget.exam.questions.length, null);
    _remainingSeconds = widget.exam.durationMinutes * 60;
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeText {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _answer(int index, int value) {
    final now = DateTime.now();
    final started = _questionStartedAt[index] ?? now;
    _responseSeconds[index] = now.difference(started).inSeconds.clamp(1, 600).toInt();
    setState(() => _answers[index] = value);
  }

  Future<void> _submit({bool force = false}) async {
    if (_submitting) return;
    final unanswered = _answers.where((a) => a == null).length;
    if (!force && unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بقي $unanswered سؤالًا دون إجابة.')));
      return;
    }
    _submitting = true;
    _timer?.cancel();

    var score = 0;
    final mistakes = <MistakeRecord>[];
    final attempts = <QuestionAttemptRecord>[];
    final now = DateTime.now();

    for (var i = 0; i < widget.exam.questions.length; i++) {
      final q = widget.exam.questions[i];
      final selected = _answers[i];
      final correct = selected == q.correctIndex;
      if (correct) score++;
      attempts.add(QuestionAttemptRecord(
        questionId: q.id,
        examTitle: widget.exam.title,
        examType: widget.exam.examType,
        subject: q.subject,
        unit: q.unit,
        lesson: q.lesson,
        skill: q.skill,
        difficulty: q.difficulty,
        isCorrect: correct,
        selectedIndex: selected,
        correctIndex: q.correctIndex,
        responseSeconds: _responseSeconds[i],
        completedAt: now,
        sourceLabel: q.sourceLabel,
        curriculumYear: q.curriculumYear,
        verifiedFromOfficialCurriculum: q.verifiedFromOfficialCurriculum,
      ));
      if (!correct) {
        mistakes.add(MistakeRecord(
          questionId: q.id,
          examTitle: widget.exam.title,
          subject: q.subject,
          unit: q.unit,
          lesson: q.lesson,
          difficulty: q.difficulty,
          questionText: q.text,
          selectedOption: selected == null ? 'لم تتم الإجابة' : q.options[selected],
          correctOption: q.options[q.correctIndex],
          explanation: q.explanation,
          completedAt: now,
          skill: q.skill,
          sourceLabel: q.sourceLabel,
          curriculumYear: q.curriculumYear,
          verifiedFromOfficialCurriculum: true,
          errorType: classifyErrorType(q.skill),
        ));
      }
    }

    await widget.controller.addExamResult(ExamResultRecord(
      examTitle: widget.exam.title,
      subject: widget.exam.subject,
      score: score,
      total: widget.exam.questions.length,
      completedAt: now,
      examType: 'ministerial_2026',
    ));
    await widget.controller.addMistakes(mistakes);
    await widget.controller.addQuestionAttempts(attempts);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MinisterialResultScreenV11(
        controller: widget.controller,
        exam: widget.exam,
        answers: _answers,
        score: score,
      ),
    ));
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= widget.exam.questions.length) return;
    _questionStartedAt[index] ??= DateTime.now();
    setState(() => _currentQuestionIndex = index);
  }

  void _openQuestionMap() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final answered = _answers.where((a) => a != null).length;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خريطة الأسئلة • $answered/${widget.exam.questions.length} مجاب', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 360,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.exam.questions.length,
                    itemBuilder: (_, index) {
                      final isAnswered = _answers[index] != null;
                      final current = index == _currentQuestionIndex;
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _goToQuestion(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: current
                                ? Theme.of(context).colorScheme.primary
                                : isAnswered
                                    ? Theme.of(context).colorScheme.secondaryContainer
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: current ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.exam.questions.length;
    final answered = _answers.where((a) => a != null).length;
    final index = _currentQuestionIndex.clamp(0, total - 1).toInt();
    final q = widget.exam.questions[index];
    _questionStartedAt[index] ??= DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(_timeText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          ),
          IconButton(
            tooltip: 'خريطة الأسئلة',
            onPressed: _openQuestionMap,
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('السؤال ${index + 1} من $total', style: const TextStyle(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('$answered مجاب', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 7,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              child: QuestionCardV13(
                number: index + 1,
                question: q,
                selectedIndex: _answers[index],
                onSelected: (value) => _answer(index, value),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: index == 0 ? null : () => _goToQuestion(index - 1),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('السابق'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: index == total - 1
                        ? FilledButton.icon(
                            onPressed: _submitting ? null : () => _submit(),
                            icon: const Icon(Icons.check_circle_outline_rounded),
                            label: Text(answered == total ? 'تسليم الامتحان' : 'راجع ثم سلّم'),
                          )
                        : FilledButton.icon(
                            onPressed: () => _goToQuestion(index + 1),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('التالي'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class MinisterialResultScreenV11 extends StatelessWidget {
  const MinisterialResultScreenV11({
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

  Map<String, List<int>> _sourceScores() {
    final result = <String, List<int>>{
      'من الكتاب': [0, 0],
      'نقل وفهم': [0, 0],
    };
    for (var i = 0; i < exam.questions.length; i++) {
      final q = exam.questions[i];
      final key = q.isTransferQuestion ? 'نقل وفهم' : 'من الكتاب';
      result[key]![1]++;
      if (answers[i] == q.correctIndex) result[key]![0]++;
    }
    return result;
  }

  Map<String, List<int>> _difficultyScores() {
    final result = <String, List<int>>{};
    for (var i = 0; i < exam.questions.length; i++) {
      final q = exam.questions[i];
      result.putIfAbsent(q.difficulty, () => [0, 0]);
      result[q.difficulty]![1]++;
      if (answers[i] == q.correctIndex) result[q.difficulty]![0]++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (score / exam.questions.length * 100).round();
    final source = _sourceScores();
    final diff = _difficultyScores();
    final transferPct = source['نقل وفهم']![1] == 0 ? 0 : (source['نقل وفهم']![0] / source['نقل وفهم']![1] * 100).round();
    final bookPct = (source['من الكتاب']![0] / source['من الكتاب']![1] * 100).round();
    final insight = transferPct + 10 < bookPct
        ? 'فهمك داخل سياق الكتاب أفضل من قدرتك على نقل الفكرة إلى موقف جديد؛ أعطِ أولوية لأسئلة التطبيق والاستنتاج.'
        : transferPct >= bookPct
            ? 'قدرتك على نقل الفهم إلى سياقات جديدة جيدة مقارنة بأدائك في أسئلة الكتاب.'
            : 'أداؤك متوازن بين أسئلة الكتاب وأسئلة نقل الفهم.';

    return Scaffold(
      appBar: AppBar(title: const Text('تقرير المحاكاة الوزارية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('$pct%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  Text('$score من ${exam.questions.length}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(exam.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('هل تفهم أم تحفظ السياق؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ScoreCard(title: 'من الكتاب', score: source['من الكتاب']![0], total: source['من الكتاب']![1], icon: Icons.menu_book_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _ScoreCard(title: 'نقل وفهم', score: source['نقل وفهم']![0], total: source['نقل وفهم']![1], icon: Icons.psychology_alt_outlined)),
            ],
          ),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(insight, style: const TextStyle(height: 1.6)))),
          const SizedBox(height: 12),
          const Text('الأداء حسب الصعوبة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...['سهل', 'متوسط', 'صعب', 'متقدم'].where(diff.containsKey).map((d) {
            final v = diff[d]!;
            final p = v[1] == 0 ? 0 : (v[0] / v[1] * 100).round();
            return Card(child: ListTile(
              title: Text(d),
              subtitle: LinearProgressIndicator(value: p / 100),
              trailing: Text('${v[0]}/${v[1]} • $p%'),
            ));
          }),
          const SizedBox(height: 12),
          const Text('مراجعة الأخطاء', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...List.generate(exam.questions.length, (i) {
            final q = exam.questions[i];
            if (answers[i] == q.correctIndex) return const SizedBox.shrink();
            return Card(
              child: ExpansionTile(
                leading: Icon(q.isTransferQuestion ? Icons.psychology_alt_outlined : Icons.menu_book_outlined),
                title: Text('${i + 1}. ${q.text}', maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${q.unit} • ${q.lesson} • ${q.difficulty}'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(alignment: Alignment.centerRight, child: Text('الإجابة الصحيحة: ${q.options[q.correctIndex]}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: Text(q.explanation, style: const TextStyle(height: 1.5))),
                  if (q.sourceReference.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: Text('مرجع المهارة: ${q.sourceReference}', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.title, required this.score, required this.total, required this.icon});
  final String title;
  final int score;
  final int total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (score / total * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$pct%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text('$score/$total'),
          ],
        ),
      ),
    );
  }
}
