import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'models.dart';
import 'v4_screens.dart';
import 'v8_screens.dart';
import 'v9_screens.dart';
import 'v10_screens.dart';
import 'v11_screens.dart';
import 'v13_theme.dart';
import 'v14_schedule_screen.dart';

class HomeDashboardV13 extends StatelessWidget {
  const HomeDashboardV13({
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
        final target = controller.nextMasteryTarget;
        final avg = controller.overallExamAverage;
        final focusProgress = profile.dailyGoalMinutes == 0
            ? 0.0
            : (controller.todayFocusMinutes / profile.dailyGoalMinutes).clamp(0.0, 1.0).toDouble();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              _WelcomePanel(
                name: profile.name,
                subtitle: '${profile.gradeYear} • ${profile.branch}',
                progress: focusProgress,
                focusLabel: '${controller.todayFocusMinutes}/${profile.dailyGoalMinutes} دقيقة تركيز اليوم',
              ),
              const SizedBox(height: 18),
              _TodayCard(
                title: target == null ? 'لنبدأ بقياس مستواك' : 'أولوية اليوم: ${target.skill}',
                body: target == null
                    ? 'نفّذ اختبارًا قصيرًا. بعد أولى المحاولات سيحدد مُوَجِّه بدقة ما الذي يحتاج إلى مراجعة.'
                    : '${target.subject} • ${target.lesson}\n${target.reason}',
                onTap: target == null ? () => onNavigate(2) : () => _openSmartTutor(context),
              ),
              const SizedBox(height: 16),
              _ProgramSpotlightV14(
                name: profile.name,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MyWeeklyProgramScreen(controller: controller),
                  ));
                },
              ),
              const SizedBox(height: 22),
              const _SectionTitle(title: 'خدماتك', subtitle: 'كل ما تحتاجه من أول شاشة'),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.28,
                children: [
                  _ServiceTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'اسأل مُوَجِّه',
                    subtitle: 'استشارة دراسية مباشرة',
                    accent: MuwajjehPalette.teal,
                    onTap: () => onNavigate(1),
                  ),
                  _ServiceTile(
                    icon: Icons.fact_check_outlined,
                    title: 'محاكاة وزارية',
                    subtitle: '50 سؤالًا بنمط 2026',
                    accent: MuwajjehPalette.navy,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MinisterialMockSetupScreenV11(controller: controller),
                      ));
                    },
                  ),
                  _ServiceTile(
                    icon: Icons.psychology_alt_outlined,
                    title: 'المعلم الذكي',
                    subtitle: 'شرح من الصفر وعلاج الخطأ',
                    accent: const Color(0xFF7A5C9E),
                    onTap: () => _openSmartTutor(context),
                  ),
                  _ServiceTile(
                    icon: Icons.route_outlined,
                    title: 'مساري الشخصي',
                    subtitle: 'فهم ← تدريب ← تحقق',
                    accent: const Color(0xFFB66A36),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LearningPathScreen(
                          controller: controller,
                          launchExam: (ctx, exam) {
                            Navigator.of(ctx).push(MaterialPageRoute(
                              builder: (_) => AdaptiveQuizScreen(
                                controller: controller,
                                exam: exam,
                                timed: false,
                              ),
                            ));
                          },
                        ),
                      ));
                    },
                  ),
                  _ServiceTile(
                    icon: Icons.donut_large_outlined,
                    title: 'خريطة الإتقان',
                    subtitle: 'وحدة ودرس ومهارة',
                    accent: const Color(0xFF3F7C92),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MasteryDashboardScreen(controller: controller),
                      ));
                    },
                  ),
                  _ServiceTile(
                    icon: Icons.timer_outlined,
                    title: 'التركيز',
                    subtitle: 'جلسة دراسة بلا تشتيت',
                    accent: const Color(0xFF56714E),
                    onTap: () => onNavigate(4),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle(title: 'نبضة الأداء', subtitle: 'صورة سريعة دون إغراقك بالأرقام'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _CompactMetric(value: '${controller.examResults.length}', label: 'اختبارات')),
                  const SizedBox(width: 10),
                  Expanded(child: _CompactMetric(value: avg == null ? '—' : '${avg.round()}%', label: 'المتوسط')),
                  const SizedBox(width: 10),
                  Expanded(child: _CompactMetric(value: '${controller.questionAttempts.length}', label: 'محاولات')),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: const CircleAvatar(
                    backgroundColor: MuwajjehPalette.tealSoft,
                    child: Icon(Icons.map_outlined, color: MuwajjehPalette.teal),
                  ),
                  title: const Text('الخريطة الكاملة للمنهاج', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('شاهد الدروس المقاسة وغير المقاسة وتطورك عبر الوقت.'),
                  trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CurriculumProgressMapScreen(controller: controller),
                    ));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSmartTutor(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SmartTutorScreen(
        controller: controller,
        launchExam: (ctx, exam) {
          Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => AdaptiveQuizScreen(
              controller: controller,
              exam: exam,
              timed: false,
            ),
          ));
        },
      ),
    ));
  }
}


class _ProgramSpotlightV14 extends StatelessWidget {
  const _ProgramSpotlightV14({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF183B56), Color(0xFF1F7A74)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x14183B56), blurRadius: 22, offset: Offset(0, 9)),
          ],
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
                  const Row(
                    children: [
                      Text('اعملي برنامجي', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                      SizedBox(width: 7),
                      Icon(Icons.auto_awesome_rounded, color: MuwajjehPalette.sand, size: 19),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$name، أدخل أنشطتك وموادك واحصل على برنامج أسبوعي ذكي + PDF ملون.',
                    style: const TextStyle(color: Color(0xFFE4F0EE), height: 1.5, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
          ],
        ),
      ),
    );
  }
}

class AdvisorHubV13 extends StatefulWidget {
  const AdvisorHubV13({super.key, required this.controller});

  final AppController controller;

  @override
  State<AdvisorHubV13> createState() => _AdvisorHubV13State();
}

class _AdvisorHubV13State extends State<AdvisorHubV13> {
  final _questionController = TextEditingController();
  late String _subject;
  AdvisorAnswerV13? _answer;

  @override
  void initState() {
    super.initState();
    final subjects = widget.controller.profile?.subjects ?? const <String>[];
    _subject = subjects.isEmpty ? 'اللغة الإنجليزية' : subjects.first;
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _ask([String? quickPrompt]) {
    if (quickPrompt != null) _questionController.text = quickPrompt;
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _answer = AdvisorEngineV13.answer(
        controller: widget.controller,
        subject: _subject,
        question: text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.controller.profile?.subjects ?? const ['اللغة الإنجليزية'];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MuwajjehPalette.navy,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, color: MuwajjehPalette.sand, size: 30),
                SizedBox(height: 10),
                Text('اسأل مُوَجِّه', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text(
                  'اكتب مشكلتك كما هي. سأربط نصيحتك بأدائك الفعلي، وأعطيك قرارًا واضحًا لما تفعله الآن.',
                  style: TextStyle(color: Color(0xFFDDE7EC), height: 1.65, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('المبحث', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<String>(
                    value: subjects.contains(_subject) ? _subject : subjects.first,
                    items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _subject = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _questionController,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      hintText: 'مثال: أفهم الدرس، لكن عندما تتغير صياغة السؤال أختار إجابة قريبة وأخطئ. ماذا أفعل؟',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _ask,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('حلّل المشكلة وأجبني'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('أسئلة سريعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickPrompt(text: 'ماذا أدرس اليوم؟', onTap: () => _ask('ماذا أدرس اليوم؟')),
              _QuickPrompt(text: 'لماذا أخطئ رغم أنني أفهم؟', onTap: () => _ask('لماذا أخطئ رغم أنني أفهم؟')),
              _QuickPrompt(text: 'كيف أرفع سرعة الحل؟', onTap: () => _ask('كيف أرفع سرعة الحل؟')),
              _QuickPrompt(text: 'هل أنا جاهز للامتحان؟', onTap: () => _ask('هل أنا جاهز للامتحان؟')),
              _QuickPrompt(text: 'عندي تراكم، من أين أبدأ؟', onTap: () => _ask('عندي تراكم، من أين أبدأ؟')),
              _QuickPrompt(text: 'أنسى بعد الدراسة، ماذا أفعل؟', onTap: () => _ask('أنسى بعد الدراسة، ماذا أفعل؟')),
              _QuickPrompt(text: 'أتوتر في الامتحان', onTap: () => _ask('أتوتر في الامتحان')),
            ],
          ),
          if (_answer != null) ...[
            const SizedBox(height: 18),
            AdvisorAnswerCardV13(answer: _answer!, controller: widget.controller),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0DDB2)),
            ),
            child: const Text(
              'في الشرح الأكاديمي: المرجع الأول دائمًا هو كتاب الطالب/التمارين الرسمي. ويُستخدم أي مصدر تعليمي إضافي لتبسيط الفكرة أو إعطاء مثال آخر، لا لاستبدال المنهاج.',
              style: TextStyle(height: 1.6, color: Color(0xFF775516), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvisorAnswerCardV13 extends StatelessWidget {
  const AdvisorAnswerCardV13({super.key, required this.answer, required this.controller});

  final AdvisorAnswerV13 answer;
  final AppController controller;

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
                const CircleAvatar(
                  backgroundColor: MuwajjehPalette.tealSoft,
                  child: Icon(Icons.psychology_alt_outlined, color: MuwajjehPalette.teal),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(answer.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 14),
            Text(answer.directAnswer, style: const TextStyle(fontSize: 16, height: 1.7, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _AdvisorSection(title: 'لماذا أقول ذلك؟', icon: Icons.insights_outlined, text: answer.reason),
            const SizedBox(height: 10),
            _AdvisorSection(title: 'افعل هذا الآن', icon: Icons.playlist_add_check_circle_outlined, text: answer.actionNow),
            const SizedBox(height: 10),
            _AdvisorSection(title: 'في الجلسة القادمة', icon: Icons.next_plan_outlined, text: answer.nextStep),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(answer.attempts == 0 ? 'الإتقان: غير مقاس' : 'إتقان ${answer.mastery.round()}%')),
                Chip(label: Text(answer.attempts == 0 ? 'الثقة: لا بيانات' : 'ثقة ${answer.confidence.round()}%')),
                Chip(label: Text('${answer.attempts} محاولة')),
              ],
            ),
            if (answer.openTutor) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SmartTutorScreen(
                      controller: controller,
                      launchExam: (ctx, exam) {
                        Navigator.of(ctx).push(MaterialPageRoute(
                          builder: (_) => AdaptiveQuizScreen(
                            controller: controller,
                            exam: exam,
                            timed: false,
                          ),
                        ));
                      },
                    ),
                  ));
                },
                icon: const Icon(Icons.school_outlined),
                label: const Text('افتح المعلم الذكي للشرح'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdvisorAnswerV13 {
  const AdvisorAnswerV13({
    required this.title,
    required this.directAnswer,
    required this.reason,
    required this.actionNow,
    required this.nextStep,
    required this.mastery,
    required this.confidence,
    required this.attempts,
    this.openTutor = false,
  });

  final String title;
  final String directAnswer;
  final String reason;
  final String actionNow;
  final String nextStep;
  final double mastery;
  final double confidence;
  final int attempts;
  final bool openTutor;
}

abstract final class AdvisorEngineV13 {
  static AdvisorAnswerV13 answer({
    required AppController controller,
    required String subject,
    required String question,
  }) {
    final mastery = controller.masteryForSubject(subject);
    final weakUnit = controller.topWeakUnitForSubject(subject);
    final lower = question.toLowerCase();
    final weakSkills = controller.masteryBySkill(subject: subject);
    final weakSkill = weakSkills.isEmpty ? null : weakSkills.first;

    if (_containsAny(lower, ['اشرح', 'ما معنى', 'ما هو', 'كيف أحل', 'قاعدة', 'قانون', 'درس'])) {
      return AdvisorAnswerV13(
        title: 'نشرحها من المصدر الصحيح',
        directAnswer: 'هذا سؤال شرح، لذلك لن أعطيك نصيحة عامة. افتح المعلم الذكي؛ سيبدأ من كتابك الرسمي، ويعرض الصفحة المتحققة ثم يشرح الفكرة كأنك تراها لأول مرة.',
        reason: weakSkill == null
            ? 'لا توجد محاولات كافية لتحديد موضع الضعف بدقة، ولذلك نبدأ من شرح المفهوم ثم نقيسه.'
            : 'أضعف مهارة مقاسة حاليًا هي ${weakSkill.skill} في ${weakSkill.lesson} بدرجة ${weakSkill.score.round()}%.',
        actionNow: 'اقرأ الشرح المبسط، لا تحفظ المثال. بعده حل سؤال تحقق واحد ثم 5 أسئلة علاجية.',
        nextStep: 'إذا تجاوز الإتقان 80% انتقل للمهارة التالية؛ وإلا يعاد الشرح بمثال مختلف.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
        openTutor: true,
      );
    }

    if (_containsAny(lower, ['سرعة', 'بطيء', 'الوقت', 'ما بلحق', 'لا ألحق'])) {
      return AdvisorAnswerV13(
        title: 'السرعة تأتي بعد ثبات الخطوات',
        directAnswer: 'لا تحاول حل السؤال أسرع الآن. قلّل زمن التردد بين الخطوات: حدّد المطلوب، سمِّ القاعدة، ثم ابدأ. السرعة الناتجة عن التخمين سترفع أخطاءك.',
        reason: 'متوسط إتقانك في $subject هو ${mastery.score.round()}% بثقة ${mastery.confidence.round()}%. ${weakUnit == null ? 'نحتاج قياسًا إضافيًا لتحديد الوحدة الأبطأ.' : 'الوحدة التي تتكرر فيها الأخطاء أكثر: $weakUnit.'}',
        actionNow: 'حل 5 أسئلة فقط. أعطِ كل سؤال زمنًا ثابتًا، وسجل أين ضاع الوقت: فهم المطلوب، اختيار القاعدة، أم الحساب/القراءة.',
        nextStep: 'أعد نفس المهارة في جلسة لاحقة بزمن أقل 10% فقط، بشرط ألا تنخفض الدقة.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
      );
    }

    if (_containsAny(lower, ['تراكم', 'متراكم', 'متأخر', 'من أين أبدأ'])) {
      return AdvisorAnswerV13(
        title: 'لا تبدأ من أول الكتاب تلقائيًا',
        directAnswer: weakSkill == null
            ? 'قس مستواك أولًا باختبار قصير، ثم ابدأ بأضعف وحدة بدل إعادة كل شيء من البداية.'
            : 'ابدأ اليوم بـ ${weakSkill.lesson}، وتحديدًا مهارة ${weakSkill.skill}. هذه أولوية أعلى من فتح عدة وحدات في جلسة واحدة.',
        reason: 'التراكم يُحل بالترتيب حسب الأثر، لا حسب عدد الصفحات. مُوَجِّه يرتب الأولويات من نتائجك الفعلية.',
        actionNow: '20 دقيقة فهم + 25 دقيقة أسئلة + 10 دقائق مراجعة أخطاء. توقف بعد هذا الهدف حتى لو بقي وقت.',
        nextStep: 'غدًا أعد اختبار تحقق قصير؛ إذا تحسنت المهارة انتقل للهدف التالي في خريطة الإتقان.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
        openTutor: weakSkill != null,
      );
    }

    if (_containsAny(lower, ['أنسى', 'انسى', 'حفظ', 'تذكر', 'ذاكرة'])) {
      return AdvisorAnswerV13(
        title: 'المشكلة ليست في إعادة القراءة',
        directAnswer: 'إذا كنت تنسى بعد الدراسة، غيّر طريقة المراجعة من «قراءة» إلى «استرجاع». أغلق الكتاب وحاول إنتاج المعلومة من ذاكرتك، ثم افتح المرجع وصحح الناقص.',
        reason: 'الاسترجاع يكشف ما تعرفه فعلًا. إعادة قراءة الصفحة تعطي شعورًا بالألفة لكنها لا تضمن أنك تستطيع استدعاء المعلومة في سؤال.',
        actionNow: 'بعد 15 دقيقة دراسة، أغلق المصدر واكتب 5 نقاط من الذاكرة. بعد ذلك حل 3 أسئلة MCQ دون الرجوع للشرح.',
        nextStep: 'أعد اختبار الاسترجاع غدًا ثم بعد ثلاثة أيام. إذا بقي الخطأ في نفس الفكرة، افتح المعلم الذكي وأعد بناء المفهوم من الصفر.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
        openTutor: weakSkill != null,
      );
    }

    if (_containsAny(lower, ['توتر', 'قلق', 'خوف', 'ارتبك', 'ارتباك'])) {
      return AdvisorAnswerV13(
        title: 'درّب الأداء تحت الزمن، لا المعرفة فقط',
        directAnswer: 'التوتر لا يُعالج بزيادة ساعات الدراسة وحدها. تحتاج إلى محاكاة تدريجية تجعل شكل الامتحان والزمن مألوفين لك.',
        reason: 'عندما يكون شكل السؤال والزمن مألوفين يقل الجزء المفاجئ من التجربة. سنفصل بين خطأ المعرفة وخطأ الضغط من نتائج المحاكاة.',
        actionNow: 'ابدأ بـ10 أسئلة تحت زمن محدد. قبل البدء خذ دقيقة لتنظيم التنفس، ثم لا توقف المؤقت أثناء الحل.',
        nextStep: 'إذا حافظت على الدقة، ارفع المحاكاة إلى 25 ثم 50 سؤالًا. إذا انخفضت الدقة فقط تحت الزمن، يكون العلاج في إدارة الاختبار لا في إعادة المنهج كاملًا.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
      );
    }

    if (_containsAny(lower, ['كم ساعة', 'كم ادرس', 'كم أدرس', 'ساعات الدراسة', 'وقت الدراسة'])) {
      final goal = controller.profile?.dailyGoalMinutes ?? 120;
      return AdvisorAnswerV13(
        title: 'الجودة أهم من عدد الساعات',
        directAnswer: 'هدفك الحالي في التطبيق ${goal} دقيقة يوميًا. لا أرفع هذا الرقم تلقائيًا؛ أولًا أريد أن تكون كل جلسة لها هدف قابل للقياس.',
        reason: 'الوقت وحده لا يخبرنا أنك تعلمت. الإتقان الحالي في $subject هو ${mastery.score.round()}%، لذلك القرار الأفضل هو ربط الوقت بتحسن هذه النسبة.',
        actionNow: 'قسّم هدفك إلى جلسات 40–50 دقيقة. لكل جلسة: مفهوم واحد + أسئلة + مراجعة خطأ.',
        nextStep: 'إذا أكملت الهدف لعدة أيام دون إرهاق وكانت النتائج تتحسن، يمكن زيادة الوقت تدريجيًا 15–20 دقيقة.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
      );
    }

    if (_containsAny(lower, ['جاهز', 'امتحان', 'مستعد'])) {
      final ready = mastery.attempts >= 10 && mastery.score >= 80 && mastery.confidence >= 55;
      return AdvisorAnswerV13(
        title: ready ? 'مؤشراتك جيدة، لكن اختبر الثبات' : 'لا أعطيك حكم جاهزية بعد',
        directAnswer: ready
            ? 'أنت قريب من مستوى جيد في $subject. الخطوة الصحيحة الآن هي محاكاة وزارية كاملة، لا مزيد من الأسئلة السهلة.'
            : 'البيانات الحالية لا تكفي لأقول إنك جاهز. الجاهزية تعني دقة جيدة مع عدد محاولات كافٍ وفي أسئلة متفاوتة الصعوبة.',
        reason: 'الإتقان الحالي ${mastery.score.round()}%، الثقة ${mastery.confidence.round()}%، وعدد المحاولات ${mastery.attempts}.',
        actionNow: ready ? 'نفّذ محاكاة 50 سؤالًا تحت الزمن.' : 'نفّذ اختبارًا متوسطًا ثم عالج أضعف مهارتين قبل المحاكاة الكاملة.',
        nextStep: 'بعد المحاكاة قارن أداء أسئلة الكتاب مع أسئلة نقل الفهم، وليس النتيجة الكلية فقط.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
      );
    }

    if (_containsAny(lower, ['أخطئ', 'اخطئ', 'غلط', 'أفهم', 'افهم'])) {
      return AdvisorAnswerV13(
        title: 'غالبًا المشكلة في نقل الفهم إلى السؤال',
        directAnswer: 'إذا كنت تفهم الشرح ثم تخطئ عند تغير الصياغة، لا تعد قراءة الدرس كاملًا. درّب نفسك على اكتشاف الدليل الذي يغيّر الإجابة بين خيارين متقاربين.',
        reason: weakSkill == null
            ? 'لا يوجد سجل كافٍ بعد لتحديد نوع الخطأ، لذلك نحتاج مجموعة قصيرة تشخيصية.'
            : 'البيانات تشير أولًا إلى ${weakSkill.skill} في ${weakSkill.lesson} (${weakSkill.score.round()}%).',
        actionNow: 'في كل سؤال اكتب قبل الإجابة: «ما الكلمة/المعطى الذي يحسم الاختيار؟». ثم فسّر لماذا ثلاثة خيارات غير صحيحة.',
        nextStep: 'بعد 5 أسئلة، افتح المعلم الذكي لأضعف مهارة فقط؛ لا تراجع جميع الدرس.',
        mastery: mastery.score,
        confidence: mastery.confidence,
        attempts: mastery.attempts,
        openTutor: weakSkill != null,
      );
    }

    return AdvisorAnswerV13(
      title: 'خطة اليوم في $subject',
      directAnswer: weakSkill == null
          ? 'ابدأ بقياس قصير؛ لا أريد أن أحدد لك مراجعة عشوائية قبل أن أرى كيف تجيب.'
          : 'ابدأ بـ ${weakSkill.lesson} — ${weakSkill.skill}. هذه هي أضعف نقطة مقاسة حاليًا.',
      reason: weakSkill == null
          ? 'لا توجد محاولات أسئلة كافية في هذا المبحث.'
          : 'درجة هذه المهارة ${weakSkill.score.round()}%، بينما القرار مبني على محاولاتك وليس على ترتيب الدروس فقط.',
      actionNow: 'راجع مفهومًا واحدًا ثم حل 5 أسئلة متدرجة. لا تفتح موضوعًا ثانيًا قبل اختبار التحقق.',
      nextStep: 'إذا وصلت 80% أو أكثر مع ثقة مناسبة، انتقل إلى المهارة التالية في الخريطة.',
      mastery: mastery.score,
      confidence: mastery.confidence,
      attempts: mastery.attempts,
      openTutor: weakSkill != null,
    );
  }

  static bool _containsAny(String value, List<String> words) {
    for (final word in words) {
      if (value.contains(word)) return true;
    }
    return false;
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.name,
    required this.subtitle,
    required this.progress,
    required this.focusLabel,
  });

  final String name;
  final String subtitle;
  final double progress;
  final String focusLabel;

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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مُوَجِّهك اليوم', style: TextStyle(color: Color(0xFFCFE1E4), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('مرحبًا، $name', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFFDCE8EC))),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0x33FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(MuwajjehPalette.sand),
            ),
          ),
          const SizedBox(height: 7),
          Text(focusLabel, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.title, required this.body, required this.onTap});
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: MuwajjehPalette.tealSoft, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.track_changes_rounded, color: MuwajjehPalette.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(body, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MuwajjehPalette.muted, height: 1.55)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: MuwajjehPalette.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.icon, required this.title, required this.subtitle, required this.accent, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MuwajjehPalette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(color: accent.withOpacity(0.11), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MuwajjehPalette.muted, fontSize: 11.5, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MuwajjehPalette.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: MuwajjehPalette.navy)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11.5, color: MuwajjehPalette.muted, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
        Text(subtitle, style: const TextStyle(fontSize: 11.5, color: MuwajjehPalette.muted)),
      ],
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  const _QuickPrompt({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: const Icon(Icons.bolt_rounded, size: 17, color: MuwajjehPalette.teal),
      label: Text(text),
    );
  }
}

class _AdvisorSection extends StatelessWidget {
  const _AdvisorSection({required this.title, required this.icon, required this.text});
  final String title;
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MuwajjehPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 19, color: MuwajjehPalette.teal), const SizedBox(width: 7), Text(title, style: const TextStyle(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 7),
          Text(text, style: const TextStyle(height: 1.6)),
        ],
      ),
    );
  }
}
