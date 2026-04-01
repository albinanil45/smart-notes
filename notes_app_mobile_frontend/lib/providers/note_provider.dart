import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'socket_provider.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _service = NoteService();

  // ✅ Main lists
  final List<NoteModel> _notes = [];
  final List<NoteModel> _archivedNotes = [];
  final List<NoteModel> _deletedNotes = [];

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
      print("Fetching notes from server...");
      final data = await _service.getUserNotes();
      print("Notes fetched: ${data.length}");

      _notes.clear();
      _archivedNotes.clear();
      _deletedNotes.clear();
      _collectionNotes.clear();

      for (var note in data) {
        _addToCorrectList(note);
      }
    } catch (e) {
      print("Error fetching notes: $e");
      throw e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================
  // ✅ SOCKET INIT
  // =========================================================
  void attachSocket(SocketProvider socketProvider) {
    socketProvider.onNoteCreated = _handleCreate;
    socketProvider.onNoteUpdated = _handleUpdate;
    socketProvider.onNoteDeleted = _handleDelete;
    socketProvider.onNoteRestored = _handleRestore;
    socketProvider.onNotePermanentDeleted = _handlePermanentDelete;
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

    // ✅ Collection map
    if (note.collectionId != null) {
      _collectionNotes.putIfAbsent(note.collectionId!, () => []);
      _collectionNotes[note.collectionId!]!.add(note);
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
  // ✅ SOCKET HANDLERS
  // =========================================================

  void _handleCreate(NoteModel note) {
    _addToCorrectList(note);
    notifyListeners();
  }

  void _handleUpdate(NoteModel note) {
    _removeFromAllLists(note.id);
    _addToCorrectList(note);
    notifyListeners();
  }

  void _handleDelete(NoteModel note) {
    _removeFromAllLists(note.id);
    _addToCorrectList(note); // will go to deleted
    notifyListeners();
  }

  void _handleRestore(NoteModel note) {
    _removeFromAllLists(note.id);
    _addToCorrectList(note);
    notifyListeners();
  }

  void _handlePermanentDelete(String id) {
    _removeFromAllLists(id);
    notifyListeners();
  }

  // =========================================================
  // ✅ CRUD METHODS
  // =========================================================

  Future<void> createNote({
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

      _handleCreate(note);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateNote(String id, Map<String, dynamic> fields) async {
    try {
      final note = await _service.updateNote(id, fields);
      _handleUpdate(note);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleArchive(String id) async {
    try {
      final note = await _service.toggleArchive(id);
      _handleUpdate(note);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleGlobalPin(String id) async {
    try {
      final note = await _service.toggleGlobalPin(id);
      _handleUpdate(note);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleCollectionPin(String id) async {
    try {
      final note = await _service.toggleCollectionPin(id);
      _handleUpdate(note);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    try {
      await _service.softDeleteNotes(ids);
      // Socket will handle update
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> restoreNotes(List<String> ids) async {
    try {
      await _service.restoreNotes(ids);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> permanentDelete(List<String> ids) async {
    try {
      await _service.permanentDeleteNotes(ids);
    } catch (e) {
      throw e.toString();
    }
  }
}
