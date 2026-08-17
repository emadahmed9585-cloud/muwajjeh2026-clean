import 'package:flutter/material.dart';

import 'models.dart';
import 'curriculum_data.dart';
import 'v6_curriculum_data.dart';
import 'v11_ministerial_questions.dart';

const examBank = <ExamDefinition>[
  ExamDefinition(
    title: 'الكيمياء - الحموض والقواعد',
    subtitle: 'اختبار تشخيصي في برونستد-لوري ودرجة الحموضة.',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    difficulty: 'متوسط',
    durationMinutes: 12,
    icon: Icons.science,
    questions: chemistryAcidsQuestions,
  ),
  ExamDefinition(
    title: 'الكيمياء - سرعة التفاعل',
    subtitle: 'تدريب على العوامل المؤثرة في سرعة التفاعل والعامل الحفاز.',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    difficulty: 'متوسط',
    durationMinutes: 12,
    icon: Icons.speed,
    questions: chemistryRateQuestions,
  ),
  ExamDefinition(
    title: 'الرياضيات - تطبيقات التفاضل',
    subtitle: 'المشتقة والتزايد والتناقص والنقاط الحرجة.',
    subject: 'الرياضيات',
    unit: 'التفاضل',
    difficulty: 'متوسط',
    durationMinutes: 15,
    icon: Icons.calculate,
    questions: mathQuestions,
  ),
  ExamDefinition(
    title: 'اللغة الإنجليزية - مهارات اللغة',
    subtitle: 'Question tags وPresent Perfect واستخدام اللغة.',
    subject: 'اللغة الإنجليزية',
    unit: 'Language Use',
    difficulty: 'متوسط',
    durationMinutes: 12,
    icon: Icons.translate,
    questions: englishQuestions,
  ),
  ExamDefinition(
    title: 'الفيزياء - الكهرباء',
    subtitle: 'مفاهيم أساسية في التيار والمقاومة والقدرة الكهربائية.',
    subject: 'الفيزياء',
    unit: 'الكهرباء',
    difficulty: 'متوسط',
    durationMinutes: 12,
    icon: Icons.bolt,
    questions: physicsQuestions,
  ),
  ExamDefinition(
    title: 'الأحياء - الوراثة',
    subtitle: 'مفاهيم الجينات والكروموسومات والأنماط الجينية.',
    subject: 'الأحياء',
    unit: 'الوراثة',
    difficulty: 'متوسط',
    durationMinutes: 12,
    icon: Icons.biotech,
    questions: biologyQuestions,
  ),
];

List<ExamQuestion> get allBankQuestions => [
      ...allCurriculumQuestions,
      ...v11MinisterialSupplementQuestions,
      ...examBank.expand((exam) => exam.questions),
    ];

const chemistryAcidsQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'chem-acid-01',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'مفهوم برونستد-لوري',
    difficulty: 'سهل',
    text: 'أيّ المواد الآتية تُعد حمضاً وفق مفهوم برونستد-لوري؟',
    options: ['مانح للبروتون', 'مستقبل للبروتون', 'مانح لزوج إلكتروني', 'لا يتفاعل مع الماء'],
    correctIndex: 0,
    explanation: 'حمض برونستد-لوري هو المادة القادرة على منح بروتون H+.',
  ),
  ExamQuestion(
    id: 'chem-acid-02',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'الرقم الهيدروجيني',
    difficulty: 'متوسط',
    text: 'عندما تزداد قيمة pH لمحلول مائي، فإن تركيز أيونات الهيدرونيوم غالباً:',
    options: ['يزداد', 'يقل', 'يبقى ثابتاً', 'يساوي صفراً دائماً'],
    correctIndex: 1,
    explanation: 'توجد علاقة عكسية لوغاريتمية بين pH وتركيز H3O+.',
  ),
  ExamQuestion(
    id: 'chem-acid-03',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'مفهوم برونستد-لوري',
    difficulty: 'سهل',
    text: 'في تفاعل حمض مع قاعدة، المادة التي تستقبل البروتون تُصنّف على أنها:',
    options: ['حمض', 'قاعدة', 'ملح فقط', 'عامل مؤكسد دائماً'],
    correctIndex: 1,
    explanation: 'القاعدة وفق برونستد-لوري هي مستقبل البروتون.',
  ),
  ExamQuestion(
    id: 'chem-acid-04',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'الرقم الهيدروجيني',
    difficulty: 'سهل',
    text: 'أي وصف يناسب المحلول المتعادل عند 25°C تقريباً؟',
    options: ['pH أقل من 7', 'pH أكبر من 7', 'pH يساوي 7 تقريباً', 'لا يحتوي ماء'],
    correctIndex: 2,
    explanation: 'الماء النقي متعادل تقريباً وتكون قيمة pH له 7 عند 25°C.',
  ),
  ExamQuestion(
    id: 'chem-acid-05',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'الأزواج المترافقة',
    difficulty: 'متوسط',
    text: 'عندما يفقد الحمض بروتوناً، فإن النوع الناتج عنه يسمى:',
    options: ['حمضاً أقوى', 'قاعدته المرافقة', 'ملحاً دائماً', 'عاملاً حفازاً'],
    correctIndex: 1,
    explanation: 'فقدان الحمض للبروتون ينتج القاعدة المرافقة لذلك الحمض.',
  ),
  ExamQuestion(
    id: 'chem-acid-06',
    subject: 'الكيمياء',
    unit: 'الحموض والقواعد',
    lesson: 'قوة الحمض والقاعدة',
    difficulty: 'صعب',
    text: 'أي عبارة تصف حمضاً قوياً في الماء بصورة أفضل؟',
    options: ['يتأين بدرجة كبيرة', 'لا يمنح بروتوناً', 'يكون pH له دائماً 7', 'لا يوصل التيار'],
    correctIndex: 0,
    explanation: 'الحمض القوي يتأين بدرجة كبيرة في الماء مقارنةً بالحمض الضعيف.',
  ),
];

const chemistryRateQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'chem-rate-01',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'العوامل المؤثرة',
    difficulty: 'سهل',
    text: 'أي عامل يؤدي عادةً إلى زيادة سرعة التفاعل بين المواد المتفاعلة؟',
    options: ['خفض درجة الحرارة', 'تقليل عدد التصادمات', 'زيادة درجة الحرارة', 'إزالة أحد المتفاعلات'],
    correctIndex: 2,
    explanation: 'رفع درجة الحرارة يزيد الطاقة الحركية وعدد التصادمات الفعالة عادةً.',
  ),
  ExamQuestion(
    id: 'chem-rate-02',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'العامل الحفاز',
    difficulty: 'متوسط',
    text: 'وظيفة العامل الحفاز هي:',
    options: ['زيادة طاقة التنشيط', 'توفير مسار أقل في طاقة التنشيط', 'إيقاف التفاعل', 'زيادة كتلة النواتج دائماً'],
    correctIndex: 1,
    explanation: 'العامل الحفاز يوفّر مساراً بمتطلبات طاقة تنشيط أقل.',
  ),
  ExamQuestion(
    id: 'chem-rate-03',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'مساحة السطح',
    difficulty: 'متوسط',
    text: 'زيادة مساحة سطح مادة صلبة متفاعلة تؤدي غالباً إلى:',
    options: ['تقليل التصادمات', 'زيادة سرعة التفاعل', 'إلغاء التفاعل', 'عدم حدوث أي أثر مطلقاً'],
    correctIndex: 1,
    explanation: 'زيادة مساحة السطح تعرّض عدداً أكبر من الجسيمات للتصادم.',
  ),
  ExamQuestion(
    id: 'chem-rate-04',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'نظرية التصادم',
    difficulty: 'متوسط',
    text: 'لكي يكون التصادم بين الجسيمات فعالاً يجب أن:',
    options: ['يحدث بأي طاقة', 'يمتلك طاقة واتجاهاً مناسبين', 'يكون بين نواتج فقط', 'يخفض درجة الحرارة'],
    correctIndex: 1,
    explanation: 'التصادم الفعال يحتاج طاقة كافية واتجاهاً مناسباً لتكوين النواتج.',
  ),
  ExamQuestion(
    id: 'chem-rate-05',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'التركيز',
    difficulty: 'متوسط',
    text: 'زيادة تركيز أحد المتفاعلات في المحلول تؤدي غالباً إلى:',
    options: ['انخفاض معدل التصادم', 'زيادة معدل التصادم', 'ثبات السرعة دائماً', 'اختفاء طاقة التنشيط'],
    correctIndex: 1,
    explanation: 'ارتفاع التركيز يزيد عدد الجسيمات في الحجم نفسه فيزداد تكرار التصادمات.',
  ),
  ExamQuestion(
    id: 'chem-rate-06',
    subject: 'الكيمياء',
    unit: 'سرعة التفاعل',
    lesson: 'منحنى طاقة التفاعل',
    difficulty: 'صعب',
    text: 'عند إضافة عامل حفاز لتفاعل، أي كمية تتغير مباشرة؟',
    options: ['طاقة التنشيط', 'التغير الكلي في الطاقة للنواتج والمتفاعلات', 'كتلة المادة', 'عدد الذرات'],
    correctIndex: 0,
    explanation: 'الحفاز يخفض طاقة التنشيط دون تغيير فرق الطاقة الكلي بين المتفاعلات والنواتج.',
  ),
];

const mathQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'math-diff-01', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'قواعد الاشتقاق', difficulty: 'سهل',
    text: 'إذا كانت f(x) = x²، فما قيمة f′(3)؟', options: ['3', '6', '9', '12'], correctIndex: 1,
    explanation: 'مشتقة x² هي 2x، وعند x = 3 تكون القيمة 6.',
  ),
  ExamQuestion(
    id: 'math-diff-02', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'التزايد والتناقص', difficulty: 'متوسط',
    text: 'إذا كانت مشتقة الدالة موجبة على فترة، فهذا يعني عادةً أن الدالة على تلك الفترة:', options: ['متزايدة', 'متناقصة', 'ثابتة دائماً', 'غير معرفة'], correctIndex: 0,
    explanation: 'إشارة المشتقة الموجبة تدل على تزايد الدالة على الفترة.',
  ),
  ExamQuestion(
    id: 'math-diff-03', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'النقاط الحرجة', difficulty: 'متوسط',
    text: 'النقطة الحرجة للدالة قد تظهر عندما:', options: ['f′(x)=0 أو غير موجودة', 'f(x)=1 دائماً', 'x=0 فقط', 'الميل موجب دائماً'], correctIndex: 0,
    explanation: 'من مواضع النقاط الحرجة أن تكون المشتقة صفراً أو غير موجودة ضمن مجال الدالة.',
  ),
  ExamQuestion(
    id: 'math-diff-04', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'معادلة المماس', difficulty: 'متوسط',
    text: 'ميل المماس لمنحنى الدالة عند نقطة يساوي:', options: ['قيمة الدالة فقط', 'قيمة المشتقة عند النقطة', 'إحداثي x فقط', 'صفر دائماً'], correctIndex: 1,
    explanation: 'المشتقة عند النقطة تمثل ميل المماس للمنحنى عند تلك النقطة.',
  ),
  ExamQuestion(
    id: 'math-diff-05', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'قواعد الاشتقاق', difficulty: 'متوسط',
    text: 'إذا كانت f(x)=3x³، فإن f′(x) تساوي:', options: ['3x²', '6x²', '9x²', '9x³'], correctIndex: 2,
    explanation: 'باستخدام قاعدة القوة: مشتقة 3x³ هي 9x².',
  ),
  ExamQuestion(
    id: 'math-diff-06', subject: 'الرياضيات', unit: 'التفاضل', lesson: 'القيم القصوى', difficulty: 'صعب',
    text: 'إذا تغيرت إشارة f′ من موجبة إلى سالبة عند x=a، فإن f عند a غالباً تمتلك:', options: ['قيمة صغرى محلية', 'قيمة عظمى محلية', 'نقطة انعطاف حتماً', 'لا شيء يمكن استنتاجه'], correctIndex: 1,
    explanation: 'الانتقال من التزايد إلى التناقص يشير إلى قيمة عظمى محلية.',
  ),
];

const englishQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'eng-lang-01', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Question tags', difficulty: 'متوسط',
    text: 'Choose the correct question tag: Nothing ever changes, ______?', options: ['does it', "doesn't it", 'do they', 'is it'], correctIndex: 0,
    explanation: 'Nothing has a negative meaning, so the question tag is positive: does it?',
  ),
  ExamQuestion(
    id: 'eng-lang-02', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Question tags', difficulty: 'متوسط',
    text: 'Choose the correct question tag: Let’s start revising now, ______?', options: ['will we', 'shall we', 'do we', "aren't we"], correctIndex: 1,
    explanation: 'After “Let’s”, the standard question tag is “shall we?”.',
  ),
  ExamQuestion(
    id: 'eng-lang-03', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Present Perfect', difficulty: 'سهل',
    text: 'Choose the best option: She has ______ finished the assignment.', options: ['yet', 'already', 'since', 'for'], correctIndex: 1,
    explanation: '“Already” is commonly used in affirmative present perfect sentences.',
  ),
  ExamQuestion(
    id: 'eng-lang-04', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Present Perfect', difficulty: 'متوسط',
    text: 'Choose the correct option: I have lived here ______ 2022.', options: ['for', 'since', 'already', 'yet'], correctIndex: 1,
    explanation: '“Since” is used with a starting point in time.',
  ),
  ExamQuestion(
    id: 'eng-lang-05', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Question tags', difficulty: 'متوسط',
    text: 'Choose the correct question tag: Don’t be late, ______?', options: ['do you', 'will you', 'shall we', "won't you"], correctIndex: 1,
    explanation: 'Imperatives commonly take “will you?” as the tag.',
  ),
  ExamQuestion(
    id: 'eng-lang-06', subject: 'اللغة الإنجليزية', unit: 'Language Use', lesson: 'Vocabulary in context', difficulty: 'صعب',
    text: 'Choose the best word: A person who is tactful is careful not to ______ other people.', options: ['offend', 'collect', 'measure', 'interrupt always'], correctIndex: 0,
    explanation: 'Tactful behaviour avoids causing offence or embarrassment.',
  ),
];

const physicsQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'phy-elec-01', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'التيار الكهربائي', difficulty: 'سهل',
    text: 'وحدة قياس شدة التيار الكهربائي في النظام الدولي هي:', options: ['الفولت', 'الأمبير', 'الأوم', 'الواط'], correctIndex: 1,
    explanation: 'الأمبير هو وحدة قياس شدة التيار الكهربائي.',
  ),
  ExamQuestion(
    id: 'phy-elec-02', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'قانون أوم', difficulty: 'متوسط',
    text: 'وفق قانون أوم، إذا ثبتت المقاومة وتضاعف فرق الجهد فإن التيار:', options: ['ينخفض للنصف', 'يتضاعف', 'يبقى ثابتاً', 'يصبح صفراً'], correctIndex: 1,
    explanation: 'I=V/R، لذلك عند ثبات R يتناسب التيار طردياً مع فرق الجهد.',
  ),
  ExamQuestion(
    id: 'phy-elec-03', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'المقاومة', difficulty: 'سهل',
    text: 'وحدة قياس المقاومة الكهربائية هي:', options: ['الأوم', 'الأمبير', 'الجول', 'الكولوم'], correctIndex: 0,
    explanation: 'الأوم هو وحدة قياس المقاومة الكهربائية.',
  ),
  ExamQuestion(
    id: 'phy-elec-04', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'القدرة الكهربائية', difficulty: 'متوسط',
    text: 'يمكن حساب القدرة الكهربائية لجهاز من العلاقة:', options: ['P=VI', 'P=V/I فقط', 'P=R/I', 'P=Q/t فقط'], correctIndex: 0,
    explanation: 'إحدى علاقات القدرة الكهربائية الأساسية هي P=VI.',
  ),
  ExamQuestion(
    id: 'phy-elec-05', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'التوصيل على التوالي', difficulty: 'متوسط',
    text: 'في دائرة توصيل على التوالي، شدة التيار المار في المقاومات تكون:', options: ['متساوية', 'مختلفة دائماً', 'صفراً', 'أكبر في المقاومة الأصغر فقط'], correctIndex: 0,
    explanation: 'في المسار المتسلسل الواحد يمر التيار نفسه في جميع العناصر.',
  ),
  ExamQuestion(
    id: 'phy-elec-06', subject: 'الفيزياء', unit: 'الكهرباء', lesson: 'قانون أوم', difficulty: 'صعب',
    text: 'مقاومة مقدارها 6 Ω موصولة بفرق جهد 12 V. شدة التيار تساوي:', options: ['0.5 A', '2 A', '6 A', '72 A'], correctIndex: 1,
    explanation: 'I=V/R=12/6=2 A.',
  ),
];

const biologyQuestions = <ExamQuestion>[
  ExamQuestion(
    id: 'bio-gen-01', subject: 'الأحياء', unit: 'الوراثة', lesson: 'الجينات', difficulty: 'سهل',
    text: 'الجين هو بصورة عامة:', options: ['جزء من DNA يحمل معلومات وراثية', 'نوع من الدهون', 'عضية خلوية كاملة', 'سكر بسيط'], correctIndex: 0,
    explanation: 'الجين مقطع من DNA يرتبط بمعلومة وراثية أو وظيفة محددة.',
  ),
  ExamQuestion(
    id: 'bio-gen-02', subject: 'الأحياء', unit: 'الوراثة', lesson: 'الكروموسومات', difficulty: 'سهل',
    text: 'توجد الجينات مرتبة على:', options: ['الكروموسومات', 'الريبوسومات فقط', 'الجدار الخلوي', 'السيتوبلازم فقط'], correctIndex: 0,
    explanation: 'تحمل الكروموسومات DNA الذي توجد عليه الجينات.',
  ),
  ExamQuestion(
    id: 'bio-gen-03', subject: 'الأحياء', unit: 'الوراثة', lesson: 'الطراز الجيني', difficulty: 'متوسط',
    text: 'يشير الطراز الجيني إلى:', options: ['التركيب الجيني للفرد', 'الصفات الظاهرة فقط', 'العمر', 'عدد الخلايا'], correctIndex: 0,
    explanation: 'الطراز الجيني يصف التركيب الأليلي أو الجيني للفرد.',
  ),
  ExamQuestion(
    id: 'bio-gen-04', subject: 'الأحياء', unit: 'الوراثة', lesson: 'الطراز الشكلي', difficulty: 'متوسط',
    text: 'الطراز الشكلي هو:', options: ['الصفة القابلة للملاحظة', 'تسلسل DNA كاملاً', 'عدد الكروموسومات فقط', 'نوع الانقسام فقط'], correctIndex: 0,
    explanation: 'الطراز الشكلي هو التعبير الظاهر أو القابل للقياس للصفة.',
  ),
  ExamQuestion(
    id: 'bio-gen-05', subject: 'الأحياء', unit: 'الوراثة', lesson: 'الأليلات', difficulty: 'متوسط',
    text: 'الأليلان في الفرد ثنائي الصيغة الصبغية يمثلان:', options: ['صورتين بديلتين للجين نفسه', 'جينين لا علاقة بينهما', 'بروتينين', 'كروموسومين متطابقين حتماً'], correctIndex: 0,
    explanation: 'الأليلات صور بديلة للجين نفسه تقع في الموضع الجيني ذاته على الكروموسومات المتماثلة.',
  ),
  ExamQuestion(
    id: 'bio-gen-06', subject: 'الأحياء', unit: 'الوراثة', lesson: 'السيادة', difficulty: 'صعب',
    text: 'في حالة السيادة التامة، يظهر في الفرد غير المتماثل الأليلات:', options: ['أثر الأليل السائد', 'أثر الأليل المتنحي فقط', 'لا تظهر أي صفة', 'كلا الأليلين بالتساوي دائماً'], correctIndex: 0,
    explanation: 'في السيادة التامة يحدد الأليل السائد الطراز الشكلي للفرد غير المتماثل.',
  ),
];
