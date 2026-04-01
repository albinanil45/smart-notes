import 'package:flutter/material.dart';
import '../models/collection_model.dart';
import '../services/collection_service.dart';
import 'socket_provider.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionService _service = CollectionService();

  // ✅ Collections list
  List<CollectionModel> _collections = [];

  List<CollectionModel> get collections => _collections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =========================================================
  // ✅ FETCH ALL COLLECTIONS
  // =========================================================
  Future<void> fetchCollections() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getUserCollections();
      _collections = data;
    } catch (e) {
      throw e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================
  // ✅ SOCKET ATTACH
  // =========================================================
  void attachSocket(SocketProvider socketProvider) {
    socketProvider.onCollectionCreated = _handleCreate;
    socketProvider.onCollectionUpdated = _handleUpdate;
    socketProvider.onCollectionPermanentDeleted = _handleDelete;
  }

  // =========================================================
  // ✅ SOCKET HANDLERS
  // =========================================================

  void _handleCreate(CollectionModel collection) {
    _collections.insert(0, collection); // newest first
    notifyListeners();
  }

  void _handleUpdate(CollectionModel collection) {
    final index = _collections.indexWhere((c) => c.id == collection.id);

    if (index != -1) {
      _collections[index] = collection;
      notifyListeners();
    }
  }

  void _handleDelete(String id) {
    _collections.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // =========================================================
  // ✅ CRUD METHODS
  // =========================================================

  Future<void> createCollection({
    required String name,
    String color = '',
  }) async {
    try {
      final collection = await _service.createCollection(
        name: name,
        color: color,
      );

      _handleCreate(collection);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateCollection(String id, Map<String, dynamic> fields) async {
    try {
      final updated = await _service.updateCollection(id, fields);
      _handleUpdate(updated);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _service.deleteCollection(id);
      // Socket will handle removal
    } catch (e) {
      throw e.toString();
    }
  }

  // =========================================================
  // ✅ HELPERS
  // =========================================================

  CollectionModel? getById(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool exists(String id) {
    return _collections.any((c) => c.id == id);
  }

  // Optional: clear all (logout case)
  void clear() {
    _collections.clear();
    notifyListeners();
  }
}
