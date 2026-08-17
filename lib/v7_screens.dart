import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'v4_screens.dart';
import 'v6_curriculum_data.dart';
import 'v7_engine.dart';

class AdaptiveExamSetupScreen extends StatefulWidget {
  const AdaptiveExamSetupScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AdaptiveExamSetupScreen> createState() => _AdaptiveExamSetupScreenState();
}

class _AdaptiveExamSetupScreenState extends State<AdaptiveExamSetupScreen> {
  late String _subject;
  int _count = 20;
  int _minutes = 35;
  String _blueprint = 'علاجي حسب الضعف';
  String _difficulty = 'تكيفي';

  List<String> get _subjects {
    const supported = ['اللغة الإنجليزية', 'الرياضيات', 'الكيمياء', 'الفيزياء', 'الأحياء'];
    final preferred = widget.controller.profile?.subjects
            .where(supported.contains)
            .toList() ??
        <String>[];
    return preferred.isEmpty ? supported : preferred;
  }

  @override
  void initState() {
    super.initState();
    _subject = _subjects.first;
  }

  void _start() {
    final exam = buildV7AdaptiveExam(
      controller: widget.controller,
      subject: _subject,
      count: _count,
      minutes: _minutes,
      blueprintMode: _blueprint,
      difficultyProfile: _difficulty,
    );
    if (exam.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أسئلة كافية لهذا المبحث حاليًا.')),
      );
      return;
    }
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
    final weights = unitTrainingWeights(
      subject: _subject,
      mode: _blueprint,
      controller: widget.controller,
    );
    final resolved = resolvedDifficultyProfile(
      requested: _difficulty,
      subject: _subject,
      controller: widget.controller,
    );
    final subjectCount = allCurriculumQuestions.where((q) => q.subject == _subject).length;

    return Scaffold(
      appBar: AppBar(title: const Text('الاختبار التكيفي V8')),
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
                    'اختبار يتغير مع الطالب',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يعطي أولوية للوحدات والمهارات منخفضة الإتقان، ثم يوازن مستوى الصعوبة وفق Mastery Score عند توافر بيانات كافية. الأوزان هنا تدريبية داخل التطبيق وليست أوزانًا وزارية معلنة.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 10),
                  Chip(label: Text('$subjectCount سؤالًا متاحًا في $_subject')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _subject,
            decoration: const InputDecoration(labelText: 'المبحث'),
            items: _subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => _subject = value ?? _subject),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _blueprint,
            decoration: const InputDecoration(labelText: 'طريقة توزيع الوحدات'),
            items: v7BlueprintModes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => _blueprint = value ?? _blueprint),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _difficulty,
            decoration: const InputDecoration(labelText: 'ملف الصعوبة'),
            items: v7DifficultyProfiles
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() => _difficulty = value ?? _difficulty),
          ),
          const SizedBox(height: 8),
          Text('المستوى الفعلي لهذه المحاولة: $resolved'),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 10, label: Text('10')),
              ButtonSegment(value: 20, label: Text('20')),
              ButtonSegment(value: 30, label: Text('30')),
              ButtonSegment(value: 40, label: Text('40')),
            ],
            selected: {_count},
            onSelectionChanged: (s) => setState(() => _count = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _minutes,
            decoration: const InputDecoration(labelText: 'الوقت'),
            items: const [20, 30, 35, 45, 60, 75]
                .map((m) => DropdownMenuItem(value: m, child: Text('$m دقيقة')))
                .toList(),
            onChanged: (value) => setState(() => _minutes = value ?? _minutes),
          ),
          const SizedBox(height: 18),
          const Text('توزيع الوحدات المتوقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...weights.entries.map((entry) {
            final percent = (entry.value * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(value: entry.value, minHeight: 8),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(width: 42, child: Text('$percent%')),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.auto_awesome),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('أنشئ الاختبار وابدأ'),
            ),
          ),
        ],
      ),
    );
  }
}

class DeepDiagnosticsScreen extends StatelessWidget {
  const DeepDiagnosticsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final mistakes = controller.mistakes;
    final errorTypes = <String, int>{};
    final lessons = <String, int>{};
    final difficulties = <String, int>{};

    for (final m in mistakes) {
      final errorType = m.errorType == 'غير مصنف' ? classifyErrorType(m.skill) : m.errorType;
      errorTypes[errorType] = (errorTypes[errorType] ?? 0) + 1;
      final lessonKey = '${m.subject}|${m.unit}|${m.lesson}';
      lessons[lessonKey] = (lessons[lessonKey] ?? 0) + 1;
      difficulties[m.difficulty] = (difficulties[m.difficulty] ?? 0) + 1;
    }

    final typeEntries = errorTypes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final lessonEntries = lessons.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final diffEntries = difficulties.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('التشخيص العميق V8')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نوع الخطأ أهم من عدد الأخطاء', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'يصنّف مُوَجِّه الخطأ من المهارة المرتبطة بالسؤال إلى: مفاهيمي، حسابي/إجرائي، لغوي، استدلالي أو تطبيقي. هذا التصنيف علاجي تقريبي ويمكن تحسينه مع مزيد من بيانات المحاولات.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('${controller.examResults.length} اختبارًا')),
                      Chip(label: Text('${mistakes.length} خطأ محفوظًا')),
                      Chip(label: Text('${lessons.length} درسًا ظهر فيه خطأ')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('أنواع الأخطاء', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (typeEntries.isEmpty)
            const Card(child: ListTile(title: Text('لا توجد بيانات كافية بعد.')))
          else
            ...typeEntries.map((e) => _DiagnosticBar(label: e.key, value: e.value, max: typeEntries.first.value)),
          const SizedBox(height: 18),
          const Text('أكثر الدروس احتياجًا للمراجعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (lessonEntries.isEmpty)
            const Card(child: ListTile(title: Text('أكمل اختبارًا واحدًا على الأقل ليظهر الترتيب.')))
          else
            ...lessonEntries.take(8).map((e) {
              final parts = e.key.split('|');
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${e.value}')),
                  title: Text(parts.length > 2 ? parts[2] : e.key),
                  subtitle: Text(parts.length > 1 ? '${parts[0]} • ${parts[1]}' : ''),
                ),
              );
            }),
          const SizedBox(height: 18),
          const Text('الأخطاء حسب مستوى الصعوبة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diffEntries.map((e) => Chip(label: Text('${e.key}: ${e.value}'))).toList(),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticBar extends StatelessWidget {
  const _DiagnosticBar({required this.label, required this.value, required this.max});

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text('$value'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: max == 0 ? 0 : value / max, minHeight: 8),
          ],
        ),
      ),
    );
  }
}
