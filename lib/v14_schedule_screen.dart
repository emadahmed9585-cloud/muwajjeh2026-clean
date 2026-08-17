import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_controller.dart';
import 'v13_theme.dart';
import 'v14_schedule_engine.dart';
import 'v14_schedule_models.dart';
import 'v14_schedule_pdf.dart';

class MyWeeklyProgramScreen extends StatefulWidget {
  const MyWeeklyProgramScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MyWeeklyProgramScreen> createState() => _MyWeeklyProgramScreenState();
}

class _MyWeeklyProgramScreenState extends State<MyWeeklyProgramScreen> {
  static const _draftKey = 'v14_weekly_program_draft';

  late final TextEditingController _nameController;
  List<WeeklySubjectTarget> _subjects = [];
  final List<PlannerFixedActivity> _activities = [];
  Set<int> _availableDays = {0, 1, 2, 3, 4, 5, 6};
  int _studyStartMinute = 16 * 60;
  int _studyEndMinute = 22 * 60;
  int _sessionMinutes = 50;
  int _breakMinutes = 10;
  int _maxSessionsPerDay = 4;
  bool _useMuwajjehPriority = true;
  late DateTime _weekStart;
  bool _loadingDraft = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.controller.profile?.name ?? '');
    _weekStart = _currentSunday();
    _subjects = _defaultSubjects();
    _loadDraft();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<WeeklySubjectTarget> _defaultSubjects() {
    final profileSubjects = widget.controller.profile?.subjects ?? const <String>[];
    final source = profileSubjects.isNotEmpty
        ? profileSubjects
        : const ['اللغة الإنجليزية', 'الرياضيات', 'الكيمياء', 'الفيزياء', 'الأحياء'];
    return source
        .map((subject) => WeeklySubjectTarget(
              subject: subject,
              sessionsPerWeek: 3,
              priority: 2,
            ))
        .toList();
  }

  DateTime _currentSunday() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) return;
      final settings = WeeklyPlannerSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        if (settings.studentName.trim().isNotEmpty) {
          _nameController.text = settings.studentName;
        }
        if (settings.subjects.isNotEmpty) _subjects = settings.subjects;
        _activities
          ..clear()
          ..addAll(settings.activities);
        _availableDays = settings.availableDays.isEmpty
            ? {0, 1, 2, 3, 4, 5, 6}
            : settings.availableDays;
        _studyStartMinute = settings.studyStartMinute;
        _studyEndMinute = settings.studyEndMinute;
        _sessionMinutes = settings.sessionMinutes;
        _breakMinutes = settings.breakMinutes;
        _maxSessionsPerDay = settings.maxSessionsPerDay;
        _useMuwajjehPriority = settings.useMuwajjehPriority;
        _weekStart = settings.weekStart;
      });
    } catch (_) {
      // إذا تغير شكل البيانات بين إصدار وآخر، نستخدم القيم الآمنة الافتراضية.
    } finally {
      if (mounted) setState(() => _loadingDraft = false);
    }
  }

  WeeklyPlannerSettings _settings() {
    return WeeklyPlannerSettings(
      studentName: _nameController.text.trim(),
      weekStart: _weekStart,
      subjects: _subjects,
      activities: List.unmodifiable(_activities),
      availableDays: Set.unmodifiable(_availableDays),
      studyStartMinute: _studyStartMinute,
      studyEndMinute: _studyEndMinute,
      sessionMinutes: _sessionMinutes,
      breakMinutes: _breakMinutes,
      maxSessionsPerDay: _maxSessionsPerDay,
      useMuwajjehPriority: _useMuwajjehPriority,
    );
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(_settings().toJson()));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDraft) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('اعملي برنامجي')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _IntroPanel(name: _nameController.text.trim()),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.badge_outlined,
            title: '1. بيانات البرنامج',
            subtitle: 'اسم الطالب والأسبوع الذي تريد تنظيمه.',
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الطالب',
                    hintText: 'مثال: أحمد محمد',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickWeek,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'بداية الأسبوع',
                      prefixIcon: Icon(Icons.date_range_outlined),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الأحد ${plannerDateLabel(_weekStart)} - السبت ${plannerDateLabel(_weekStart.add(const Duration(days: 6)))}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Icon(Icons.edit_calendar_outlined, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SectionCard(
            icon: Icons.menu_book_outlined,
            title: '2. المواد التي يجب دراستها',
            subtitle: 'حدد عدد الجلسات الأسبوعية وأولوية كل مادة.',
            child: Column(
              children: [
                for (var i = 0; i < _subjects.length; i++) _subjectEditor(i),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _useMuwajjehPriority,
                  onChanged: (value) => setState(() => _useMuwajjehPriority = value),
                  title: const Text('استفد من نتائج مُوَجِّه', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('يرفع أولوية المواد التي تظهر فيها نقاط ضعف، دون تغيير عدد الجلسات الذي طلبته.'),
                ),
              ],
            ),
          ),
          _SectionCard(
            icon: Icons.calendar_view_week_outlined,
            title: '3. أيام الدراسة',
            subtitle: 'اختر الأيام التي تسمح بوضع جلسات دراسة فيها.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final day in plannerDays)
                  FilterChip(
                    selected: _availableDays.contains(day.index),
                    label: Text(day.label),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _availableDays.add(day.index);
                        } else {
                          _availableDays.remove(day.index);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          _SectionCard(
            icon: Icons.schedule_outlined,
            title: '4. وقت الدراسة المفضل',
            subtitle: 'مُوَجِّه سيبحث عن أوقات فارغة داخل هذه النافذة.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _timeButton(
                        label: 'ابدأ الدراسة',
                        minute: _studyStartMinute,
                        onChanged: (value) => setState(() => _studyStartMinute = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _timeButton(
                        label: 'أنهِ الدراسة',
                        minute: _studyEndMinute,
                        onChanged: (value) => setState(() => _studyEndMinute = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _sessionMinutes,
                        decoration: const InputDecoration(labelText: 'مدة الجلسة'),
                        items: const [35, 40, 45, 50, 60, 75]
                            .map((value) => DropdownMenuItem(value: value, child: Text('$value دقيقة')))
                            .toList(),
                        onChanged: (value) => setState(() => _sessionMinutes = value ?? 50),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _breakMinutes,
                        decoration: const InputDecoration(labelText: 'راحة بين الجلسات'),
                        items: const [5, 10, 15, 20]
                            .map((value) => DropdownMenuItem(value: value, child: Text('$value دقائق')))
                            .toList(),
                        onChanged: (value) => setState(() => _breakMinutes = value ?? 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _maxSessionsPerDay,
                  decoration: const InputDecoration(labelText: 'أقصى عدد جلسات في اليوم'),
                  items: const [2, 3, 4, 5, 6]
                      .map((value) => DropdownMenuItem(value: value, child: Text('$value جلسات')))
                      .toList(),
                  onChanged: (value) => setState(() => _maxSessionsPerDay = value ?? 4),
                ),
              ],
            ),
          ),
          _SectionCard(
            icon: Icons.directions_run_outlined,
            title: '5. أنشطتك اليومية الثابتة',
            subtitle: 'مدرسة، درس خصوصي، رياضة، زيارة، تدريب... ولن يضع مُوَجِّه دراسة فوقها.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.school_outlined, size: 18),
                      label: const Text('إضافة دوام المدرسة'),
                      onPressed: _addSchoolPreset,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('إضافة نشاط'),
                      onPressed: _addActivity,
                    ),
                  ],
                ),
                if (_activities.isEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MuwajjehPalette.canvas,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'لم تضف نشاطًا ثابتًا بعد. يمكنك المتابعة، أو أضف أوقات المدرسة والدروس حتى يكون البرنامج أدق.',
                      style: TextStyle(color: MuwajjehPalette.muted),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  for (final activity in _activities) _activityTile(activity),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MuwajjehPalette.navy, MuwajjehPalette.teal],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'جاهز؟',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سأرتب الأسبوع، أوازن المواد، أحترم أنشطتك، ثم أصنع لك PDF ملونًا باسمك.',
                  style: TextStyle(color: Color(0xFFE8F4F2), height: 1.6),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: MuwajjehPalette.sand,
                    foregroundColor: MuwajjehPalette.ink,
                  ),
                  onPressed: _generatePlan,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('اعملي برنامجي الآن'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectEditor(int index) {
    final target = _subjects[index];
    final mastery = widget.controller.masteryForSubject(target.subject);
    final masteryText = mastery.attempts == 0 ? 'لا توجد بيانات بعد' : 'إتقان ${mastery.score.round()}%';
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: target.enabled ? _subjectColor(target.subject).withOpacity(.07) : const Color(0xFFF6F7F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: target.enabled ? _subjectColor(target.subject).withOpacity(.25) : MuwajjehPalette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Switch.adaptive(
                value: target.enabled,
                onChanged: (value) => _updateSubject(index, target.copyWith(enabled: value)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(target.subject, style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text(masteryText, style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (target.enabled) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'جلسة أقل',
                          onPressed: target.sessionsPerWeek <= 1
                              ? null
                              : () => _updateSubject(
                                    index,
                                    target.copyWith(sessionsPerWeek: target.sessionsPerWeek - 1),
                                  ),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text('${target.sessionsPerWeek}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                              const Text('جلسات / أسبوع', style: TextStyle(fontSize: 10.5, color: MuwajjehPalette.muted)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'جلسة أكثر',
                          onPressed: target.sessionsPerWeek >= 10
                              ? null
                              : () => _updateSubject(
                                    index,
                                    target.copyWith(sessionsPerWeek: target.sessionsPerWeek + 1),
                                  ),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: target.priority,
                    decoration: const InputDecoration(labelText: 'الأولوية'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('عادية')),
                      DropdownMenuItem(value: 2, child: Text('مهمة')),
                      DropdownMenuItem(value: 3, child: Text('عالية')),
                    ],
                    onChanged: (value) => _updateSubject(index, target.copyWith(priority: value ?? 2)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _updateSubject(int index, WeeklySubjectTarget value) {
    setState(() => _subjects[index] = value);
  }

  Widget _timeButton({
    required String label,
    required int minute,
    required ValueChanged<int> onChanged,
  }) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
          helpText: label,
        );
        if (picked != null) onChanged(picked.hour * 60 + picked.minute);
      },
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: MuwajjehPalette.muted)),
          const SizedBox(height: 3),
          Text(plannerTimeLabel(minute), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _activityTile(PlannerFixedActivity activity) {
    final day = plannerDays.firstWhere((d) => d.index == activity.dayIndex);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MuwajjehPalette.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: MuwajjehPalette.tealSoft,
            child: Icon(Icons.event_busy_outlined, color: MuwajjehPalette.teal, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${day.label} • ${activity.title}', style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${plannerTimeLabel(activity.startMinute)} - ${plannerTimeLabel(activity.endMinute)}',
                  style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف النشاط',
            onPressed: () => setState(() => _activities.removeWhere((a) => a.id == activity.id)),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'اختر أي يوم من الأسبوع المطلوب',
    );
    if (picked == null) return;
    final normalized = DateTime(picked.year, picked.month, picked.day)
        .subtract(Duration(days: picked.weekday % 7));
    setState(() => _weekStart = normalized);
  }

  void _addSchoolPreset() {
    final existingSchool = _activities.any((a) => a.title == 'المدرسة');
    if (existingSchool) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة دوام المدرسة مسبقًا. يمكنك حذف الأيام أو إضافة أوقات أخرى يدويًا.')),
      );
      return;
    }
    final stamp = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      for (var day = 0; day <= 4; day++) {
        _activities.add(
          PlannerFixedActivity(
            id: 'school_${stamp}_$day',
            dayIndex: day,
            title: 'المدرسة',
            startMinute: 8 * 60,
            endMinute: 14 * 60,
          ),
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أضفت المدرسة من الأحد إلى الخميس 8:00 ص - 2:00 م. عدّلها بإزالة الأيام غير المناسبة وإضافة نشاطك الصحيح.')),
    );
  }

  Future<void> _addActivity() async {
    final titleController = TextEditingController();
    var dayIndex = 0;
    var startMinute = 16 * 60;
    var endMinute = 17 * 60;

    final result = await showModalBottomSheet<PlannerFixedActivity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickTime(bool start) async {
              final current = start ? startMinute : endMinute;
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
              );
              if (picked == null) return;
              setSheetState(() {
                final value = picked.hour * 60 + picked.minute;
                if (start) {
                  startMinute = value;
                } else {
                  endMinute = value;
                }
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('إضافة نشاط ثابت', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'اسم النشاط',
                        hintText: 'درس خصوصي، رياضة، عمل...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: dayIndex,
                      decoration: const InputDecoration(labelText: 'اليوم'),
                      items: plannerDays
                          .map((day) => DropdownMenuItem(value: day.index, child: Text(day.label)))
                          .toList(),
                      onChanged: (value) => setSheetState(() => dayIndex = value ?? 0),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(true),
                            child: Text('من ${plannerTimeLabel(startMinute)}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pickTime(false),
                            child: Text('إلى ${plannerTimeLabel(endMinute)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty || endMinute <= startMinute) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('اكتب اسم النشاط وتأكد أن وقت النهاية بعد وقت البداية.')),
                          );
                          return;
                        }
                        Navigator.of(sheetContext).pop(
                          PlannerFixedActivity(
                            id: 'activity_${DateTime.now().microsecondsSinceEpoch}',
                            dayIndex: dayIndex,
                            title: title,
                            startMinute: startMinute,
                            endMinute: endMinute,
                          ),
                        );
                      },
                      child: const Text('إضافة النشاط'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    titleController.dispose();
    if (result != null) setState(() => _activities.add(result));
  }

  Future<void> _generatePlan() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      _showMessage('اكتب اسم الطالب أولًا ليظهر على البرنامج وملف PDF.');
      return;
    }
    if (_availableDays.isEmpty) {
      _showMessage('اختر يومًا واحدًا على الأقل للدراسة.');
      return;
    }
    if (_studyEndMinute - _studyStartMinute < _sessionMinutes) {
      _showMessage('الفترة بين بداية الدراسة ونهايتها أقصر من مدة الجلسة. عدّل الوقت أولًا.');
      return;
    }
    final enabled = _subjects.where((s) => s.enabled && s.sessionsPerWeek > 0).toList();
    if (enabled.isEmpty) {
      _showMessage('فعّل مادة واحدة على الأقل وحدد لها جلسات أسبوعية.');
      return;
    }

    await _saveDraft();
    final plan = WeeklyScheduleEngine.generate(
      controller: widget.controller,
      settings: _settings(),
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeeklyPlanPreviewScreen(plan: plan),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _subjectColor(String subject) {
    if (subject.contains('الإنجليزية')) return const Color(0xFF237E74);
    if (subject.contains('الرياضيات')) return const Color(0xFF315FA7);
    if (subject.contains('الكيمياء')) return const Color(0xFFCC7C29);
    if (subject.contains('الفيزياء')) return const Color(0xFF71569C);
    if (subject.contains('الأحياء') || subject.contains('العلوم الحياتية')) return const Color(0xFF4C7F4F);
    return MuwajjehPalette.teal;
  }
}

class WeeklyPlanPreviewScreen extends StatefulWidget {
  const WeeklyPlanPreviewScreen({super.key, required this.plan});

  final WeeklyPlanResult plan;

  @override
  State<WeeklyPlanPreviewScreen> createState() => _WeeklyPlanPreviewScreenState();
}

class _WeeklyPlanPreviewScreenState extends State<WeeklyPlanPreviewScreen> {
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Scaffold(
      appBar: AppBar(title: const Text('برنامجك الأسبوعي')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MuwajjehPalette.navy, MuwajjehPalette.teal],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.settings.studentName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plannerDateLabel(plan.settings.weekStart)} - ${plannerDateLabel(plan.settings.weekStart.add(const Duration(days: 6)))}',
                  style: const TextStyle(color: Color(0xFFDCEBE8)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    plan.quote,
                    style: const TextStyle(color: Colors.white, height: 1.65, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _PlanMetric(value: '${plan.placedStudySessions}', label: 'جلسات موزعة')),
              const SizedBox(width: 8),
              Expanded(child: _PlanMetric(value: '${plan.settings.sessionMinutes}', label: 'دقيقة / جلسة')),
              const SizedBox(width: 8),
              Expanded(child: _PlanMetric(value: '${plan.settings.availableDays.length}', label: 'أيام متاحة')),
            ],
          ),
          if (plan.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF1D7A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ملاحظة قبل اعتماد البرنامج', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  for (final warning in plan.warnings)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $warning', style: const TextStyle(height: 1.55)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text('الأسبوع بنظرة واحدة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final day in plannerDays) _dayPreview(plan, day),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: MuwajjehPalette.tealSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'نصيحة مُوَجِّه: إذا فاتتك جلسة، انقلها إلى أول وقت فارغ. لا تعاقب نفسك بمضاعفة جلسات اليوم التالي.',
              style: TextStyle(height: 1.65, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => WeeklyPlanPdfPreviewScreen(plan: plan)),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('معاينة PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _sharing ? null : _sharePdf,
                  icon: _sharing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.ios_share_outlined),
                  label: Text(_sharing ? 'جاري التجهيز...' : 'تصدير / مشاركة PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayPreview(WeeklyPlanResult plan, WeeklyPlannerDay day) {
    final blocks = plan.blocksForDay(day.index);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: day.index == 5 ? const Color(0xFFF6ECD0) : MuwajjehPalette.tealSoft,
                  child: Text(day.shortLabel.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 10),
                Text(day.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(
                  '${blocks.where((b) => b.kind == PlannerBlockKind.study).length} جلسات',
                  style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (blocks.isEmpty)
              const Text('راحة / لا توجد أنشطة أو جلسات مجدولة.', style: TextStyle(color: MuwajjehPalette.muted))
            else
              for (final block in blocks) _blockTile(block),
          ],
        ),
      ),
    );
  }

  Widget _blockTile(WeeklyPlanBlock block) {
    final study = block.kind == PlannerBlockKind.study;
    final color = study ? _subjectColor(block.subject) : const Color(0xFF8A9499);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(14),
        border: BorderDirectional(start: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              plannerTimeLabel(block.startMinute),
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(study ? block.subject : block.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                if (study && block.reason.isNotEmpty)
                  Text(block.reason, style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 11.5)),
              ],
            ),
          ),
          Text(plannerTimeLabel(block.endMinute), style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _sharePdf() async {
    setState(() => _sharing = true);
    try {
      final bytes = await WeeklySchedulePdfBuilder.build(widget.plan);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'muwajjeh_weekly_plan.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تجهيز PDF الآن: $error')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Color _subjectColor(String subject) {
    if (subject.contains('الإنجليزية')) return const Color(0xFF237E74);
    if (subject.contains('الرياضيات')) return const Color(0xFF315FA7);
    if (subject.contains('الكيمياء')) return const Color(0xFFCC7C29);
    if (subject.contains('الفيزياء')) return const Color(0xFF71569C);
    if (subject.contains('الأحياء') || subject.contains('العلوم الحياتية')) return const Color(0xFF4C7F4F);
    return MuwajjehPalette.teal;
  }
}

class WeeklyPlanPdfPreviewScreen extends StatelessWidget {
  const WeeklyPlanPdfPreviewScreen({super.key, required this.plan});

  final WeeklyPlanResult plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معاينة البرنامج PDF')),
      body: PdfPreview(
        build: (_) => WeeklySchedulePdfBuilder.build(plan),
        pdfFileName: 'muwajjeh_weekly_plan.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'الطالب' : name.trim();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF183B56), Color(0xFF246B67)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اعملي برنامجي', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  '$displayName، أدخل تفاصيل أسبوعك وسأحوّلها إلى خطة واضحة وPDF ملون يمكنك حفظه أو مشاركته.',
                  style: const TextStyle(color: Color(0xFFE1EFED), height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: MuwajjehPalette.tealSoft,
                  child: Icon(Icons.auto_awesome_rounded, color: MuwajjehPalette.teal),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 19, color: MuwajjehPalette.navy),
                          const SizedBox(width: 6),
                          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(subtitle, style: const TextStyle(color: MuwajjehPalette.muted, height: 1.5, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: MuwajjehPalette.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: MuwajjehPalette.navy, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 11)),
        ],
      ),
    );
  }
}
