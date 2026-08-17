import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';

class MasteryDashboardScreen extends StatefulWidget {
  const MasteryDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MasteryDashboardScreen> createState() => _MasteryDashboardScreenState();
}

class _MasteryDashboardScreenState extends State<MasteryDashboardScreen> {
  String? _subject;

  List<String> get _subjects {
    final values = <String>{...?(widget.controller.profile?.subjects)};
    values.addAll(widget.controller.questionAttempts.map((a) => a.subject));
    final output = values.where((s) => s.trim().isNotEmpty).toList()..sort();
    return output;
  }

  String? get _resolvedSubject {
    final subjects = _subjects;
    if (subjects.isEmpty) return null;
    if (_subject != null && subjects.contains(_subject)) return _subject;
    return subjects.first;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final subject = _resolvedSubject;
        if (subject == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('لوحة الإتقان V8')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'لا توجد محاولات مسجلة بعد. أكمل اختبارًا واحدًا ليبدأ مُوَجِّه بحساب الإتقان.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final subjectMetric = widget.controller.masteryForSubject(subject);
        final skills = widget.controller.masteryBySkill(subject: subject);
        final recent = widget.controller.questionAttempts
            .where((a) => a.subject == subject)
            .take(12)
            .toList();
        final target = widget.controller.nextMasteryTarget;

        return Scaffold(
          appBar: AppBar(title: const Text('لوحة الإتقان V8')),
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
                        'Mastery Score',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'درجة الإتقان لا تعتمد على الأخطاء فقط؛ بل على جميع المحاولات، وصحة الإجابة، وصعوبة السؤال، وحداثة المحاولة، مع أثر صغير لزمن الاستجابة.',
                        style: TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: subject,
                        decoration: const InputDecoration(labelText: 'المبحث'),
                        items: _subjects
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) => setState(() => _subject = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MasteryStat(
                      label: 'الإتقان',
                      value: '${subjectMetric.score.round()}%',
                      subtitle: subjectMetric.status,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MasteryStat(
                      label: 'الثقة',
                      value: '${subjectMetric.confidence.round()}%',
                      subtitle: '${subjectMetric.attempts} محاولة',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MasteryStat(
                      label: 'الزمن',
                      value: subjectMetric.averageResponseSeconds <= 0
                          ? '—'
                          : '${subjectMetric.averageResponseSeconds.round()}ث',
                      subtitle: 'متوسط تقديري',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (target != null) ...[
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
                    title: const Text('ما الذي تدرسه بعد ذلك؟', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${target.subject} ← ${target.unit} ← ${target.lesson}\nالمهارة: ${target.skill}\n${target.reason}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('إتقان المهارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (skills.isEmpty)
                const Card(child: ListTile(title: Text('لا توجد بيانات مهارية كافية بعد.')))
              else
                ...skills.take(12).map((metric) => _MasterySkillCard(metric: metric)),
              const SizedBox(height: 18),
              const Text('المحاولات الأخيرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                const Card(child: ListTile(title: Text('لا توجد محاولات.')))
              else
                ...recent.map(
                  (attempt) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(attempt.isCorrect ? Icons.check : Icons.close),
                      ),
                      title: Text(attempt.skill),
                      subtitle: Text('${attempt.unit} • ${attempt.lesson} • ${attempt.difficulty}'),
                      trailing: Text(
                        attempt.responseSeconds <= 0 ? '—' : '${attempt.responseSeconds}ث',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('كيف تُقرأ الدرجة؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      SizedBox(height: 8),
                      Text('أقل من 45: يحتاج تأسيس • 45–64: قيد التطور • 65–79: جيد • 80–91: متقن • 92 فأعلى: متقن جدًا.'),
                      SizedBox(height: 6),
                      Text('تبدأ المهارة بدرجة تمهيدية محافظة، لذلك لا يكفي سؤال واحد صحيح للوصول إلى 100%. ترتفع الثقة كلما زاد عدد المحاولات.'),
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

class _MasteryStat extends StatelessWidget {
  const _MasteryStat({required this.label, required this.value, required this.subtitle});

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MasterySkillCard extends StatelessWidget {
  const _MasterySkillCard({required this.metric});

  final MasteryMetric metric;

  @override
  Widget build(BuildContext context) {
    final value = (metric.score / 100).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(metric.skill, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('${metric.score.round()}% • ${metric.status}'),
              ],
            ),
            const SizedBox(height: 5),
            Text('${metric.unit} ← ${metric.lesson}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 9),
            LinearProgressIndicator(value: value, minHeight: 8),
            const SizedBox(height: 7),
            Text(
              '${metric.correct}/${metric.attempts} صحيحة • ثقة ${metric.confidence.round()}%'
              '${metric.averageResponseSeconds > 0 ? ' • ${metric.averageResponseSeconds.round()}ث/سؤال' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
