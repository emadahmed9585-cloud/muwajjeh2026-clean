import 'dart:async';

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'exam_data.dart';
import 'models.dart';
import 'v4_screens.dart';
import 'v5_screens.dart';
import 'curriculum_data.dart';
import 'v6_curriculum_data.dart';
import 'v6_screens.dart';
import 'v7_screens.dart';
import 'v8_screens.dart';
import 'v9_screens.dart';
import 'v10_screens.dart';
import 'v11_screens.dart';
import 'v13_theme.dart';
import 'v13_experience.dart';
import 'v13_question_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.load();
  runApp(MuwajjehApp(controller: controller));
}

class MuwajjehApp extends StatelessWidget {
  const MuwajjehApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final appTheme = buildMuwajjehTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مُوَجِّه',
      theme: appTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: controller.hasProfile
          ? MainShell(controller: controller)
          : ProfileSetupScreen(controller: controller, isFirstRun: true),
    );
  }
}

// -----------------------------------------------------------------------------
// الملف الشخصي
// -----------------------------------------------------------------------------

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.controller,
    required this.isFirstRun,
  });

  final AppController controller;
  final bool isFirstRun;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _branch = 'العلمي';
  String _gradeYear = 'الثاني عشر';
  double _dailyGoal = 120;
  final Set<String> _subjects = {};

  static const _branches = ['العلمي', 'الأدبي', 'الشرعي', 'الصحي', 'الهندسي'];
  static const _allSubjects = [
    'اللغة الإنجليزية',
    'الرياضيات',
    'الكيمياء',
    'الفيزياء',
    'الأحياء',
    'اللغة العربية',
    'تاريخ الأردن',
    'الحاسوب',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _branch = profile?.branch ?? 'العلمي';
    _gradeYear = profile?.gradeYear ?? 'الثاني عشر';
    _dailyGoal = (profile?.dailyGoalMinutes ?? 120).toDouble();
    _subjects.addAll(
      profile?.subjects ??
          const ['اللغة الإنجليزية', 'الرياضيات', 'الكيمياء', 'الفيزياء'],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر مبحثاً واحداً على الأقل.')),
      );
      return;
    }

    await widget.controller.saveProfile(
      StudentProfile(
        name: _nameController.text.trim(),
        branch: _branch,
        gradeYear: _gradeYear,
        subjects: _subjects.toList(),
        dailyGoalMinutes: _dailyGoal.round(),
      ),
    );

    if (!mounted) return;
    if (widget.isFirstRun) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainShell(controller: widget.controller),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isFirstRun,
        title: Text(widget.isFirstRun ? 'إعداد حساب الطالب' : 'تعديل الملف الشخصي'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.isFirstRun) ...[
              const Icon(Icons.explore_rounded, size: 72, color: MuwajjehPalette.teal),
              const SizedBox(height: 12),
              const Text(
                'أهلاً بك في مُوَجِّه',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'أنشئ ملفك الدراسي حتى تصبح النتائج والخطط مرتبطة باحتياجاتك.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.6),
              ),
              const SizedBox(height: 26),
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الطالب',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'اكتب اسم الطالب.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _branch,
              decoration: const InputDecoration(
                labelText: 'الفرع',
                prefixIcon: Icon(Icons.account_tree_outlined),
              ),
              items: _branches
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _branch = value);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _gradeYear,
              decoration: const InputDecoration(
                labelText: 'الصف',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'الحادي عشر', child: Text('الحادي عشر')),
                DropdownMenuItem(value: 'الثاني عشر', child: Text('الثاني عشر')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _gradeYear = value);
              },
            ),
            const SizedBox(height: 22),
            const Text('المباحث التي تدرسها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSubjects.map((subject) {
                return FilterChip(
                  label: Text(subject),
                  selected: _subjects.contains(subject),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _subjects.add(subject) : _subjects.remove(subject);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'هدف الدراسة اليومي: ${_dailyGoal.round()} دقيقة',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _dailyGoal,
              min: 30,
              max: 300,
              divisions: 18,
              label: '${_dailyGoal.round()} دقيقة',
              onChanged: (value) => setState(() => _dailyGoal = value),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_outline),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(widget.isFirstRun ? 'ابدأ استخدام مُوَجِّه' : 'حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// الهيكل الرئيسي
// -----------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeDashboardV13(
        controller: widget.controller,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      AdvisorHubV13(controller: widget.controller),
      ExamsScreen(controller: widget.controller),
      SmartPlanScreen(controller: widget.controller),
      FocusScreen(controller: widget.controller),
    ];

    const titles = [
      'بوصلة التوجيهي',
      'اسأل مُوَجِّه',
      'الامتحانات',
      'الخطة الذكية',
      'أدوات التركيز',
    ];

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_currentIndex]),
            actions: [
              IconButton(
                tooltip: 'الملف الشخصي',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(controller: widget.controller),
                    ),
                  );
                },
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ],
          ),
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'اسأل',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'الامتحانات',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'الخطة',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer),
                label: 'التركيز',
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  final AppController controller;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final profile = controller.profile!;
        final average = controller.overallExamAverage;
        final today = controller.todayFocusMinutes;
        final goal = profile.dailyGoalMinutes;
        final progress = goal == 0 ? 0.0 : (today / goal).clamp(0.0, 1.0);
        final strongest = controller.strongestSubject;
        final weakest = controller.weakestSubject;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [MuwajjehPalette.navy, Color(0xFF215A67)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً، ${profile.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.gradeYear} • الفرع ${profile.branch}',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    const Text('هدف التركيز اليومي', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$today من $goal دقيقة',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.assignment_turned_in_outlined,
                      value: '${controller.examResults.length}',
                      label: 'اختبارات مكتملة',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.analytics_outlined,
                      value: average == null ? '—' : '${average.round()}%',
                      label: 'متوسط الأداء',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.timer_outlined,
                      value: '${controller.totalFocusMinutes}',
                      label: 'دقائق التركيز',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('ابدأ من هنا', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.psychology_alt_outlined,
                      title: 'استشارة',
                      subtitle: 'حل مشكلة دراسية',
                      onTap: () => onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.quiz_outlined,
                      title: 'اختبار',
                      subtitle: 'قِس مستواك الآن',
                      onTap: () => onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.play_circle_outline,
                      title: 'تركيز',
                      subtitle: 'ابدأ جلسة دراسة',
                      onTap: () => onNavigate(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text('تحليل الأداء', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PerformanceScreen(controller: controller),
                        ),
                      );
                    },
                    child: const Text('التفاصيل'),
                  ),
                ],
              ),
              if (controller.examResults.isEmpty)
                const _EmptyStateCard(
                  icon: Icons.insights_outlined,
                  text: 'أكمل أول اختبار حتى يبدأ مُوَجِّه بتحليل نقاط القوة والضعف.',
                )
              else ...[
                _PerformanceInsight(
                  icon: Icons.trending_up,
                  title: 'نقطة قوة حالية',
                  value: strongest == null
                      ? 'غير متاح'
                      : '${strongest.subject} • ${strongest.average.round()}%',
                  positive: true,
                ),
                _PerformanceInsight(
                  icon: Icons.track_changes,
                  title: 'الأولوية القادمة',
                  value: weakest == null
                      ? 'غير متاح'
                      : '${weakest.subject} • ${weakest.average.round()}%',
                  positive: false,
                ),
              ],
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(controller.nextRecommendation.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(controller.nextRecommendation.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onNavigate(3),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.psychology_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  title: const Text(
                    'تحليل المهارات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    controller.mistakes.isEmpty
                        ? 'ابدأ اختبارًا ليحدد مُوَجِّه مهاراتك الأضعف.'
                        : '${controller.mistakes.length} خطأ محفوظًا جاهزًا للتحليل.',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SkillInsightsScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.workspace_premium_outlined, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: const Text('لوحة الإتقان V8', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    controller.questionAttempts.isEmpty
                        ? 'ستظهر درجة الإتقان بعد أول اختبار جديد.'
                        : '${controller.questionAttempts.length} محاولة سؤال مسجلة للتحليل.',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MasteryDashboardScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Icon(Icons.route_outlined, color: Theme.of(context).colorScheme.tertiary),
                  ),
                  title: const Text('مساري الشخصي V9', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    controller.activeLearningPathSnapshot == null
                        ? 'حوّل أضعف مهارة إلى مسار: فهم ← تدريب ← تحقق.'
                        : '${controller.activeLearningPathSnapshot!.stageLabel} • ${controller.activeLearningPathSnapshot!.record.skill}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LearningPathScreen(
                          controller: controller,
                          launchExam: (ctx, exam) {
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => ExamQuizScreen(exam: exam, controller: controller),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(Icons.psychology_alt_outlined, color: Theme.of(context).colorScheme.secondary),
                  ),
                  title: const Text('المعلم الذكي V12', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('شرح للمبتدئ + رقم صفحة الكتاب + مثال بسيط + علاج حسب الإتقان.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SmartTutorScreen(
                          controller: controller,
                          launchExam: (ctx, exam) {
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => ExamQuizScreen(exam: exam, controller: controller),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: const Text('خريطة التقدم V10', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('تتبّع إتقان الوحدات والدروس والمهارات عبر الزمن.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CurriculumProgressMapScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.secondary),
                  ),
                  title: const Text('اختبار تكيفي V8', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('اختبار يتوزع حسب وحدات المنهاج ونقاط ضعفك ومستواك.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdaptiveExamSetupScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text('مباحثك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.subjects.map((subject) => Chip(label: Text(subject))).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceInsight extends StatelessWidget {
  const _PerformanceInsight({
    required this.icon,
    required this.title,
    required this.value,
    required this.positive,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final baseColor = positive ? Colors.green : Colors.orange;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: baseColor.withOpacity(0.12),
          child: Icon(icon, color: baseColor),
        ),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// الاستشارة الأكاديمية
// -----------------------------------------------------------------------------

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 18),
          Container(
            width: 108,
            height: 108,
            margin: const EdgeInsets.symmetric(horizontal: 100),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'اسأل مُوَجِّه',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'صف المشكلة التي تواجهك، وسيحوّلها مُوَجِّه إلى خطوات عملية لجلسة اليوم.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.7),
          ),
          const SizedBox(height: 24),
          const _FeatureTile(
            icon: Icons.analytics_outlined,
            title: 'تشخيص المشكلة',
            subtitle: 'تحديد نوع الضعف والأولوية الدراسية.',
          ),
          const _FeatureTile(
            icon: Icons.route_outlined,
            title: 'خطة علاجية',
            subtitle: 'تقسيم وقتك إلى مراجعة وفهم وتطبيق.',
          ),
          const _FeatureTile(
            icon: Icons.track_changes,
            title: 'إجراء يبدأ اليوم',
            subtitle: 'خطوة واحدة واضحة بدل النصائح العامة.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ConsultationFormScreen(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ابدأ الاستشارة الآن', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class ConsultationFormScreen extends StatefulWidget {
  const ConsultationFormScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ConsultationFormScreen> createState() => _ConsultationFormScreenState();
}

class _ConsultationFormScreenState extends State<ConsultationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemController = TextEditingController();

  late String _subject;
  String _problemType = 'صعوبة فهم المادة';
  double _dailyMinutes = 60;

  static const _problemTypes = [
    'صعوبة فهم المادة',
    'ضعف الحفظ والتذكر',
    'بطء حل الأسئلة',
    'القلق من الامتحان',
    'التراكم الدراسي',
    'ضعف إدارة الوقت',
  ];

  @override
  void initState() {
    super.initState();
    final subjects = widget.controller.profile?.subjects ?? const ['اللغة الإنجليزية'];
    _subject = subjects.isEmpty ? 'اللغة الإنجليزية' : subjects.first;
  }

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  void _buildPlan() {
    if (!_formKey.currentState!.validate()) return;

    final plan = _generatePlan(
      subject: _subject,
      problemType: _problemType,
      details: _problemController.text.trim(),
      dailyMinutes: _dailyMinutes.round(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ConsultationResultScreen(plan: plan)),
    );
  }

  StudyPlan _generatePlan({
    required String subject,
    required String problemType,
    required String details,
    required int dailyMinutes,
  }) {
    final review = (dailyMinutes * 0.25).round();
    final learning = (dailyMinutes * 0.35).round();
    final practice = dailyMinutes - review - learning;

    String diagnosis;
    String firstAction;

    switch (problemType) {
      case 'ضعف الحفظ والتذكر':
        diagnosis = 'المشكلة تبدو مرتبطة باسترجاع المعلومات أكثر من فهمها.';
        firstAction = 'استخدم الاستدعاء النشط: أغلق الكتاب واكتب ما تتذكره قبل المراجعة.';
        break;
      case 'بطء حل الأسئلة':
        diagnosis = 'الأولوية هي رفع سرعة الاسترجاع وربط الفكرة بنمط السؤال.';
        firstAction = 'حل مجموعة قصيرة بمؤقت، ثم راجع سبب كل إجابة خاطئة.';
        break;
      case 'القلق من الامتحان':
        diagnosis = 'المشكلة الأساسية هي الأداء تحت الضغط، لا المعرفة وحدها.';
        firstAction = 'ابدأ بمحاكاة قصيرة في وقت محدد ثم ارفع المدة تدريجياً.';
        break;
      case 'التراكم الدراسي':
        diagnosis = 'تحتاج إلى تقليل حجم المهمة وتقسيم التراكم إلى وحدات يومية.';
        firstAction = 'اختر درساً واحداً فقط اليوم وأنهِه قبل الانتقال إلى غيره.';
        break;
      case 'ضعف إدارة الوقت':
        diagnosis = 'المطلوب هو تحويل وقت الدراسة إلى جلسات محددة الهدف.';
        firstAction = 'حدّد هدفاً واحداً لكل جلسة، وأوقف أي مهمة لا تخدم هذا الهدف.';
        break;
      default:
        diagnosis = 'المشكلة تبدو مرتبطة ببناء الفهم قبل الانتقال إلى التدريب المكثف.';
        firstAction = 'ابدأ بمفهوم واحد، اشرحه بكلماتك، ثم اختبره بسؤالين أو ثلاثة.';
    }

    return StudyPlan(
      subject: subject,
      problemType: problemType,
      diagnosis: diagnosis,
      firstAction: firstAction,
      details: details,
      steps: [
        '$review دقيقة: مراجعة سريعة لما سبق من $subject.',
        '$learning دقيقة: تعلم أو فهم جزئية واحدة جديدة فقط.',
        '$practice دقيقة: حل أسئلة وكتابة الأخطاء في سجل خاص.',
        'آخر 3 دقائق: دوّن ما أتقنته وما يحتاج إلى مراجعة في الجلسة القادمة.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.controller.profile?.subjects ?? const ['اللغة الإنجليزية'];

    return Scaffold(
      appBar: AppBar(title: const Text('استشارة جديدة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('أخبرني بما تواجهه', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('ستحصل على خطة أولية مباشرة من إجاباتك.'),
            const SizedBox(height: 22),
            DropdownButtonFormField<String>(
              value: _subject,
              decoration: const InputDecoration(
                labelText: 'المبحث',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              items: subjects
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _subject = value);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _problemType,
              decoration: const InputDecoration(
                labelText: 'نوع المشكلة',
                prefixIcon: Icon(Icons.psychology_alt_outlined),
              ),
              items: _problemTypes
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _problemType = value);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _problemController,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'صف المشكلة بالتفصيل',
                hintText: 'مثال: أفهم الدرس ولكن أخطئ عندما تتغير صياغة السؤال...',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'اكتب وصفاً مختصراً للمشكلة (10 أحرف على الأقل).';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'الوقت المتاح لهذه الجلسة: ${_dailyMinutes.round()} دقيقة',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _dailyMinutes,
              min: 30,
              max: 180,
              divisions: 10,
              label: '${_dailyMinutes.round()} دقيقة',
              onChanged: (value) => setState(() => _dailyMinutes = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _buildPlan,
              icon: const Icon(Icons.route),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('صمّم خطتي', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultationResultScreen extends StatelessWidget {
  const ConsultationResultScreen({super.key, required this.plan});

  final StudyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخطة العلاجية')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.subject,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(plan.problemType, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(height: 28),
                  const Text('التشخيص الأولي', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(plan.diagnosis, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('خطة جلسة اليوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...plan.steps.asMap().entries.map(
            (entry) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
                title: Text(entry.value),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ابدأ من هنا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(plan.firstAction, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// الامتحانات والنتائج
// -----------------------------------------------------------------------------

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final studentSubjects = controller.profile?.subjects ?? const <String>[];
    final preferred = examBank.where((exam) => studentSubjects.contains(exam.subject)).toList();
    final other = examBank.where((exam) => !studentSubjects.contains(exam.subject)).toList();
    final ordered = [...preferred, ...other];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('بنك الاختبارات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('أجب عن الأسئلة، ثم تُحفظ النتيجة تلقائياً في ملف أدائك.'),
          const SizedBox(height: 18),
          _ExamHubAction(
            icon: Icons.verified_outlined,
            title: 'منهج 2026-2027 الرسمي',
            subtitle: '${allBankQuestions.where((q) => q.verifiedFromOfficialCurriculum).length} سؤالاً مرتبطاً بالمنهاج • كتاب رسمي + نقل وفهم',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CurriculumLibraryScreen(controller: controller)),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.fact_check_outlined,
                  title: 'تغطية المنهاج',
                  subtitle: 'حالة الفهرسة والتغطية لكل مبحث',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CurriculumCoverageScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.psychology_outlined,
                  title: 'تحليل المهارات',
                  subtitle: 'حوّل أخطاءك إلى أولويات مراجعة',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SkillInsightsScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.account_balance_outlined,
                  title: 'بنك الأسئلة',
                  subtitle: 'اختر المبحث والوحدة والصعوبة',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => QuestionBankScreen(controller: controller)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.emoji_events_outlined,
                  title: 'محاكاة وزارية 2026',
                  subtitle: '50 سؤالًا • من الكتب الرسمية + نقل وفهم',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MinisterialMockSetupScreenV11(controller: controller)),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExamHubAction(
            icon: Icons.route_outlined,
            title: 'مساري الشخصي V9',
            subtitle: 'فهم ← تدريب ← تحقق ← انتقال أو علاج',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LearningPathScreen(
                    controller: controller,
                    launchExam: (ctx, exam) {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => ExamQuizScreen(exam: exam, controller: controller),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.psychology_alt_outlined,
                  title: 'المعلم الذكي V12',
                  subtitle: 'صفحة الكتاب + شرح من الصفر + علاج مخصص',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SmartTutorScreen(
                          controller: controller,
                          launchExam: (ctx, exam) {
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => ExamQuizScreen(exam: exam, controller: controller),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.map_outlined,
                  title: 'خريطة التقدم V10',
                  subtitle: 'إتقان المنهاج والاتجاه عبر الزمن',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CurriculumProgressMapScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExamHubAction(
            icon: Icons.workspace_premium_outlined,
            title: 'Mastery Score V8',
            subtitle: '${controller.questionAttempts.length} محاولة • إتقان حسب المبحث والدرس والمهارة',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MasteryDashboardScreen(controller: controller),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.auto_awesome,
                  title: 'اختبار تكيفي V8',
                  subtitle: 'أوزان تدريبية + صعوبة تكيفية',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdaptiveExamSetupScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ExamHubAction(
                  icon: Icons.manage_search_outlined,
                  title: 'التشخيص العميق',
                  subtitle: 'نوع الخطأ والدرس ومستوى الصعوبة',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeepDiagnosticsScreen(controller: controller),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExamHubAction(
            icon: Icons.folder_open_outlined,
            title: 'سجل الأخطاء',
            subtitle: '${controller.mistakes.length} خطأ/أخطاء محفوظة للمراجعة العلاجية',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MistakesScreen(controller: controller)),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text('اختبارات جاهزة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...ordered.map((exam) => _ExamCard(exam: exam, controller: controller)),
          if (controller.examResults.isNotEmpty) ...[
            const SizedBox(height: 18),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PerformanceScreen(controller: controller)),
                );
              },
              icon: const Icon(Icons.insights),
              label: const Text('عرض سجل النتائج والتحليل'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExamHubAction extends StatelessWidget {
  const _ExamHubAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.controller});

  final ExamDefinition exam;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(exam.icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('${exam.subtitle}\n${exam.questions.length} أسئلة'),
        ),
        trailing: const Icon(Icons.play_circle_fill, color: Colors.green),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExamQuizScreen(exam: exam, controller: controller),
            ),
          );
        },
      ),
    );
  }
}

class ExamQuizScreen extends StatefulWidget {
  const ExamQuizScreen({
    super.key,
    required this.exam,
    required this.controller,
  });

  final ExamDefinition exam;
  final AppController controller;

  @override
  State<ExamQuizScreen> createState() => _ExamQuizScreenState();
}

class _ExamQuizScreenState extends State<ExamQuizScreen> {
  late final List<int?> _answers;
  late final List<int> _responseSeconds;
  late DateTime _lastInteractionAt;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.exam.questions.length, null);
    _responseSeconds = List<int>.filled(widget.exam.questions.length, 0);
    _lastInteractionAt = DateTime.now();
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

  Future<void> _submit() async {
    final unanswered = _answers.where((answer) => answer == null).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بقي $unanswered سؤال/أسئلة دون إجابة.')),
      );
      return;
    }

    var score = 0;
    final mistakes = <MistakeRecord>[];
    final attempts = <QuestionAttemptRecord>[];
    final now = DateTime.now();
    for (var i = 0; i < widget.exam.questions.length; i++) {
      final question = widget.exam.questions[i];
      final selectedIndex = _answers[i]!;
      final isCorrect = selectedIndex == question.correctIndex;
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
          selectedIndex: selectedIndex,
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
        mistakes.add(
          MistakeRecord(
            questionId: question.id.isEmpty ? '${widget.exam.title}-$i' : question.id,
            examTitle: widget.exam.title,
            subject: question.subject.isEmpty ? widget.exam.subject : question.subject,
            unit: question.unit,
            lesson: question.lesson,
            difficulty: question.difficulty,
            questionText: question.text,
            selectedOption: question.options[selectedIndex],
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
    await widget.controller.addMistakes(mistakes);
    await widget.controller.addQuestionAttempts(attempts);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          controller: widget.controller,
          exam: widget.exam,
          answers: _answers.cast<int>(),
          score: score,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exam.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.exam.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.exam.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('إنهاء الاختبار', style: TextStyle(fontSize: 18)),
                ),
              ),
            );
          }

          final question = widget.exam.questions[index];
          return QuestionCardV13(
            number: index + 1,
            question: question,
            selectedIndex: _answers[index],
            onSelected: (value) => _recordAnswer(index, value),
          );
        },
      ),
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({
    super.key,
    required this.controller,
    required this.exam,
    required this.answers,
    required this.score,
  });

  final AppController controller;
  final ExamDefinition exam;
  final List<int> answers;
  final int score;

  @override
  Widget build(BuildContext context) {
    final percentage = (score / exam.questions.length * 100).round();
    final recommendation = controller.recommendationAfterExam(exam.subject, percentage);

    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.insights,
                    size: 70,
                    color: percentage >= 70
                        ? Colors.amber.shade700
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text('$percentage%', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  Text('أجبت عن $score من ${exam.questions.length} بصورة صحيحة.'),
                  const SizedBox(height: 8),
                  const Text('تم حفظ هذه النتيجة في ملف أدائك.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
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
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MistakesScreen(controller: controller)),
                      );
                    },
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('راجع أخطاء هذا الاختبار'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('التصحيح والتفسير', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(exam.questions.length, (index) {
            final question = exam.questions[index];
            final isCorrect = answers[index] == question.correctIndex;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${index + 1}. ${question.text}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('إجابتك: ${question.options[answers[index]]}'),
                    if (!isCorrect)
                      Text(
                        'الإجابة الصحيحة: ${question.options[question.correctIndex]}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 8),
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

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key, required this.controller});

  final AppController controller;

  String _dateText(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final performance = controller.subjectPerformance;
        return Scaffold(
          appBar: AppBar(title: const Text('تحليل الأداء')),
          body: controller.examResults.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('لا توجد نتائج بعد. أكمل اختباراً واحداً على الأقل لبدء التحليل.'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Text('الأداء حسب المبحث', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...performance.map((item) {
                      final normalized = (item.average / 100).clamp(0.0, 1.0);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(item.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Text('${item.average.round()}%'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(value: normalized),
                              const SizedBox(height: 8),
                              Text('${item.attempts} محاولة/محاولات'),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    const Text('سجل الاختبارات', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...controller.examResults.map(
                      (record) => Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${record.percentage}%')),
                          title: Text(record.examTitle),
                          subtitle: Text('${record.subject} • ${_dateText(record.completedAt)}'),
                          trailing: Text('${record.score}/${record.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
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

// -----------------------------------------------------------------------------
// التركيز
// -----------------------------------------------------------------------------

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _timer;
  int _selectedMinutes = 50;
  int _remainingSeconds = 50 * 60;
  bool _isRunning = false;
  bool _completionSaved = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrPause() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _selectedMinutes * 60;
      _completionSaved = false;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        _saveCompletedSession();
        _showCompletionDialog();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _saveCompletedSession() async {
    if (_completionSaved) return;
    _completionSaved = true;
    await widget.controller.addFocusSession(
      FocusSessionRecord(minutes: _selectedMinutes, completedAt: DateTime.now()),
    );
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
      _completionSaved = false;
    });
  }

  void _changeDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _isRunning = false;
      _completionSaved = false;
    });
  }

  void _showCompletionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 42),
        title: const Text('أحسنت!'),
        content: Text('أنهيت جلسة تركيز مدتها $_selectedMinutes دقيقة، وتمت إضافتها إلى سجلك.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset();
            },
            child: const Text('جلسة جديدة'),
          ),
        ],
      ),
    );
  }

  String get _timeText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _selectedMinutes * 60;
    if (total == 0) return 0;
    return (1 - (_remainingSeconds / total)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 14),
          const Text('جلسة تركيز', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'أنجزت اليوم ${widget.controller.todayFocusMinutes} دقيقة من هدفك.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 25, label: Text('25 دقيقة')),
              ButtonSegment(value: 50, label: Text('50 دقيقة')),
            ],
            selected: {_selectedMinutes},
            onSelectionChanged: _isRunning ? null : (selection) => _changeDuration(selection.first),
          ),
          const SizedBox(height: 34),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_timeText, style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold)),
                      Text(_isRunning ? 'ركز في مهمة واحدة' : 'وقت الدراسة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _startOrPause,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(_isRunning ? 'إيقاف مؤقت' : 'ابدأ الجلسة'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'إعادة ضبط',
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('إجمالي التركيز'),
              subtitle: Text('${widget.controller.totalFocusMinutes} دقيقة في ${widget.controller.focusSessions.length} جلسة'),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// الملف الشخصي
// -----------------------------------------------------------------------------

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final profile = controller.profile!;
        return Scaffold(
          appBar: AppBar(title: const Text('الملف الشخصي')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(profile.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${profile.gradeYear} • الفرع ${profile.branch}', textAlign: TextAlign.center),
              const SizedBox(height: 22),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined),
                      title: const Text('عدد المباحث'),
                      trailing: Text('${profile.subjects.length}'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('هدف الدراسة اليومي'),
                      trailing: Text('${profile.dailyGoalMinutes} دقيقة'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.quiz_outlined),
                      title: const Text('الاختبارات المكتملة'),
                      trailing: Text('${controller.examResults.length}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileSetupScreen(
                        controller: controller,
                        isFirstRun: false,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل الملف الشخصي'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PerformanceScreen(controller: controller)),
                  );
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('تحليل أدائي'),
              ),
            ],
          ),
        );
      },
    );
  }
}
