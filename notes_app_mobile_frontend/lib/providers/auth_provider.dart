import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../../../core/network/auth_interceptor.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  unverified,
  blocked,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserModel? _user;
  UserModel? get user => _user;

  String? _token;
  String? get token => _token;

  // ================= CONSTRUCTOR =================
  AuthProvider() {
    init();
  }

  // ================= INIT =================
  Future<void> init() async {
    final savedToken = await _storage.read(key: "token");

    if (savedToken == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = savedToken;
    AuthInterceptor.setToken(_token);

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final fetchedUser = await _authService.getCurrentUser();
      if (fetchedUser == null) {
        await logout();
        return;
      }

      _user = fetchedUser;

      if (_user!.isBlocked) {
        _status = AuthStatus.blocked;
      } else if (!_user!.isVerified) {
        _status = AuthStatus.unverified;
      } else {
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      await logout(); // token invalid / expired
      return;
    }

    notifyListeners();
  }

  // ================= REGISTER =================
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final message = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      return message;
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= VERIFY OTP =================
  Future<String?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final message = await _authService.verifyOtp(email: email, otp: otp);

      _status = AuthStatus.unauthenticated;
      notifyListeners();

      return message;
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= LOGIN =================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _authService.login(email: email, password: password);

      _token = res["token"];
      _user = res["user"];

      // SAVE TOKEN 🔥
      await _storage.write(key: "token", value: _token);

      AuthInterceptor.setToken(_token);

      if (_user!.isBlocked) {
        _status = AuthStatus.blocked;
      } else if (!_user!.isVerified) {
        _status = AuthStatus.unverified;
      } else {
        _status = AuthStatus.authenticated;
      }

      notifyListeners();
      return res["message"];
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<String?> forgotPassword(String email) async {
    try {
      final message = await _authService.forgotPassword(email);
      return message;
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= RESET PASSWORD =================
  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final message = await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      _status = AuthStatus.unauthenticated;
      notifyListeners();

      return message;
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= RESEND OTP =================
  Future<String?> resendOtp() async {
    if (_user == null) throw "User not found";

    try {
      final message = await _authService.resendOtp(_user!.email);
      return message;
    } catch (e) {
      throw e.toString();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _token = null;
    _user = null;

    await _storage.delete(key: "token");

    AuthInterceptor.setToken(null);

    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
