import 'package:flutter/material.dart';

import 'models.dart';
import 'v13_theme.dart';

class QuestionCardV13 extends StatelessWidget {
  const QuestionCardV13({
    super.key,
    required this.number,
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
    this.showDifficulty = false,
  });

  final int number;
  final ExamQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showDifficulty;

  @override
  Widget build(BuildContext context) {
    final prompt = QuestionPromptParts.fromQuestion(question);
    final questionDirection = _directionFor(prompt.stem.isEmpty ? question.text : prompt.stem);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MuwajjehPalette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A142A36),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: MuwajjehPalette.navy,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.skill,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MuwajjehPalette.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                if (showDifficulty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      question.difficulty,
                      style: const TextStyle(
                        color: MuwajjehPalette.muted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: MuwajjehPalette.tealSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Directionality(
                textDirection: _directionFor(prompt.instruction),
                child: Text(
                  prompt.instruction,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: MuwajjehPalette.teal,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            if (prompt.stem.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Directionality(
                textDirection: questionDirection,
                child: Text(
                  prompt.stem,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: MuwajjehPalette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.65,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...List.generate(question.options.length, (index) {
              final selected = selectedIndex == index;
              return _AnswerOption(
                label: String.fromCharCode(65 + index),
                text: question.options[index],
                selected: selected,
                onTap: () => onSelected(index),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: selected ? const Color(0xFFF0F8F6) : const Color(0xFFFBFCFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? MuwajjehPalette.teal : MuwajjehPalette.border,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? MuwajjehPalette.teal : Colors.white,
                    border: Border.all(
                      color: selected ? MuwajjehPalette.teal : const Color(0xFFD5DEDB),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : MuwajjehPalette.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: _directionFor(text),
                    child: Text(
                      text,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: MuwajjehPalette.ink,
                        fontSize: 15.5,
                        height: 1.55,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded, color: MuwajjehPalette.teal, size: 21),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionPromptParts {
  const QuestionPromptParts({required this.instruction, required this.stem});

  final String instruction;
  final String stem;

  factory QuestionPromptParts.fromQuestion(ExamQuestion question) {
    final raw = question.text.trim();
    final english = question.subject == 'اللغة الإنجليزية' || _looksMostlyLatin(raw);
    final defaultInstruction = english
        ? 'Choose the correct answer.'
        : 'اختر الإجابة الصحيحة.';

    final colon = raw.indexOf(':');
    if (english && raw.toLowerCase().startsWith('choose the correct') && colon > 0) {
      final stem = raw.substring(colon + 1).trim();
      return QuestionPromptParts(instruction: defaultInstruction, stem: stem);
    }

    if (english && raw.toLowerCase().startsWith('choose the correct') && raw.length < 90) {
      return QuestionPromptParts(instruction: defaultInstruction, stem: '');
    }

    return QuestionPromptParts(instruction: defaultInstruction, stem: raw);
  }
}

TextDirection _directionFor(String text) {
  final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
  final latinCount = RegExp(r'[A-Za-z]').allMatches(text).length;
  return arabicCount > latinCount ? TextDirection.rtl : TextDirection.ltr;
}

bool _looksMostlyLatin(String text) => _directionFor(text) == TextDirection.ltr;
