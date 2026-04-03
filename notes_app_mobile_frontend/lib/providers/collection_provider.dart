import 'package:flutter/material.dart';
import '../models/collection_model.dart';
import '../services/collection_service.dart';

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
  // ✅ HELPERS
  // =========================================================

  CollectionModel? _findById(String id) {
    try {
      return _collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // ✅ CRUD METHODS (MANUAL UPDATE)
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

      // Add newest at top
      _collections.insert(0, collection);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateCollection(String id, Map<String, dynamic> fields) async {
    try {
      final existing = _findById(id);
      if (existing == null) return;

      await _service.updateCollection(id, fields);

      // Manually update fields (optimistic update)
      final updated = existing.copyWith(
        name: fields['name'] ?? existing.name,
        color: fields['color'] ?? existing.color,
      );

      final index = _collections.indexWhere((c) => c.id == id);
      if (index != -1) {
        _collections[index] = updated;
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _service.deleteCollection(id);

      // Remove locally using ID
      _collections.removeWhere((c) => c.id == id);

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // =========================================================
  // ✅ PUBLIC HELPERS
  // =========================================================

  CollectionModel? getById(String id) {
    return _findById(id);
  }

  bool exists(String id) {
    return _collections.any((c) => c.id == id);
  }

  void clear() {
    _collections.clear();
    notifyListeners();
  }
}
