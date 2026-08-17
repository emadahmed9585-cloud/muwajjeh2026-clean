import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'exam_data.dart';
import 'models.dart';

typedef LearningExamLauncher = void Function(
  BuildContext context,
  ExamDefinition exam,
);

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({
    super.key,
    required this.controller,
    required this.launchExam,
  });

  final AppController controller;
  final LearningExamLauncher launchExam;

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  bool _busy = false;

  Future<void> _startPath() async {
    setState(() => _busy = true);
    final path = await widget.controller.startLearningPathFromWeakestSkill();
    if (!mounted) return;
    setState(() => _busy = false);
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل اختبارًا أولًا حتى يحدد مُوَجِّه مهارة تحتاج إلى مسار علاجي.'),
        ),
      );
    }
  }

  List<ExamQuestion> _questionsForPath(
    LearningPathRecord path, {
    required bool checkpoint,
  }) {
    final exactSkill = allBankQuestions.where((q) =>
        q.subject == path.subject &&
        q.unit == path.unit &&
        q.lesson == path.lesson &&
        q.skill == path.skill);
    final exactLesson = allBankQuestions.where((q) =>
        q.subject == path.subject &&
        q.unit == path.unit &&
        q.lesson == path.lesson);
    final sameUnit = allBankQuestions.where(
      (q) => q.subject == path.subject && q.unit == path.unit,
    );
    final sameSubject = allBankQuestions.where((q) => q.subject == path.subject);

    final merged = <ExamQuestion>[];
    final seen = <String>{};
    void add(Iterable<ExamQuestion> source) {
      for (final q in source) {
        final key = q.id.isEmpty ? '${q.subject}|${q.unit}|${q.lesson}|${q.text}' : q.id;
        if (seen.add(key)) merged.add(q);
      }
    }

    add(exactSkill);
    add(exactLesson);
    add(sameUnit);
    add(sameSubject);

    final preferred = merged.where((q) {
      if (checkpoint) {
        return q.difficulty == 'متوسط' ||
            q.difficulty == 'صعب' ||
            q.difficulty == 'متقدم';
      }
      return q.difficulty == 'سهل' || q.difficulty == 'متوسط';
    }).toList();

    final pool = <ExamQuestion>[];
    final poolSeen = <String>{};
    for (final q in [...preferred, ...merged]) {
      final key = q.id.isEmpty ? q.text : q.id;
      if (poolSeen.add(key)) pool.add(q);
    }

    pool.shuffle(math.Random(DateTime.now().millisecondsSinceEpoch));
    return pool.take(math.min(5, pool.length)).toList();
  }

  void _launchPractice(LearningPathRecord path, {required bool checkpoint}) {
    final questions = _questionsForPath(path, checkpoint: checkpoint);
    if (questions.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أسئلة مستهدفة كافية لهذه المهارة حاليًا.')),
      );
      return;
    }

    final exam = ExamDefinition(
      title: checkpoint
          ? 'اختبار تحقق • ${path.skill} • ${path.id}'
          : 'تدريب تأسيسي • ${path.skill} • ${path.id}',
      subtitle: checkpoint
          ? 'تحقق قصير قبل الانتقال للمستوى التالي.'
          : 'تدريب علاجي مركز على الدرس والمهارة.',
      subject: path.subject,
      icon: checkpoint ? Icons.verified_outlined : Icons.fitness_center_outlined,
      questions: questions,
      unit: path.unit,
      difficulty: checkpoint ? 'تكيفي' : 'تأسيسي',
      durationMinutes: checkpoint ? 10 : 12,
      examType: checkpoint ? 'learning_checkpoint' : 'learning_foundation',
    );
    widget.launchExam(context, exam);
  }

  MistakeRecord? _latestMatchingMistake(LearningPathRecord path) {
    for (final mistake in widget.controller.mistakes) {
      if (mistake.subject == path.subject &&
          mistake.unit == path.unit &&
          mistake.lesson == path.lesson) {
        return mistake;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final path = widget.controller.activeLearningPath;
        if (path == null) {
          final target = widget.controller.nextLearningPathTarget;
          return Scaffold(
            appBar: AppBar(title: const Text('مساري الشخصي V9')),
            body: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const _IntroCard(),
                const SizedBox(height: 14),
                if (target == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'لا توجد بيانات كافية لإنشاء مسار بعد. أكمل اختبارًا من بنك الأسئلة أو الاختبار التكيفي أولًا.',
                        style: TextStyle(height: 1.6),
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('المسار المقترح', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text('${target.subject} ← ${target.unit} ← ${target.lesson}'),
                          const SizedBox(height: 5),
                          Text('المهارة: ${target.skill}'),
                          const SizedBox(height: 5),
                          Text('الإتقان الحالي: ${target.score.round()}%'),
                          const SizedBox(height: 10),
                          Text(target.reason, style: const TextStyle(height: 1.5)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _busy ? null : _startPath,
                            icon: const Icon(Icons.route_outlined),
                            label: Text(_busy ? 'جارٍ الإنشاء...' : 'أنشئ مساري الآن'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        final snapshot = widget.controller.snapshotForLearningPath(path);
        final mistake = _latestMatchingMistake(path);
        final improvement = snapshot.currentMastery.score - path.baselineMastery;

        return Scaffold(
          appBar: AppBar(title: const Text('مساري الشخصي V9')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Icon(snapshot.isCompleted ? Icons.emoji_events_outlined : Icons.route_outlined),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(path.skill, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                                Text('${path.subject} • ${path.unit} • ${path.lesson}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(value: (snapshot.stage / 4).clamp(0.0, 1.0).toDouble(), minHeight: 9),
                      const SizedBox(height: 8),
                      Text('المرحلة الحالية: ${snapshot.stageLabel}'),
                      const SizedBox(height: 4),
                      Text(
                        'الإتقان: ${path.baselineMastery.round()}% ← ${snapshot.currentMastery.score.round()}%'
                        '${improvement > 0 ? '  (+${improvement.round()})' : ''}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PathStepCard(
                number: 1,
                title: 'فهم المفهوم',
                subtitle: 'راجع القاعدة أو المفهوم من كتابك الرسمي، ثم افهم سبب آخر خطأ مرتبط بالدرس.',
                state: path.conceptReviewed ? _StepState.done : _StepState.active,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mistake != null) ...[
                      const Text('من آخر خطأ مسجل:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(mistake.explanation, style: const TextStyle(height: 1.5)),
                      const SizedBox(height: 10),
                    ],
                    const Text('قائمة المراجعة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('• حدّد القاعدة أو الفكرة الأساسية.\n• افهم مثالًا محلولًا واحدًا على الأقل.\n• اكتب سبب الخطأ السابق بكلماتك.\n• لا تنتقل للتدريب قبل أن تستطيع شرح الفكرة باختصار.'),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => widget.controller.markLearningConceptReviewed(path.id, !path.conceptReviewed),
                      icon: Icon(path.conceptReviewed ? Icons.undo : Icons.check),
                      label: Text(path.conceptReviewed ? 'إلغاء علامة المراجعة' : 'أتممت فهم المفهوم'),
                    ),
                  ],
                ),
              ),
              _PathStepCard(
                number: 2,
                title: 'تدريب تأسيسي',
                subtitle: '5 أسئلة مستهدفة. المطلوب 60% على الأقل لفتح التحقق.',
                state: !path.conceptReviewed
                    ? _StepState.locked
                    : (snapshot.foundationAttempts >= 5 && snapshot.foundationPercentage >= 60)
                        ? _StepState.done
                        : _StepState.active,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('آخر دورة: ${snapshot.foundationCorrect}/${snapshot.foundationAttempts} صحيحة (${snapshot.foundationPercentage}%).'),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: !path.conceptReviewed ? null : () => _launchPractice(path, checkpoint: false),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(snapshot.foundationAttempts == 0 ? 'ابدأ 5 أسئلة تأسيسية' : 'أعد التدريب التأسيسي'),
                    ),
                  ],
                ),
              ),
              _PathStepCard(
                number: 3,
                title: 'اختبار تحقق',
                subtitle: '5 أسئلة أعلى مستوى. معيار الاجتياز 80% حتى نعتبر المهارة مستقرة.',
                state: snapshot.isCompleted
                    ? _StepState.done
                    : snapshot.needsRemediation
                        ? _StepState.warning
                        : (path.conceptReviewed && snapshot.foundationAttempts >= 5 && snapshot.foundationPercentage >= 60)
                            ? _StepState.active
                            : _StepState.locked,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('آخر تحقق: ${snapshot.checkpointCorrect}/${snapshot.checkpointAttempts} صحيحة (${snapshot.checkpointPercentage}%).'),
                    if (snapshot.needsRemediation) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'لم يتحقق معيار 80%. راجع تفسير الأخطاء، نفّذ تدريبًا علاجيًا آخر، ثم أعد اختبار التحقق.',
                        style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
                      ),
                    ],
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: path.conceptReviewed &&
                              snapshot.foundationAttempts >= 5 &&
                              snapshot.foundationPercentage >= 60
                          ? () => _launchPractice(path, checkpoint: true)
                          : null,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(snapshot.checkpointAttempts == 0 ? 'ابدأ اختبار التحقق' : 'أعد اختبار التحقق'),
                    ),
                  ],
                ),
              ),
              _PathStepCard(
                number: 4,
                title: 'الانتقال أو إعادة العلاج',
                subtitle: snapshot.isCompleted
                    ? 'تم اجتياز المسار. يمكنك الانتقال إلى أضعف مهارة تالية.'
                    : 'يقرر مُوَجِّه الخطوة بناءً على نتيجة التحقق، لا على إكمال الأنشطة فقط.',
                state: snapshot.isCompleted ? _StepState.done : _StepState.locked,
                child: snapshot.isCompleted
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أحسنت. اجتزت التحقق بنسبة ${snapshot.checkpointPercentage}%، ودرجة الإتقان الحالية ${snapshot.currentMastery.score.round()}%.',
                            style: const TextStyle(height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              await widget.controller.archiveLearningPath(path.id);
                              await widget.controller.startLearningPathFromWeakestSkill();
                            },
                            icon: const Icon(Icons.skip_next),
                            label: const Text('انتقل إلى المهارة التالية'),
                          ),
                        ],
                      )
                    : const Text('ستفتح هذه المرحلة بعد اجتياز اختبار التحقق بنسبة 80% أو أكثر.'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => widget.controller.archiveLearningPath(path.id),
                icon: const Icon(Icons.archive_outlined),
                label: const Text('أرشفة هذا المسار'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Path V9', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'يحوّل مُوَجِّه أضعف مهارة لديك إلى مسار قصير قابل للقياس: فهم → تدريب → تحقق → انتقال أو إعادة علاج.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { locked, active, done, warning }

class _PathStepCard extends StatelessWidget {
  const _PathStepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.child,
  });

  final int number;
  final String title;
  final String subtitle;
  final _StepState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (state) {
      case _StepState.done:
        icon = Icons.check_circle;
        break;
      case _StepState.warning:
        icon = Icons.warning_amber_rounded;
        break;
      case _StepState.locked:
        icon = Icons.lock_outline;
        break;
      case _StepState.active:
        icon = Icons.radio_button_checked;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('$number')),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(icon),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
