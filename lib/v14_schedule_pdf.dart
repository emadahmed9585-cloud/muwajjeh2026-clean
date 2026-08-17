import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'v14_schedule_models.dart';

class WeeklySchedulePdfBuilder {
  const WeeklySchedulePdfBuilder._();

  static final PdfColor _navy = PdfColor(24 / 255, 59 / 255, 86 / 255);
  static final PdfColor _teal = PdfColor(31 / 255, 122 / 255, 116 / 255);
  static final PdfColor _sand = PdfColor(242 / 255, 184 / 255, 75 / 255);
  static final PdfColor _ink = PdfColor(23 / 255, 33 / 255, 43 / 255);
  static final PdfColor _muted = PdfColor(102 / 255, 119 / 255, 132 / 255);
  static final PdfColor _border = PdfColor(227 / 255, 233 / 255, 231 / 255);
  static final PdfColor _soft = PdfColor(246 / 255, 248 / 255, 247 / 255);

  static Future<Uint8List> build(WeeklyPlanResult plan) async {
    final regular = await PdfGoogleFonts.notoNaskhArabicRegular();
    final bold = await PdfGoogleFonts.notoNaskhArabicBold();
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: _overviewPage(plan),
        ),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: _detailPageContent(plan),
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _overviewPage(WeeklyPlanResult plan) {
    final end = plan.settings.weekStart.add(const Duration(days: 6));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'مُوَجِّه | برنامجي الأسبوعي',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'الأسبوع ${plannerDateLabel(plan.settings.weekStart)} - ${plannerDateLabel(end)}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _teal,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  plan.settings.studentName,
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: pw.BoxDecoration(
            color: PdfColor(1, 0.975, 0.90),
            border: pw.Border.all(color: _sand, width: 0.8),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            plan.quote,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: _ink, fontSize: 10.5, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _summaryChip('الجلسات', '${plan.placedStudySessions}/${plan.requestedStudySessions}'),
            pw.SizedBox(width: 8),
            _summaryChip('مدة الجلسة', '${plan.settings.sessionMinutes} دقيقة'),
            pw.SizedBox(width: 8),
            _summaryChip('الراحة', '${plan.settings.breakMinutes} دقيقة'),
            pw.SizedBox(width: 8),
            _summaryChip('أقصى جلسات يومية', '${plan.settings.maxSessionsPerDay}'),
          ],
        ),
        pw.SizedBox(height: 11),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < plannerDays.length; i++) ...[
                pw.Expanded(child: _dayColumn(plan, plannerDays[i])),
                if (i != plannerDays.length - 1) pw.SizedBox(width: 5),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 7),
        _legend(plan),
      ],
    );
  }

  static pw.Widget _summaryChip(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          color: _soft,
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          children: [
            pw.Text(value, style: pw.TextStyle(color: _navy, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text(title, style: pw.TextStyle(color: _muted, fontSize: 7.5)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _dayColumn(WeeklyPlanResult plan, WeeklyPlannerDay day) {
    final study = plan
        .blocksForDay(day.index)
        .where((b) => b.kind == PlannerBlockKind.study)
        .toList();
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 7),
            decoration: pw.BoxDecoration(
              color: day.index == 5 ? PdfColor(0.96, 0.94, 0.87) : PdfColor(0.91, 0.96, 0.95),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(9),
                topRight: pw.Radius.circular(9),
              ),
            ),
            child: pw.Text(
              day.shortLabel,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(color: _navy, fontSize: 9.2, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 5),
          if (study.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                plan.settings.availableDays.contains(day.index) ? 'راحة / مراجعة خفيفة' : 'غير متاح',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: _muted, fontSize: 7.2),
              ),
            )
          else
            ...study.map((block) => _studyBlock(block)),
        ],
      ),
    );
  }

  static pw.Widget _studyBlock(WeeklyPlanBlock block) {
    final color = _subjectColor(block.subject);
    return pw.Container(
      margin: const pw.EdgeInsets.fromLTRB(4, 2, 4, 2),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: pw.BoxDecoration(
        color: _lighten(color),
        border: pw.Border(left: pw.BorderSide(color: color, width: 2.3)),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _shortSubject(block.subject),
            maxLines: 1,
            style: pw.TextStyle(color: _ink, fontSize: 7.2, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${plannerTimeLabel(block.startMinute)} - ${plannerTimeLabel(block.endMinute)}',
            style: pw.TextStyle(color: _muted, fontSize: 5.9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _legend(WeeklyPlanResult plan) {
    final subjects = plan.settings.subjects.where((s) => s.enabled).map((s) => s.subject).toSet();
    return pw.Wrap(
      spacing: 10,
      runSpacing: 5,
      children: [
        for (final subject in subjects)
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: _subjectColor(subject), shape: pw.BoxShape.circle)),
              pw.SizedBox(width: 4),
              pw.Text(_shortSubject(subject), style: pw.TextStyle(fontSize: 6.8, color: _muted)),
            ],
          ),
      ],
    );
  }

  static pw.Widget _detailPageContent(WeeklyPlanResult plan) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('تفاصيل البرنامج الأسبوعي', style: pw.TextStyle(color: _navy, fontSize: 19, fontWeight: pw.FontWeight.bold)),
                  pw.Text('الطالب: ${plan.settings.studentName}', style: pw.TextStyle(color: _muted, fontSize: 9)),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: pw.BoxDecoration(color: _teal, borderRadius: pw.BorderRadius.circular(10)),
              child: pw.Text('مُوَجِّه', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        _detailsTable(plan),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _subjectGoals(plan)),
            pw.SizedBox(width: 12),
            pw.Expanded(child: _plannerNotes(plan)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _detailsTable(WeeklyPlanResult plan) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _navy),
        children: [
          _tableCell('اليوم', header: true),
          _tableCell('الأنشطة الثابتة', header: true),
          _tableCell('جلسات الدراسة', header: true),
        ],
      ),
    ];
    for (final day in plannerDays) {
      final blocks = plan.blocksForDay(day.index);
      final activities = blocks.where((b) => b.kind == PlannerBlockKind.activity).toList();
      final study = blocks.where((b) => b.kind == PlannerBlockKind.study).toList();
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: day.index.isEven ? PdfColors.white : _soft),
          children: [
            _tableCell(day.label, bold: true),
            _tableCell(
              activities.isEmpty
                  ? 'لا توجد أنشطة ثابتة مسجلة'
                  : activities.map((b) => '${plannerTimeLabel(b.startMinute)}-${plannerTimeLabel(b.endMinute)}  ${b.title}').join('\n'),
            ),
            _tableCell(
              study.isEmpty
                  ? 'راحة / لا توجد جلسة'
                  : study.map((b) => '${plannerTimeLabel(b.startMinute)}-${plannerTimeLabel(b.endMinute)}  ${b.subject}').join('\n'),
            ),
          ],
        ),
      );
    }
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.7),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.0),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(3.0),
      },
      children: rows,
    );
  }

  static pw.Widget _tableCell(String text, {bool header = false, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: header ? PdfColors.white : _ink,
          fontSize: header ? 8.5 : 7.5,
          fontWeight: (header || bold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          lineSpacing: 2,
        ),
      ),
    );
  }

  static pw.Widget _subjectGoals(WeeklyPlanResult plan) {
    final enabled = plan.settings.subjects.where((s) => s.enabled).toList();
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text('أهداف المواد هذا الأسبوع', style: pw.TextStyle(color: _navy, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 7),
          for (final target in enabled)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(
                children: [
                  pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: _subjectColor(target.subject), shape: pw.BoxShape.circle)),
                  pw.SizedBox(width: 6),
                  pw.Expanded(child: pw.Text(target.subject, style: pw.TextStyle(fontSize: 8, color: _ink))),
                  pw.Text('${plan.sessionsForSubject(target.subject)}/${target.sessionsPerWeek} جلسة', style: pw.TextStyle(fontSize: 7.2, color: _muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _plannerNotes(WeeklyPlanResult plan) {
    final notes = <String>[
      'ابدأ كل جلسة بهدف واحد واضح، ولا تفتح أكثر من مادة في الجلسة نفسها.',
      'بعد كل جلسة، اكتب في دقيقة واحدة: ماذا فهمت؟ وما الذي بقي غير واضح؟',
      'إذا فاتتك جلسة، انقلها إلى أول وقت فارغ؛ لا تضاعف جلسات اليوم التالي تلقائيًا.',
      if (plan.settings.useMuwajjehPriority) 'تم أخذ نتائج مُوَجِّه ونقاط الضعف في الاعتبار عند ترتيب الأولويات.',
      ...plan.warnings,
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor(0.91, 0.96, 0.95),
        border: pw.Border.all(color: _teal),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text('ملاحظات مُوَجِّه', style: pw.TextStyle(color: _navy, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          for (final note in notes)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
              child: pw.Text('• $note', style: pw.TextStyle(color: _ink, fontSize: 7.5)),
            ),
        ],
      ),
    );
  }

  static String _shortSubject(String subject) {
    if (subject.contains('اللغة الإنجليزية')) return 'الإنجليزية';
    if (subject.contains('الرياضيات')) return 'الرياضيات';
    if (subject.contains('الكيمياء')) return 'الكيمياء';
    if (subject.contains('الفيزياء')) return 'الفيزياء';
    if (subject.contains('الأحياء') || subject.contains('العلوم الحياتية')) return 'الأحياء';
    return subject.length > 12 ? '${subject.substring(0, 12)}…' : subject;
  }

  static PdfColor _subjectColor(String subject) {
    if (subject.contains('الإنجليزية')) return PdfColor(0.12, 0.48, 0.45);
    if (subject.contains('الرياضيات')) return PdfColor(0.16, 0.36, 0.68);
    if (subject.contains('الكيمياء')) return PdfColor(0.83, 0.48, 0.15);
    if (subject.contains('الفيزياء')) return PdfColor(0.45, 0.33, 0.62);
    if (subject.contains('الأحياء') || subject.contains('العلوم الحياتية')) return PdfColor(0.28, 0.50, 0.30);
    return _teal;
  }

  static PdfColor _lighten(PdfColor color) => PdfColor(
        0.88 + color.red * 0.12,
        0.88 + color.green * 0.12,
        0.88 + color.blue * 0.12,
      );
}
