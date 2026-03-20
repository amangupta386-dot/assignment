import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/pattern_note_repository.dart';
import 'pattern_note_detail_screen.dart';

Future<void> openPatternNoteOrShowSnackbar(
  BuildContext context,
  String patternName,
) async {
  final trimmed = patternName.trim();
  if (trimmed.isEmpty) return;

  final note = await context.read<PatternNoteRepository>().getNoteByPattern(
        trimmed,
      );
  if (!context.mounted) return;

  if (note == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No pattern note saved for $trimmed')),
    );
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PatternNoteDetailScreen(patternName: note.patternName),
    ),
  );
}
