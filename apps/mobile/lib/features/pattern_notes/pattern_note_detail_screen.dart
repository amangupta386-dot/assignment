import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../models/pattern_note_model.dart';
import '../../repositories/pattern_note_repository.dart';
import 'pattern_note_editor_screen.dart';

class PatternNoteDetailScreen extends StatefulWidget {
  const PatternNoteDetailScreen({
    super.key,
    required this.patternName,
  });

  final String patternName;

  @override
  State<PatternNoteDetailScreen> createState() =>
      _PatternNoteDetailScreenState();
}

class _PatternNoteDetailScreenState extends State<PatternNoteDetailScreen> {
  PatternNoteModel? _note;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final repository = context.read<PatternNoteRepository>();
    final note = await repository.getNoteByPattern(widget.patternName);
    if (!mounted) return;
    setState(() {
      _note = note;
      _isLoading = false;
    });
  }

  Future<void> _openEditor() async {
    final note = _note;
    if (note == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatternNoteEditorScreen(existingNote: note),
      ),
    );
    await _loadNote();
  }

  Future<void> _deleteNote() async {
    final note = _note;
    if (note == null) return;

    await context.read<PatternNoteRepository>().deleteNote(note.patternName);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.patternName} note deleted')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Note'),
        actions: [
          if (_note != null)
            IconButton(
              onPressed: _openEditor,
              icon: const Icon(Icons.edit_outlined),
            ),
          if (_note != null)
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _note == null
              ? const Center(child: Text('Pattern note not found'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _note!.patternName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _InfoPill(
                                label: 'Time Complexity',
                                value: _note!.timeComplexity,
                              ),
                              _InfoPill(
                                label: 'Updated',
                                value: _formatDate(_note!.updatedAt),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          File(_note!.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => SizedBox(
                            height: 220,
                            child: Center(
                              child: Text(
                                'Saved image could not be loaded',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
