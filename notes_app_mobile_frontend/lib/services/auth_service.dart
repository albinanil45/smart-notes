import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  // REGISTER
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "/auth/register",
        data: {"name": name, "email": email, "password": password},
      );

      return res.data["message"];
    } on DioException catch (e) {
      print(e.response?.statusCode);
      print(e.response?.data);
      print(e.message);
      print(e.type);

      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

  // VERIFY OTP
  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final res = await _dio.post(
        "/auth/verify-otp",
        data: {"email": email, "otp": otp},
      );

      return res.data["message"];
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Invalid OTP";
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "/auth/login",
        data: {"email": email, "password": password},
      );

      return {
        "token": res.data["token"],
        "user": UserModel.fromJson(res.data["user"]),
        "message": res.data["message"],
      };
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Login failed";
    }
  }

  // FORGOT PASSWORD
  Future<String> forgotPassword(String email) async {
    try {
      final res = await _dio.post(
        "/auth/forgot-password",
        data: {"email": email},
      );

      return res.data["message"];
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Error";
    }
  }

  // RESET PASSWORD
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        "/auth/reset-password",
        data: {"email": email, "otp": otp, "newPassword": newPassword},
      );

      return res.data["message"];
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Error";
    }
  }

  // RESEND OTP
  Future<String> resendOtp(String email) async {
    try {
      final res = await _dio.post("/auth/resend-otp", data: {"email": email});

      return res.data["message"];
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to resend OTP";
    }
  }

  // GET CURRENT USER
  Future<UserModel?> getCurrentUser() async {
    try {
      final res = await _dio.get("/auth/me");

      if (res.data == null) return null;

      return UserModel.fromJson(res.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Error";
    }
  }
}
