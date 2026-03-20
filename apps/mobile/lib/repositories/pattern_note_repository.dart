import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/pattern_note_model.dart';

class PatternNoteRepository {
  Future<List<PatternNoteModel>> getAllNotes() async {
    final storageFile = await _notesStorageFile();
    if (!await storageFile.exists()) {
      return const <PatternNoteModel>[];
    }

    final raw = await storageFile.readAsString();
    if (raw.isEmpty) return const <PatternNoteModel>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <PatternNoteModel>[];

    final notes = decoded
        .whereType<Map>()
        .map((item) =>
            PatternNoteModel.fromJson(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) =>
          a.patternName.toLowerCase().compareTo(b.patternName.toLowerCase()));

    return notes;
  }

  Future<PatternNoteModel?> getNoteByPattern(String patternName) async {
    final normalized = normalizePattern(patternName);
    final notes = await getAllNotes();
    for (final note in notes) {
      if (note.normalizedPattern == normalized) {
        return note;
      }
    }
    return null;
  }

  Future<PatternNoteModel> saveNote({
    required String patternName,
    required String imageSourcePath,
    String? previousPatternName,
  }) async {
    final cleanedPattern = patternName.trim();
    final normalizedCurrent = normalizePattern(cleanedPattern);
    final normalizedPrevious = previousPatternName == null
        ? normalizedCurrent
        : normalizePattern(previousPatternName);

    final notes = await getAllNotes();
    final existingIndex = notes.indexWhere(
      (note) =>
          note.normalizedPattern == normalizedPrevious ||
          note.normalizedPattern == normalizedCurrent,
    );

    final existingNote = existingIndex >= 0 ? notes[existingIndex] : null;
    final savedImagePath = await _storeImage(
      sourcePath: imageSourcePath,
      patternName: cleanedPattern,
      currentStoredPath: existingNote?.imagePath,
    );

    final note = PatternNoteModel(
      patternName: cleanedPattern,
      imagePath: savedImagePath,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (existingIndex >= 0) {
      if (existingNote != null &&
          existingNote.imagePath.isNotEmpty &&
          existingNote.imagePath != savedImagePath) {
        await _deleteIfExists(existingNote.imagePath);
      }
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }

    await _writeNotes(notes);

    return note;
  }

  Future<void> deleteNote(String patternName) async {
    final notes = await getAllNotes();
    final normalized = normalizePattern(patternName);
    final targetIndex =
        notes.indexWhere((note) => note.normalizedPattern == normalized);
    if (targetIndex < 0) return;

    final note = notes.removeAt(targetIndex);
    await _deleteIfExists(note.imagePath);
    await _writeNotes(notes);
  }

  Future<String> _storeImage({
    required String sourcePath,
    required String patternName,
    String? currentStoredPath,
  }) async {
    if (currentStoredPath != null &&
        currentStoredPath.isNotEmpty &&
        sourcePath == currentStoredPath) {
      return currentStoredPath;
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Selected image not found');
    }

    final notesDir = await _notesDirectory();
    await notesDir.create(recursive: true);

    final extension = path.extension(sourcePath).isEmpty
        ? '.jpg'
        : path.extension(sourcePath);
    final fileName =
        '${_safeName(patternName)}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destination = File(path.join(notesDir.path, fileName));
    await sourceFile.copy(destination.path);
    return destination.path;
  }

  Future<Directory> _notesDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(baseDir.path, 'pattern_notes'));
  }

  Future<File> _notesStorageFile() async {
    final notesDir = await _notesDirectory();
    await notesDir.create(recursive: true);
    return File(path.join(notesDir.path, 'pattern_notes.json'));
  }

  Future<void> _writeNotes(List<PatternNoteModel> notes) async {
    final storageFile = await _notesStorageFile();
    await storageFile.writeAsString(
      jsonEncode(notes.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _deleteIfExists(String filePath) async {
    if (filePath.isEmpty) return;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _safeName(String value) {
    final cleaned =
        value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return cleaned
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
