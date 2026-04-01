import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/note_model.dart';

class NoteService {
  final Dio _dio = DioClient().dio;

  // ✅ Create Note
  Future<NoteModel> createNote({
    String title = '',
    String content = '',
    String? collectionId,
    String color = '',
  }) async {
    try {
      final response = await _dio.post(
        '/notes',
        data: {
          'title': title,
          'content': content,
          'collectionId': collectionId,
          'color': color,
        },
      );
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Get All Notes
  Future<List<NoteModel>> getUserNotes() async {
    try {
      print("Fetching notes from service...");
      final response = await _dio.get('/notes');
      print("Notes fetched: ${(response.data as List).length}");
      return (response.data as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print("Error in getUserNotes: $e");
      throw _handleError(e);
    }
  }

  // ✅ Update Note
  Future<NoteModel> updateNote(String id, Map<String, dynamic> fields) async {
    try {
      final response = await _dio.put('/notes/$id', data: fields);
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Toggle Global Pin
  Future<NoteModel> toggleGlobalPin(String id) async {
    try {
      final response = await _dio.patch('/notes/$id/pin-global');
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Toggle Collection Pin
  Future<NoteModel> toggleCollectionPin(String id) async {
    try {
      final response = await _dio.patch('/notes/$id/pin-collection');
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Toggle Archive
  Future<NoteModel> toggleArchive(String id) async {
    try {
      final response = await _dio.patch('/notes/$id/archive');
      return NoteModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Soft Delete Notes (multiple)
  Future<String> softDeleteNotes(List<String> ids) async {
    try {
      final response = await _dio.patch('/notes/delete', data: {'ids': ids});
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Restore Notes (multiple)
  Future<String> restoreNotes(List<String> ids) async {
    try {
      final response = await _dio.patch('/notes/restore', data: {'ids': ids});
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Permanent Delete Notes (multiple)
  Future<String> permanentDeleteNotes(List<String> ids) async {
    try {
      final response = await _dio.delete(
        '/notes/permanent',
        data: {'ids': ids},
      );
      return response.data['message'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 🔥 Central error handler
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
