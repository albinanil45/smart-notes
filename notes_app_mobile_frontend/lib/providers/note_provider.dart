import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  // ✅ Main lists
  final List<NoteModel> _notes = [];
  final List<NoteModel> _archivedNotes = [];
  final List<NoteModel> _deletedNotes = [];

  String _searchKeyword = '';
  List<NoteModel> _searchResults = [];

  String get searchKeyword => _searchKeyword;
  List<NoteModel> get searchResults => _searchResults;

  // ✅ Collection-wise notes
  final Map<String, List<NoteModel>> _collectionNotes = {};

  // ✅ Getters
  List<NoteModel> get notes => _notes;
  List<NoteModel> get archivedNotes => _archivedNotes;
  List<NoteModel> get deletedNotes => _deletedNotes;
  Map<String, List<NoteModel>> get collectionNotes => _collectionNotes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =========================================================
  // ✅ INITIAL FETCH
  // =========================================================
  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getUserNotes();

      _notes.clear();
      _archivedNotes.clear();
      _deletedNotes.clear();
      _collectionNotes.clear();

      for (var note in data) {
        _addToCorrectList(note);
      }
    } catch (e) {
      throw e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================
  // ✅ CORE HELPERS
  // =========================================================

  void _addToCorrectList(NoteModel note) {
    if (note.isDeleted) {
      _deletedNotes.add(note);
    } else if (note.isArchived) {
      _archivedNotes.add(note);
    } else {
      _notes.add(note);
    }

    // Collection map
    if (note.collectionId != null) {
      _collectionNotes.putIfAbsent(note.collectionId!, () => []);
      _collectionNotes[note.collectionId!]!.add(note);
    }
  }

  NoteModel? _findNoteById(String id) {
    try {
      return [
        ..._notes,
        ..._archivedNotes,
        ..._deletedNotes,
      ].firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  void _removeFromAllLists(String id) {
    _notes.removeWhere((n) => n.id == id);
    _archivedNotes.removeWhere((n) => n.id == id);
    _deletedNotes.removeWhere((n) => n.id == id);

    for (var list in _collectionNotes.values) {
      list.removeWhere((n) => n.id == id);
    }
  }

  // =========================================================
  // ✅ CRUD METHODS (MANUAL ID-BASED UPDATE)
  // =========================================================

  Future<NoteModel?> createNote({
    String title = '',
    String content = '',
    String? collectionId,
    String color = '',
  }) async {
    try {
      final note = await _service.createNote(
        title: title,
        content: content,
        collectionId: collectionId,
        color: color,
      );

      _addToCorrectList(note);
      notifyListeners();
      return note;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateNote(String id, Map<String, dynamic> fields) async {
    try {
      final updatedNote = await _service.updateNote(id, fields);

      _removeFromAllLists(id);
      _addToCorrectList(updatedNote);
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleArchive(String id) async {
    try {
      final note = _findNoteById(id);
      if (note == null) return;

      await _service.toggleArchive(id);

      _removeFromAllLists(id);

      final updated = note.copyWith(isArchived: !note.isArchived);
      _addToCorrectList(updated);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleGlobalPin(String id) async {
    try {
      final note = _findNoteById(id);
      if (note == null) return;

      await _service.toggleGlobalPin(id);

      final updated = note.copyWith(isPinnedGlobal: !note.isPinnedGlobal);

      _removeFromAllLists(id);
      _addToCorrectList(updated);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleCollectionPin(String id) async {
    try {
      final note = _findNoteById(id);
      if (note == null) return;

      await _service.toggleCollectionPin(id);

      final updated = note.copyWith(
        isPinnedInCollection: !note.isPinnedInCollection,
      );

      _removeFromAllLists(id);
      _addToCorrectList(updated);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= DELETE =================

  Future<void> deleteNotes(List<String> ids) async {
    try {
      await _service.softDeleteNotes(ids);

      for (var id in ids) {
        final note = _findNoteById(id);
        if (note == null) continue;

        _removeFromAllLists(id);

        final deletedNote = note.copyWith(isDeleted: true);
        _addToCorrectList(deletedNote);
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= RESTORE =================

  Future<void> restoreNotes(List<String> ids) async {
    try {
      await _service.restoreNotes(ids);

      for (var id in ids) {
        final note = _findNoteById(id);
        if (note == null) continue;

        _removeFromAllLists(id);

        final restoredNote = note.copyWith(isDeleted: false, isArchived: false);

        _addToCorrectList(restoredNote);
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= PERMANENT DELETE =================

  Future<void> permanentDelete(List<String> ids) async {
    try {
      await _service.permanentDeleteNotes(ids);

      for (var id in ids) {
        _removeFromAllLists(id);
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  void searchNotes(String keyword) {
    _searchKeyword = keyword;

    if (keyword.trim().isEmpty) {
      _searchResults = [];
    } else {
      final lowerKeyword = keyword.toLowerCase();

      _searchResults = _notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(lowerKeyword);
        final contentMatch = note.content.toLowerCase().contains(lowerKeyword);

        return titleMatch || contentMatch;
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchKeyword = '';
    _searchResults = [];
    notifyListeners();
  }
}
