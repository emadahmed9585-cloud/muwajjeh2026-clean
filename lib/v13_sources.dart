class TutorSourceV13 {
  const TutorSourceV13({
    required this.name,
    required this.role,
    required this.note,
    this.primary = false,
  });

  final String name;
  final String role;
  final String note;
  final bool primary;
}

List<TutorSourceV13> tutorSourcesFor(String subject) {
  final official = const TutorSourceV13(
    name: 'الكتاب الرسمي الأردني للصف الثاني عشر',
    role: 'المرجع الأساسي',
    note: 'تُضبط الفكرة والمصطلح وتسلسل المنهاج وفق كتاب الطالب/التمارين الرسمي.',
    primary: true,
  );

  if (subject == 'اللغة الإنجليزية') {
    return [
      official,
      const TutorSourceV13(
        name: 'British Council LearnEnglish',
        role: 'مرجع تعزيزي',
        note: 'يُستأنس به عند تبسيط القواعد والمفردات وتقديم مثال إضافي، دون تغيير محتوى المنهاج.',
      ),
    ];
  }

  if (subject == 'الرياضيات' || subject == 'الكيمياء' || subject == 'الفيزياء' || subject == 'الأحياء') {
    return [
      official,
      const TutorSourceV13(
        name: 'OpenStax',
        role: 'مرجع تعزيزي',
        note: 'يُستخدم لتوضيح الفكرة العلمية/الرياضية بمثال إضافي أو تفسير مفاهيمي عند الحاجة.',
      ),
      const TutorSourceV13(
        name: 'Khan Academy',
        role: 'مرجع تدريبي مساعد',
        note: 'يُستأنس بأساليب التدرج والممارسة لتبسيط الفكرة للطالب المبتدئ، لا كمصدر بديل للمنهاج.',
      ),
    ];
  }

  return [official];
}
