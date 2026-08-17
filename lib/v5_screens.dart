import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'curriculum_data.dart';
import 'v6_curriculum_data.dart';
import 'models.dart';
import 'v4_screens.dart';

class CurriculumLibraryScreen extends StatefulWidget {
  const CurriculumLibraryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CurriculumLibraryScreen> createState() => _CurriculumLibraryScreenState();
}

class _CurriculumLibraryScreenState extends State<CurriculumLibraryScreen> {
  String _subject = 'اللغة الإنجليزية';

  List<String> get _subjects => curriculumSources.map((s) => s.subject).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final source = curriculumSources.firstWhere((s) => s.subject == _subject);
    final units = allUnitsForSubject(_subject);
    final verifiedQuestions = allCurriculumQuestions
        .where((q) => q.subject == _subject && q.verifiedFromOfficialCurriculum)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('المناهج الرسمية')),
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
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.verified_outlined, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'اعتماد المنهاج الرسمي',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'يعرض مُوَجِّه هنا بنية الكتب المعتمدة للصف الثاني عشر. لا تُصنّف الأسئلة على أنها مرتبطة بالمنهاج إلا إذا رُبطت بوحدة ودرس تم التحقق منهما من المصدر الرسمي. الأسئلة نفسها مُنشأة داخل التطبيق وليست أسئلة وزارية رسمية.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Chip(label: Text('2026-2027')),
                      Chip(label: Text('$allVerifiedCurriculumQuestionCount سؤالاً مُنشأً وفق المنهاج')),
                      const Chip(label: Text('الفصل الأول')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(
              labelText: 'المبحث',
              prefixIcon: Icon(Icons.menu_book_outlined),
            ),
            items: _subjects
                .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _subject = value);
            },
          ),
          const SizedBox(height: 14),
          _SourceCard(source: source, questionCount: verifiedQuestions.length),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text('الوحدات والدروس', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              ),
              Text('${units.length} وحدة'),
            ],
          ),
          const SizedBox(height: 8),
          if (units.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'الكتاب مدرج في المصدر الرسمي، ولم تُستكمل فهرسة وحداته داخل هذه النسخة بعد. لذلك لن ينسب التطبيق أي سؤال لهذا الكتاب على أنه متحقق حتى تكتمل الفهرسة.',
                  style: TextStyle(height: 1.6),
                ),
              ),
            )
          else
            ...units.map((unit) {
              final count = allCurriculumQuestions
                  .where((q) => q.subject == unit.subject && q.unit == unit.title)
                  .length;
              return _CurriculumUnitCard(
                unit: unit,
                questionCount: count,
                onPractice: count == 0 ? null : () => _startUnitPractice(unit),
              );
            }),
        ],
      ),
    );
  }

  void _startUnitPractice(CurriculumUnit unit) {
    final pool = allCurriculumQuestions
        .where((q) => q.subject == unit.subject && q.unit == unit.title)
        .toList()
      ..shuffle(math.Random());
    if (pool.isEmpty) return;

    final exam = ExamDefinition(
      title: '${unit.subject} - ${unit.title}',
      subtitle: 'تدريب مُنشأ وفق بنية المنهاج الرسمي المفهرس $currentCurriculumYear.',
      subject: unit.subject,
      unit: unit.title,
      difficulty: 'متنوع',
      durationMinutes: math.max(8, pool.length * 2),
      examType: 'official_curriculum',
      icon: Icons.verified,
      questions: pool,
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
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source, required this.questionCount});

  final CurriculumSource source;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final isIndexed = source.status.contains('مفهرس');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(source.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                const SizedBox(width: 8),
                Icon(
                  isIndexed ? Icons.verified : Icons.schedule_outlined,
                  color: isIndexed ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${source.publisher} • ${source.semester} • ${source.academicYear}'),
            const SizedBox(height: 8),
            Text(source.note, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(source.status)),
                if (isIndexed) Chip(label: Text('$questionCount سؤال مرتبط بالمنهاج')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurriculumUnitCard extends StatelessWidget {
  const _CurriculumUnitCard({
    required this.unit,
    required this.questionCount,
    required this.onPractice,
  });

  final CurriculumUnit unit;
  final int questionCount;
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${unit.number}')),
        title: Text(unit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${unit.lessons.length} محاور • $questionCount أسئلة مرتبطة بالمنهاج'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ...unit.lessons.map(
            (lesson) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline, size: 20),
              title: Text(lesson),
            ),
          ),
          if (onPractice != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onPractice,
                icon: const Icon(Icons.play_arrow),
                label: const Text('ابدأ تدريب هذه الوحدة'),
              ),
            ),
        ],
      ),
    );
  }
}

class OfficialQuestionInfoSheet extends StatelessWidget {
  const OfficialQuestionInfoSheet({super.key, required this.question});

  final ExamQuestion question;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بيانات السؤال', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _info('المبحث', question.subject),
            _info('الوحدة', question.unit),
            _info('الدرس', question.lesson),
            _info('المهارة', question.skill),
            _info('الصعوبة', question.difficulty),
            _info('المصدر', question.sourceLabel),
            _info('العام الدراسي', question.curriculumYear.isEmpty ? 'غير محدد' : question.curriculumYear),
            _info('حالة التحقق', question.verifiedFromOfficialCurriculum ? 'متحقق من بنية المنهاج الرسمي' : 'سؤال تجريبي'),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('$label: $value'),
      );
}
