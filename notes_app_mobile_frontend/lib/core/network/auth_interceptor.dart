import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  static String? _token;

  // Call this from Provider
  static void setToken(String? token) {
    _token = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null) {
      options.headers["Authorization"] = "Bearer $_token";
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Optional: handle global errors like 401
    if (err.response?.statusCode == 401) {
      // You can notify provider here later if needed
    }

    return handler.next(err);
  }
}
