import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'curriculum_data.dart';
import 'models.dart';
import 'v5_screens.dart';
import 'v6_curriculum_data.dart';

class CurriculumCoverageScreen extends StatelessWidget {
  const CurriculumCoverageScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final totalUnits = allCurriculumUnits.length;
    final coveredUnits = allCurriculumUnits.where((unit) {
      return allCurriculumQuestions.any(
        (q) => q.subject == unit.subject && q.unit == unit.title,
      );
    }).length;
    final totalLessons = allCurriculumUnits.fold<int>(
      0,
      (sum, unit) => sum + unit.lessons.length,
    );
    final coveredLessons = <String>{};
    for (final q in allCurriculumQuestions) {
      coveredLessons.add('${q.subject}|${q.unit}|${q.lesson}');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تغطية المنهاج V6')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.fact_check_outlined, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لوحة تحقق وتغطية المحتوى',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'يفصل التطبيق بين اعتماد وجود الكتاب رسميًا، وبين مستوى فهرسة وحداته ودروسه. الأسئلة تدريبية أصلية ومبنية على المهارات، وليست نسخًا من أسئلة الكتاب أو أسئلة وزارية.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('${curriculumSources.length} مباحث')),
                      Chip(label: Text('$totalUnits وحدة مفهرسة')),
                      Chip(label: Text('$coveredUnits وحدة لها تدريب')),
                      Chip(label: Text('$allVerifiedCurriculumQuestionCount سؤالًا مرتبطًا بالمنهاج')),
                      Chip(label: Text('$totalLessons محورًا/درسًا مفهرسًا')),
                      Chip(label: Text('${coveredLessons.length} محورًا له أسئلة')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...curriculumSources.map((source) {
            final units = allUnitsForSubject(source.subject);
            final questions = allCurriculumQuestions
                .where((q) => q.subject == source.subject)
                .toList();
            final totalSubjectLessons = units.fold<int>(
              0,
              (sum, unit) => sum + unit.lessons.length,
            );
            final subjectCoveredLessons = questions
                .map((q) => '${q.unit}|${q.lesson}')
                .toSet()
                .length;
            final coverage = totalSubjectLessons == 0
                ? 0.0
                : (subjectCoveredLessons / totalSubjectLessons)
                    .clamp(0.0, 1.0)
                    .toDouble();

            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CurriculumLibraryScreen(controller: controller),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text('${units.length}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.subject,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  source.status,
                                  style: TextStyle(
                                    color: source.status.contains('متحقق')
                                        ? Colors.green.shade700
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text('${(coverage * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: coverage, minHeight: 8),
                      const SizedBox(height: 10),
                      Text(
                        '${questions.length} سؤالًا • ${units.length} وحدات • '
                        '$subjectCoveredLessons من $totalSubjectLessons محورًا مغطى',
                      ),
                      const SizedBox(height: 8),
                      Text(source.note, style: const TextStyle(height: 1.5)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SkillInsightsScreen extends StatelessWidget {
  const SkillInsightsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final profileSubjects = controller.profile?.subjects ?? const <String>[];
    final grouped = <String, int>{};

    for (final mistake in controller.mistakes) {
      if (profileSubjects.isNotEmpty &&
          !profileSubjects.contains(mistake.subject)) {
        continue;
      }
      final skill = mistake.skill.trim().isEmpty ? 'فهم' : mistake.skill;
      final key = '${mistake.subject}|$skill';
      grouped[key] = (grouped[key] ?? 0) + 1;
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bySubject = <String, int>{};
    for (final mistake in controller.mistakes) {
      if (profileSubjects.isNotEmpty &&
          !profileSubjects.contains(mistake.subject)) {
        continue;
      }
      bySubject[mistake.subject] = (bySubject[mistake.subject] ?? 0) + 1;
    }
    final subjectEntries = bySubject.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('التحليل المهاري')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ماذا يكشف سجل أخطائك؟',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يحلل مُوَجِّه الأخطاء المحفوظة بحسب المبحث والمهارة. هذا مؤشر علاجي، وليس حكمًا نهائيًا على مستوى الطالب؛ كلما زاد عدد الاختبارات أصبحت الصورة أدق.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('${controller.examResults.length} اختبارًا')),
                      Chip(label: Text('${controller.mistakes.length} خطأ محفوظًا')),
                      Chip(
                        label: Text(
                          '${controller.mistakes.where((m) => m.verifiedFromOfficialCurriculum).length} من أسئلة مرتبطة بالمنهاج',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الأولويات حسب المبحث',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (subjectEntries.isEmpty)
            const _SkillEmpty()
          else
            ...subjectEntries.map((entry) {
              final average = controller.performanceForSubject(entry.key);
              final weakUnit = controller.topWeakUnitForSubject(entry.key);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${entry.value}')),
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    [
                      if (average != null) 'متوسط الأداء ${average.round()}%',
                      if (weakUnit != null) 'أكثر وحدة أخطاءً: $weakUnit',
                    ].join(' • '),
                  ),
                ),
              );
            }),
          const SizedBox(height: 18),
          const Text(
            'المهارات الأكثر حاجة للمراجعة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const _SkillEmpty()
          else
            ...entries.take(12).map((entry) {
              final parts = entry.key.split('|');
              final subject = parts.first;
              final skill = parts.length > 1 ? parts[1] : 'فهم';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        child: Text('${entry.value}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(subject),
                          ],
                        ),
                      ),
                      const Icon(Icons.trending_up_outlined),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CurriculumLibraryScreen(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.school_outlined),
            label: const Text('اذهب إلى تدريب المنهاج'),
          ),
        ],
      ),
    );
  }
}

class _SkillEmpty extends StatelessWidget {
  const _SkillEmpty();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.insights_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'لا توجد بيانات كافية بعد. أجب عن اختبار مرتبط بالمنهاج، وستظهر المهارات التي تحتاج مراجعة هنا.',
                style: TextStyle(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
