import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'v10_engine.dart';
import 'v12_tutor_content.dart';
import 'v13_sources.dart';
import 'v13_theme.dart';

typedef V10ExamLauncher = void Function(BuildContext context, ExamDefinition exam);

class SmartTutorScreen extends StatefulWidget {
  const SmartTutorScreen({
    super.key,
    required this.controller,
    required this.launchExam,
  });

  final AppController controller;
  final V10ExamLauncher launchExam;

  @override
  State<SmartTutorScreen> createState() => _SmartTutorScreenState();
}

class _SmartTutorScreenState extends State<SmartTutorScreen> {
  bool _busy = false;

  Future<void> _startPath() async {
    setState(() => _busy = true);
    final path = await widget.controller.startLearningPathFromWeakestSkill();
    if (!mounted) return;
    setState(() => _busy = false);
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مهارة منخفضة بما يكفي لإنشاء علاج ذكي الآن.')),
      );
    }
  }

  void _launchRemedial(LearningPathRecord path) {
    final engine = V10TutorEngine(widget.controller);
    final exam = engine.buildRemedialExam(path);
    if (exam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أسئلة علاجية كافية لهذه المهارة حاليًا.')),
      );
      return;
    }
    widget.launchExam(context, exam);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final engine = V10TutorEngine(widget.controller);
        final path = widget.controller.activeLearningPath;
        if (path == null) {
          final target = widget.controller.nextLearningPathTarget;
          return Scaffold(
            appBar: AppBar(title: const Text('المعلم الذكي')),
            body: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const _TutorIntro(),
                const SizedBox(height: 14),
                if (target == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'لا توجد مهارة علاجية محددة حاليًا. أكمل اختبارًا جديدًا لتكوين بيانات أدق، أو افتح خريطة التقدم لمعرفة الأجزاء غير المقاسة.',
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
                          const Text('أفضل نقطة بداية الآن', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text('${target.subject} ← ${target.unit} ← ${target.lesson}'),
                          const SizedBox(height: 6),
                          Text('المهارة: ${target.skill}'),
                          const SizedBox(height: 6),
                          Text('الإتقان الحالي: ${target.score.round()}%'),
                          const SizedBox(height: 10),
                          Text(target.reason, style: const TextStyle(height: 1.5)),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _busy ? null : _startPath,
                            icon: const Icon(Icons.psychology_alt_outlined),
                            label: Text(_busy ? 'جارٍ التحليل...' : 'ابدأ العلاج الذكي'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        final advice = engine.adviceForPath(path);
        final bookRef = bookReferenceFor(subject: path.subject, unit: path.unit, lesson: path.lesson);
        final beginner = beginnerLessonFor(advice);
        final snapshot = widget.controller.snapshotForLearningPath(path);
        final selected = engine.remedialQuestionsForPath(path, count: 5);

        return Scaffold(
          appBar: AppBar(title: const Text('المعلم الذكي')),
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
                          const CircleAvatar(child: Icon(Icons.psychology_alt_outlined)),
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
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(advice.errorType)),
                          Chip(label: Text('إتقان ${snapshot.currentMastery.score.round()}%')),
                          Chip(label: Text('ثقة ${snapshot.currentMastery.confidence.round()}%')),
                          Chip(label: Text('المستوى المقترح: ${advice.recommendedDifficulty}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _BookReferenceCard(reference: bookRef),
              const SizedBox(height: 12),
              _TutorSourcesCard(subject: path.subject),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school_outlined),
                          SizedBox(width: 8),
                          Text('الشرح للمبتدئ — نبدأ من الصفر', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(beginner.startFromZero, style: const TextStyle(height: 1.75, fontSize: 16)),
                      const SizedBox(height: 14),
                      _BeginnerBox(title: 'مثال شديد البساطة', icon: Icons.lightbulb_outline, text: beginner.simpleExample),
                      const SizedBox(height: 10),
                      _BeginnerBox(title: 'انتبه: هذا الخطأ شائع', icon: Icons.warning_amber_rounded, text: beginner.commonMistake),
                      const SizedBox(height: 10),
                      _BeginnerBox(title: 'احفظ الفكرة بهذه الطريقة', icon: Icons.memory_outlined, text: beginner.memoryTip),
                      const SizedBox(height: 10),
                      _BeginnerBox(title: 'تأكد أنك فهمت', icon: Icons.quiz_outlined, text: beginner.quickCheck),
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
                      Text(advice.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('التشخيص', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(advice.diagnosis, style: const TextStyle(height: 1.6)),
                      const SizedBox(height: 14),
                      const Text('شرح مصغر', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(advice.microLesson, style: const TextStyle(height: 1.6)),
                      if (advice.lastMistakeExplanation.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('من تفسير آخر خطأ لك', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(advice.lastMistakeExplanation, style: const TextStyle(height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _TutorListCard(
                title: 'طريقة الحل التي أريدك أن تتبعها',
                icon: Icons.format_list_numbered,
                items: advice.strategySteps,
              ),
              const SizedBox(height: 12),
              _TutorListCard(
                title: 'اسأل نفسك قبل تثبيت الإجابة',
                icon: Icons.help_outline,
                items: advice.selfCheckQuestions,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المجموعة العلاجية المقترحة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        selected.isEmpty
                            ? 'لا توجد أسئلة كافية لهذه المهارة بعد.'
                            : 'اخترت لك ${selected.length} أسئلة، مع إعطاء أولوية لنفس المهارة والدرس وتجنب الأسئلة الحديثة متى أمكن.',
                        style: const TextStyle(height: 1.5),
                      ),
                      if (selected.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ...selected.map(
                          (q) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text('• ${q.difficulty} • ${q.skill} • ${q.lesson}'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _launchRemedial(path),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('ابدأ العلاج المخصص'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.route_outlined)),
                  title: const Text('حالة المسار الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${snapshot.stageLabel} • البداية ${path.baselineMastery.round()}% ← الآن ${snapshot.currentMastery.score.round()}%'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TutorIntro extends StatelessWidget {
  const _TutorIntro();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعلم الذكي', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'يشرح من الصفر كما لو أنك طالب مبتدئ، ويرجع أولًا إلى الكتاب الرسمي، ثم يشرح الفكرة من الصفر بلغة بسيطة. عند الحاجة يستخدم مرجعًا تعليميًا موثوقًا لتقديم مثال إضافي، مع بقاء المنهاج الرسمي هو المرجع الحاكم.',
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}


class _BookReferenceCard extends StatelessWidget {
  const _BookReferenceCard({required this.reference});

  final BookPageReference reference;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book_outlined),
                SizedBox(width: 8),
                Expanded(child: Text('ارجع إلى الكتاب الرسمي', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 12),
            Text(reference.bookTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 7),
            Row(
              children: [
                const Text('رقم الصفحة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(reference.pageLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.primary)),
              ],
            ),
            const SizedBox(height: 5),
            Text('الدرس: ${reference.lesson}', style: const TextStyle(height: 1.45)),
            const SizedBox(height: 12),
            if (reference.hasImage) ...[
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => Dialog.fullscreen(
                      child: Scaffold(
                        appBar: AppBar(title: Text('صفحة ${reference.pageLabel}')),
                        body: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4,
                          child: Center(
                            child: Image.asset(
                              reference.assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _BookImagePlaceholder(reference: reference),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    reference.assetPath,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => _BookImagePlaceholder(reference: reference),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text('اضغط على صورة الصفحة للتكبير', style: TextStyle(fontSize: 12, color: MuwajjehPalette.muted)),
            ] else
              _BookImagePlaceholder(reference: reference),
            if (reference.note.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(reference.note, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookImagePlaceholder extends StatelessWidget {
  const _BookImagePlaceholder({required this.reference});

  final BookPageReference reference;

  @override
  Widget build(BuildContext context) {
    final verified = reference.hasVerifiedPage;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(verified ? Icons.image_outlined : Icons.fact_check_outlined, size: 38),
          const SizedBox(height: 8),
          Text(
            verified
                ? 'مكان صورة الصفحة الرسمية ${reference.pageLabel}'
                : 'صورة الصفحة ستظهر بعد مطابقة رقم الصفحة من نسخة 2026 الرسمية',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, height: 1.45),
          ),
          const SizedBox(height: 6),
          Text(
            verified
                ? 'يدعم مُوَجِّه إظهار صورة أو مقتطف مرخّص من الصفحة هنا. نسخة النشر لا تضمّن صور صفحات محمية تلقائيًا قبل التأكد من حق إعادة الاستخدام.'
                : reference.referenceStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}


class _TutorSourcesCard extends StatelessWidget {
  const _TutorSourcesCard({required this.subject});

  final String subject;

  @override
  Widget build(BuildContext context) {
    final sources = tutorSourcesFor(subject);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_outlined, color: MuwajjehPalette.teal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مصادر الشرح',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'الكتاب الرسمي أولًا. المراجع الأخرى تُستخدم فقط لتبسيط الفكرة أو إضافة مثال يخدم الفهم.',
              style: TextStyle(color: MuwajjehPalette.muted, height: 1.55),
            ),
            const SizedBox(height: 12),
            ...sources.map((source) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: source.primary ? MuwajjehPalette.tealSoft : const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MuwajjehPalette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        source.primary ? Icons.menu_book_rounded : Icons.auto_stories_outlined,
                        color: source.primary ? MuwajjehPalette.teal : MuwajjehPalette.navy,
                        size: 20,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(source.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(source.role, style: const TextStyle(color: MuwajjehPalette.teal, fontSize: 12, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(source.note, style: const TextStyle(height: 1.5, fontSize: 12.5, color: MuwajjehPalette.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _BeginnerBox extends StatelessWidget {
  const _BeginnerBox({required this.title, required this.icon, required this.text});

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(height: 1.65)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorListCard extends StatelessWidget {
  const _TutorListCard({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 10),
            ...items.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 11, child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.value, style: const TextStyle(height: 1.5))),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class CurriculumProgressMapScreen extends StatefulWidget {
  const CurriculumProgressMapScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CurriculumProgressMapScreen> createState() => _CurriculumProgressMapScreenState();
}

class _CurriculumProgressMapScreenState extends State<CurriculumProgressMapScreen> {
  String? _subject;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final engine = V10TutorEngine(widget.controller);
        final subjects = engine.subjectsWithCurriculum();
        if (subjects.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('خريطة التقدم V10')),
            body: const Center(child: Text('لا توجد مباحث مفهرسة حاليًا.')),
          );
        }
        final subject = _subject != null && subjects.contains(_subject) ? _subject! : subjects.first;
        final nodes = engine.progressNodesForSubject(subject);
        final timeline = engine.masteryTimelineForSubject(subject);
        final coverage = engine.coverageForSubject(subject);
        final measured = nodes.where((n) => n.isMeasured).toList();
        final mastered = measured.where((n) => n.score >= 80).length;
        final weak = measured.where((n) => n.score < 65).length;
        final units = <String, List<CurriculumProgressNode>>{};
        for (final node in nodes) {
          units.putIfAbsent(node.unit, () => []).add(node);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('خريطة التقدم V10')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('خريطة إتقان المنهاج', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                        'تظهر الخريطة كل درس ومهارة لها تدريب في البنك، بما في ذلك الأجزاء التي لم تُقَس بعد. النتيجة تتغير مع كل محاولة جديدة.',
                        style: TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: subject,
                        decoration: const InputDecoration(labelText: 'المبحث'),
                        items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) => setState(() => _subject = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ProgressStat(label: 'مقاس', value: '${coverage.x}/${coverage.y}', subtitle: 'مهارة/محور')),
                  const SizedBox(width: 8),
                  Expanded(child: _ProgressStat(label: 'متقن', value: '$mastered', subtitle: '80% فأعلى')),
                  const SizedBox(width: 8),
                  Expanded(child: _ProgressStat(label: 'أولوية', value: '$weak', subtitle: 'أقل من 65%')),
                ],
              ),
              const SizedBox(height: 14),
              if (timeline.isNotEmpty) ...[
                const Text('الإتقان عبر الزمن', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
                    child: SizedBox(height: 170, child: _TimelineBars(points: timeline)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('الوحدات والدروس', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...units.entries.map((entry) => _UnitProgressCard(unit: entry.key, nodes: entry.value)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('قراءة الخريطة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      SizedBox(height: 8),
                      Text('غير مقاس: لا توجد محاولة بعد • يحتاج تأسيس: أقل من 45% • قيد التطور: 45–64% • جيد: 65–79% • متقن: 80% فأعلى.'),
                      SizedBox(height: 6),
                      Text('سهم التحسن يعتمد على مقارنة المحاولات الأقدم بالأحدث عندما تتوفر 4 محاولات على الأقل.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value, required this.subtitle});

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _TimelineBars extends StatelessWidget {
  const _TimelineBars({required this.points});

  final List<MasteryTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final shown = points.length <= 8 ? points : points.sublist(points.length - 8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: shown.map((point) {
        final fraction = (point.score / 100).clamp(0.08, 1.0).toDouble();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${point.score.round()}%', style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction,
                      widthFactor: 0.72,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(point.label, style: const TextStyle(fontSize: 9)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnitProgressCard extends StatelessWidget {
  const _UnitProgressCard({required this.unit, required this.nodes});

  final String unit;
  final List<CurriculumProgressNode> nodes;

  @override
  Widget build(BuildContext context) {
    final measured = nodes.where((n) => n.isMeasured).toList();
    final score = measured.isEmpty
        ? 0.0
        : measured.map((n) => n.score).reduce((a, b) => a + b) / measured.length;
    final byLesson = <String, List<CurriculumProgressNode>>{};
    for (final node in nodes) {
      byLesson.putIfAbsent(node.lesson, () => []).add(node);
    }

    return Card(
      child: ExpansionTile(
        title: Text(unit, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(measured.isEmpty
            ? 'لم يبدأ القياس بعد'
            : 'متوسط الإتقان ${score.round()}% • ${measured.length}/${nodes.length} محور مقاس'),
        children: byLesson.entries.map((entry) {
          final lessonMeasured = entry.value.where((n) => n.isMeasured).toList();
          final lessonScore = lessonMeasured.isEmpty
              ? 0.0
              : lessonMeasured.map((n) => n.score).reduce((a, b) => a + b) / lessonMeasured.length;
          return ExpansionTile(
            title: Text(entry.key),
            subtitle: Text(lessonMeasured.isEmpty ? 'غير مقاس' : '${lessonScore.round()}%'),
            children: entry.value.map((node) => _SkillProgressTile(node: node)).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _SkillProgressTile extends StatelessWidget {
  const _SkillProgressTile({required this.node});

  final CurriculumProgressNode node;

  @override
  Widget build(BuildContext context) {
    final icon = !node.isMeasured
        ? Icons.radio_button_unchecked
        : node.score >= 80
            ? Icons.check_circle_outline
            : node.score < 65
                ? Icons.error_outline
                : Icons.timelapse;
    final trendIcon = node.attempts < 4 || node.trend.abs() < 2.5
        ? Icons.remove
        : node.trend > 0
            ? Icons.trending_up
            : Icons.trending_down;
    return ListTile(
      leading: Icon(icon),
      title: Text(node.skill),
      subtitle: Text(
        node.isMeasured
            ? '${node.score.round()}% • ثقة ${node.confidence.round()}% • ${node.attempts} محاولة • ${node.questionCount} سؤال بالبنك'
            : 'غير مقاس • ${node.questionCount} سؤال بالبنك',
      ),
      trailing: Tooltip(message: node.trendLabel, child: Icon(trendIcon)),
    );
  }
}
