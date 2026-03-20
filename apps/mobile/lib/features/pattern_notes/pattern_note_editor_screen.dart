import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/pattern_note_model.dart';
import '../../repositories/pattern_note_repository.dart';

class PatternNoteEditorScreen extends StatefulWidget {
  const PatternNoteEditorScreen({
    super.key,
    this.existingNote,
    this.initialPatternName,
  });

  final PatternNoteModel? existingNote;
  final String? initialPatternName;

  @override
  State<PatternNoteEditorScreen> createState() =>
      _PatternNoteEditorScreenState();
}

class _PatternNoteEditorScreenState extends State<PatternNoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patternController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _patternController.text =
        widget.existingNote?.patternName ?? widget.initialPatternName ?? '';
    _imagePath = widget.existingNote?.imagePath;
  }

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;
    setState(() {
      _imagePath = file.path;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null || _imagePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final note = await context.read<PatternNoteRepository>().saveNote(
            patternName: _patternController.text,
            imageSourcePath: _imagePath!,
            previousPatternName: widget.existingNote?.patternName,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${note.patternName} note saved')),
      );
      Navigator.pop(context, note);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null
            ? 'Add Pattern Note'
            : 'Edit Pattern Note'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
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
                  'Build your visual pattern notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save the pattern name and a reference image so you can open it from anywhere in the app.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _patternController,
                  decoration: const InputDecoration(
                    labelText: 'Pattern Name',
                    prefixIcon: Icon(Icons.hub_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a pattern name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Image',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                if (_imagePath == null || _imagePath!.isEmpty)
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text('No image selected yet'),
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_imagePath!),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save Pattern Note'),
            ),
          ),
        ],
      ),
    );
  }
}
