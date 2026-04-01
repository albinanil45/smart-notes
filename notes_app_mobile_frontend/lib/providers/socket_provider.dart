import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/collection_model.dart';
import '../services/socket_service.dart';

class SocketProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  // ✅ Connect and join rooms
  Future<void> init(String userId) async {
    try {
      print("Initializing socket connection for user: $userId");
      await _socketService.connect();
      print("Joining rooms for user: $userId");
      _socketService.joinNotes(userId);
      _socketService.joinCollections(userId);
      print("Attaching socket listeners for user: $userId");
      _listenToNotes();
      _listenToCollections();
    } catch (e) {
      throw e.toString();
    }
  }

  // 🔥 Callbacks — set these from NoteProvider / CollectionProvider
  void Function(NoteModel note)? onNoteCreated;
  void Function(NoteModel note)? onNoteUpdated;
  void Function(NoteModel note)? onNoteDeleted;
  void Function(NoteModel note)? onNoteRestored;
  void Function(String noteId)? onNotePermanentDeleted;

  void Function(CollectionModel collection)? onCollectionCreated;
  void Function(CollectionModel collection)? onCollectionUpdated;
  void Function(String collectionId)? onCollectionPermanentDeleted;

  // ✅ Note listener
  void _listenToNotes() {
    _socketService.onNoteChanged((data) {
      final type = data['type'];

      if (type == 'permanent_deleted') {
        final noteId = data['noteId'].toString();
        onNotePermanentDeleted?.call(noteId);
        return;
      }

      final note = NoteModel.fromJson(Map<String, dynamic>.from(data['note']));

      switch (type) {
        case 'created':
          onNoteCreated?.call(note);
          break;
        case 'updated':
          onNoteUpdated?.call(note);
          break;
        case 'deleted':
          onNoteDeleted?.call(note);
          break;
        case 'restored':
          onNoteRestored?.call(note);
          break;
      }
    });
  }

  // ✅ Collection listener
  void _listenToCollections() {
    _socketService.onCollectionChanged((data) {
      final type = data['type'];

      if (type == 'permanent_deleted') {
        final collectionId = data['collectionId'].toString();
        onCollectionPermanentDeleted?.call(collectionId);
        return;
      }

      final collection = CollectionModel.fromJson(
        Map<String, dynamic>.from(data['collection']),
      );

      switch (type) {
        case 'created':
          onCollectionCreated?.call(collection);
          break;
        case 'updated':
          onCollectionUpdated?.call(collection);
          break;
      }
    });
  }

  // ✅ Disconnect and clean up
  void dispose() {
    _socketService.offNoteChanged();
    _socketService.offCollectionChanged();
    _socketService.disconnect();
    super.dispose();
  }
}
