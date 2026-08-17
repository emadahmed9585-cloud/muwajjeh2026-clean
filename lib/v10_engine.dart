import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'curriculum_data.dart';
import 'v6_curriculum_data.dart';
import 'exam_data.dart';
import 'models.dart';

class V10TutorEngine {
  const V10TutorEngine(this.controller);

  final AppController controller;

  LearningPathRecord? get activePath => controller.activeLearningPath;

  MistakeRecord? latestMistakeFor({
    required String subject,
    required String unit,
    required String lesson,
    required String skill,
  }) {
    for (final mistake in controller.mistakes) {
      if (mistake.subject == subject &&
          mistake.unit == unit &&
          mistake.lesson == lesson &&
          (mistake.skill == skill || skill.isEmpty)) {
        return mistake;
      }
    }
    for (final mistake in controller.mistakes) {
      if (mistake.subject == subject &&
          mistake.unit == unit &&
          mistake.lesson == lesson) {
        return mistake;
      }
    }
    return null;
  }

  TutorAdvice adviceFor({
    required String subject,
    required String unit,
    required String lesson,
    required String skill,
  }) {
    final mistake = latestMistakeFor(
      subject: subject,
      unit: unit,
      lesson: lesson,
      skill: skill,
    );
    final recordedErrorType = mistake?.errorType;
    final errorType = recordedErrorType == null || recordedErrorType == 'غير مصنف'
        ? classifyErrorType(skill)
        : recordedErrorType;
    final mastery = controller.masteryForAttempts(
      controller.questionAttempts.where((a) =>
          a.subject == subject &&
          a.unit == unit &&
          a.lesson == lesson &&
          a.skill == skill),
      subject: subject,
      unit: unit,
      lesson: lesson,
      skill: skill,
    );
    final difficulty = _recommendedDifficulty(mastery.score, mastery.attempts);

    switch (errorType) {
      case 'خطأ حسابي/إجرائي':
        return TutorAdvice(
          subject: subject,
          unit: unit,
          lesson: lesson,
          skill: skill,
          errorType: errorType,
          title: 'ثبّت خطوات الحل قبل زيادة السرعة',
          diagnosis:
              'النمط يشير إلى أن الفكرة قد تكون معروفة، لكن التنفيذ أو ترتيب الخطوات أو التعويض يسبب فقدان العلامة.',
          microLesson:
              'حوّل كل سؤال إلى أربع خانات ثابتة: المعطيات → العلاقة/القاعدة → التعويض أو الإجراء → فحص النتيجة. لا تبدأ الحساب قبل كتابة ما الذي يطلبه السؤال.',
          strategySteps: const [
            'اكتب المطلوب في سطر مستقل قبل الحل.',
            'حدد القانون أو القاعدة التي تربط المعطيات بالمطلوب.',
            'نفّذ خطوة واحدة في كل سطر وتحقق من الإشارة والوحدة.',
            'قدّر النتيجة منطقيًا قبل اختيار الإجابة.',
          ],
          selfCheckQuestions: const [
            'هل استخدمت كل المعطيات الضرورية فقط؟',
            'هل الإشارة والوحدة أو شكل الناتج منطقي؟',
            'هل يمكنني تحديد السطر الذي حدث فيه الخطأ إن كانت النتيجة غير صحيحة؟',
          ],
          recommendedDifficulty: difficulty,
          lastMistakeExplanation: mistake?.explanation ?? '',
        );
      case 'خطأ لغوي':
        return TutorAdvice(
          subject: subject,
          unit: unit,
          lesson: lesson,
          skill: skill,
          errorType: errorType,
          title: 'اقرأ الإشارة اللغوية قبل الخيارات',
          diagnosis:
              'الخطأ يرتبط باختيار صيغة أو كلمة أو وظيفة لغوية؛ وغالبًا يُحل بتحديد الإشارة في السياق قبل النظر إلى المشتتات.',
          microLesson:
              'لا تبدأ من الخيارات. حدّد أولًا: الزمن أو الوظيفة أو معنى السياق، ثم توقع شكل الإجابة، وبعد ذلك قارن توقعك بالخيارات.',
          strategySteps: const [
            'ضع خطًا تحت كلمة الزمن أو الرابط أو القرينة الدلالية.',
            'سمِّ القاعدة أو الوظيفة المطلوبة بكلمة واحدة.',
            'استبعد خيارين لا ينسجمان مع البنية قبل المفاضلة النهائية.',
            'أعد قراءة الجملة كاملة بالإجابة المختارة.',
          ],
          selfCheckQuestions: const [
            'ما القرينة التي جعلتني أختار هذه الصيغة؟',
            'هل الإجابة صحيحة نحويًا ودلاليًا معًا؟',
            'لماذا الخيار الأقرب الآخر خطأ؟',
          ],
          recommendedDifficulty: difficulty,
          lastMistakeExplanation: mistake?.explanation ?? '',
        );
      case 'خطأ استدلالي':
        return TutorAdvice(
          subject: subject,
          unit: unit,
          lesson: lesson,
          skill: skill,
          errorType: errorType,
          title: 'اربط كل استنتاج بدليل',
          diagnosis:
              'المشكلة ليست تذكر المعلومة فقط، بل الانتقال من المعطيات إلى النتيجة دون خطوة استدلال واضحة.',
          microLesson:
              'قبل اختيار الإجابة، اكتب في ذهنك جملة قصيرة: «لأن المعطى X، إذن النتيجة Y». إذا لم تستطع كتابة لأن/إذن، فالاستنتاج ما زال غير مثبت.',
          strategySteps: const [
            'افصل الحقائق المعطاة عن الاستنتاج المطلوب.',
            'ابحث عن العلاقة السببية أو الشرطية بينهما.',
            'اختبر كل خيار: هل تدعمه المعطيات أم يضيف افتراضًا جديدًا؟',
            'اختر الخيار الذي يحتاج أقل افتراضات خارج السؤال.',
          ],
          selfCheckQuestions: const [
            'ما الدليل المباشر على اختياري؟',
            'هل أضفت معلومة غير موجودة في السؤال؟',
            'هل يوجد خيار صحيح جزئيًا لكنه لا يجيب المطلوب؟',
          ],
          recommendedDifficulty: difficulty,
          lastMistakeExplanation: mistake?.explanation ?? '',
        );
      case 'خطأ تطبيقي':
        return TutorAdvice(
          subject: subject,
          unit: unit,
          lesson: lesson,
          skill: skill,
          errorType: errorType,
          title: 'حدّد شرط استخدام القاعدة أولًا',
          diagnosis:
              'يبدو أن القاعدة معروفة، لكن اختيار وقت استخدامها أو نقلها إلى موقف جديد هو موضع الضعف.',
          microLesson:
              'لكل قاعدة ثلاثة أجزاء: ماذا تقول؟ متى تنطبق؟ ما الذي يمنع تطبيقها؟ اربط السؤال بهذه الأجزاء قبل الحل.',
          strategySteps: const [
            'سمِّ المفهوم أو القاعدة التي يبدو أن السؤال يستهدفها.',
            'تحقق من شروط انطباقها على الحالة المعطاة.',
            'طبّقها على المعطيات فقط، لا على حالة محفوظة من مثال سابق.',
            'قارن النتيجة بالسلوك المتوقع للمفهوم.',
          ],
          selfCheckQuestions: const [
            'ما شرط تطبيق هذه القاعدة؟',
            'ما الشيء المختلف بين هذا السؤال والمثال المحفوظ؟',
            'هل النتيجة تتفق مع اتجاه أو معنى المفهوم؟',
          ],
          recommendedDifficulty: difficulty,
          lastMistakeExplanation: mistake?.explanation ?? '',
        );
      default:
        return TutorAdvice(
          subject: subject,
          unit: unit,
          lesson: lesson,
          skill: skill,
          errorType: 'خطأ مفاهيمي',
          title: 'أعد بناء حدود المفهوم',
          diagnosis:
              'النمط يشير إلى خلط في معنى المفهوم أو حدوده، لذلك زيادة عدد الأسئلة وحدها لن تكون كافية قبل تثبيت الفكرة.',
          microLesson:
              'عرّف المفهوم بجملة قصيرة، ثم اكتب مثالًا ينتمي إليه ومثالًا مضادًا لا ينتمي إليه. الفرق بين المثالين هو أهم جزء في العلاج.',
          strategySteps: const [
            'اكتب تعريفًا من سطر واحد دون نسخ حرفي.',
            'قارن المفهوم بأقرب مفهوم يختلط به عادة.',
            'اكتب مثالًا صحيحًا ومثالًا مضادًا.',
            'بعد ذلك فقط انتقل إلى أسئلة الاختيار من متعدد.',
          ],
          selfCheckQuestions: const [
            'ما الخاصية التي لا يمكن حذفها من تعريف المفهوم؟',
            'ما الفرق بينه وبين أقرب مفهوم مشابه؟',
            'هل أستطيع ابتكار مثال جديد من عندي؟',
          ],
          recommendedDifficulty: difficulty,
          lastMistakeExplanation: mistake?.explanation ?? '',
        );
    }
  }

  TutorAdvice adviceForPath(LearningPathRecord path) => adviceFor(
        subject: path.subject,
        unit: path.unit,
        lesson: path.lesson,
        skill: path.skill,
      );

  String _recommendedDifficulty(double score, int attempts) {
    if (attempts < 2 || score < 45) return 'سهل';
    if (score < 65) return 'متوسط';
    if (score < 82) return 'صعب';
    return 'متقدم';
  }

  List<ExamQuestion> remedialQuestionsForPath(
    LearningPathRecord path, {
    int count = 5,
  }) {
    final mastery = controller.masteryForAttempts(
      controller.questionAttempts.where((a) =>
          a.subject == path.subject &&
          a.unit == path.unit &&
          a.lesson == path.lesson &&
          a.skill == path.skill),
      subject: path.subject,
      unit: path.unit,
      lesson: path.lesson,
      skill: path.skill,
    );
    final targetDifficulty = _recommendedDifficulty(mastery.score, mastery.attempts);
    final recentIds = controller.questionAttempts
        .where((a) => a.subject == path.subject)
        .take(18)
        .map((a) => a.questionId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final exactSkill = allBankQuestions.where((q) =>
        q.subject == path.subject &&
        q.unit == path.unit &&
        q.lesson == path.lesson &&
        q.skill == path.skill);
    final exactLesson = allBankQuestions.where((q) =>
        q.subject == path.subject && q.unit == path.unit && q.lesson == path.lesson);
    final sameUnit = allBankQuestions.where(
        (q) => q.subject == path.subject && q.unit == path.unit);

    final merged = <ExamQuestion>[];
    final seen = <String>{};
    void append(Iterable<ExamQuestion> source) {
      for (final q in source) {
        final key = q.id.isEmpty ? q.text : q.id;
        if (seen.add(key)) merged.add(q);
      }
    }

    append(exactSkill);
    append(exactLesson);
    append(sameUnit);

    int difficultyRank(String difficulty) {
      switch (difficulty) {
        case 'سهل':
          return 0;
        case 'متوسط':
          return 1;
        case 'صعب':
          return 2;
        case 'متقدم':
          return 3;
        default:
          return 1;
      }
    }

    final targetRank = difficultyRank(targetDifficulty);
    merged.sort((a, b) {
      final aRecent = recentIds.contains(a.id) ? 1 : 0;
      final bRecent = recentIds.contains(b.id) ? 1 : 0;
      if (aRecent != bRecent) return aRecent.compareTo(bRecent);
      final aDist = (difficultyRank(a.difficulty) - targetRank).abs();
      final bDist = (difficultyRank(b.difficulty) - targetRank).abs();
      if (aDist != bDist) return aDist.compareTo(bDist);
      return a.text.compareTo(b.text);
    });

    final selected = merged.take(math.min(count, merged.length)).toList();
    return selected;
  }

  ExamDefinition? buildRemedialExam(LearningPathRecord path) {
    final questions = remedialQuestionsForPath(path, count: 5);
    if (questions.length < 3) return null;
    final advice = adviceForPath(path);
    return ExamDefinition(
      title: 'علاج ذكي V10 • ${path.skill} • ${path.id}',
      subtitle: 'مجموعة علاجية منتقاة بعد تشخيص ${advice.errorType}.',
      subject: path.subject,
      icon: _iconForSubject(path.subject),
      questions: questions,
      unit: path.unit,
      difficulty: advice.recommendedDifficulty,
      durationMinutes: 12,
      examType: 'tutor_remedial',
    );
  }

  List<CurriculumProgressNode> progressNodesForSubject(String subject) {
    final output = <CurriculumProgressNode>[];
    final units = allCurriculumUnits.where((u) => u.subject == subject).toList();

    for (final unit in units) {
      for (final lesson in unit.lessons) {
        final questions = allBankQuestions.where((q) =>
            q.subject == subject && q.unit == unit.title && q.lesson == lesson).toList();
        final skills = questions.map((q) => q.skill).where((s) => s.isNotEmpty).toSet();
        if (skills.isEmpty) {
          final attempts = controller.questionAttempts.where((a) =>
              a.subject == subject && a.unit == unit.title && a.lesson == lesson);
          final metric = controller.masteryForAttempts(
            attempts,
            subject: subject,
            unit: unit.title,
            lesson: lesson,
          );
          output.add(CurriculumProgressNode(
            subject: subject,
            unit: unit.title,
            lesson: lesson,
            skill: 'عام',
            score: metric.score,
            confidence: metric.confidence,
            attempts: metric.attempts,
            trend: _trendForAttempts(attempts.toList()),
            questionCount: questions.length,
          ));
          continue;
        }

        for (final skill in skills) {
          final attempts = controller.questionAttempts.where((a) =>
              a.subject == subject &&
              a.unit == unit.title &&
              a.lesson == lesson &&
              a.skill == skill);
          final metric = controller.masteryForAttempts(
            attempts,
            subject: subject,
            unit: unit.title,
            lesson: lesson,
            skill: skill,
          );
          output.add(CurriculumProgressNode(
            subject: subject,
            unit: unit.title,
            lesson: lesson,
            skill: skill,
            score: metric.score,
            confidence: metric.confidence,
            attempts: metric.attempts,
            trend: _trendForAttempts(attempts.toList()),
            questionCount: questions.where((q) => q.skill == skill).length,
          ));
        }
      }
    }
    return output;
  }

  double _trendForAttempts(List<QuestionAttemptRecord> attempts) {
    if (attempts.length < 4) return 0;
    final ordered = [...attempts]..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    final split = ordered.length ~/ 2;
    final earlier = ordered.take(split).toList();
    final later = ordered.skip(split).toList();
    if (earlier.isEmpty || later.isEmpty) return 0;
    final first = controller.masteryForAttempts(earlier).score;
    final second = controller.masteryForAttempts(later).score;
    return second - first;
  }

  List<MasteryTrendPoint> masteryTimelineForSubject(String subject) {
    final ordered = controller.questionAttempts
        .where((a) => a.subject == subject)
        .toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    if (ordered.isEmpty) return const [];

    final points = <MasteryTrendPoint>[];
    final cumulative = <QuestionAttemptRecord>[];
    final step = math.max(1, (ordered.length / 8).ceil());
    for (var i = 0; i < ordered.length; i++) {
      cumulative.add(ordered[i]);
      if ((i + 1) % step != 0 && i != ordered.length - 1) continue;
      final metric = controller.masteryForAttempts(cumulative, subject: subject);
      final date = ordered[i].completedAt;
      points.add(MasteryTrendPoint(
        label: '${date.day}/${date.month}',
        score: metric.score,
        attempts: cumulative.length,
        completedAt: date,
      ));
    }
    return points;
  }

  List<String> subjectsWithCurriculum() {
    final profile = controller.profile?.subjects ?? const <String>[];
    final curriculum = allCurriculumUnits.map((u) => u.subject).toSet();
    final preferred = profile.where(curriculum.contains).toList();
    final remaining = curriculum.where((s) => !preferred.contains(s)).toList()..sort();
    return [...preferred, ...remaining];
  }

  math.Point<int> coverageForSubject(String subject) {
    final nodes = progressNodesForSubject(subject);
    final measured = nodes.where((n) => n.isMeasured).length;
    return math.Point(measured, nodes.length);
  }

  IconData _iconForSubject(String subject) {
    switch (subject) {
      case 'الكيمياء':
        return Icons.science_outlined;
      case 'الفيزياء':
        return Icons.bolt_outlined;
      case 'الرياضيات':
        return Icons.calculate_outlined;
      case 'الأحياء':
        return Icons.biotech_outlined;
      case 'اللغة الإنجليزية':
        return Icons.translate_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}
