import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/collection_model.dart';

class CollectionService {
  final Dio _dio = DioClient().dio;

  // ✅ Create Collection
  Future<CollectionModel> createCollection({
    required String name,
    String color = '',
  }) async {
    try {
      final response = await _dio.post(
        '/collections',
        data: {'name': name, 'color': color},
      );
      return CollectionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Get All Collections
  Future<List<CollectionModel>> getUserCollections() async {
    try {
      final response = await _dio.get('/collections');
      return (response.data as List)
          .map((json) => CollectionModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Update Collection
  Future<CollectionModel> updateCollection(
    String id,
    Map<String, dynamic> fields,
  ) async {
    try {
      final response = await _dio.put('/collections/$id', data: fields);
      return CollectionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ Delete Collection
  Future<String> deleteCollection(String id) async {
    try {
      final response = await _dio.delete('/collections/$id');
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
