import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_service.dart';
import '../data/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  bool _checkingAuth = true;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isLoading => _isLoading;
  bool get checkingAuth => _checkingAuth;
  String? get errorMessage => _errorMessage;

  /// Check existing session on application startup
  Future<void> checkAuth() async {
    _checkingAuth = true;
    notifyListeners();

    try {
      final token = await _api.getToken();
      if (token != null && token.isNotEmpty) {
        final response = await _api.dio.get('/auth/profile');
        if (response.statusCode == 200) {
          _user = User.fromJson(response.data);
        } else {
          await _api.clearTokens();
          _user = null;
        }
      } else {
        _user = null;
      }
    } catch (_) {
      // If token expired or network offline, keep clean state
      _user = null;
    } finally {
      _checkingAuth = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;

        if (accessToken != null) {
          await _api.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        }

        _user = User.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed. Check your connection.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.post('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;

        if (accessToken != null) {
          await _api.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        }

        _user = User.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Sign up failed.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _api.getRefreshToken();
      final Map<String, dynamic> body = {};
      if (refreshToken != null) {
        body['refreshToken'] = refreshToken;
      }
      await _api.dio.post('/auth/logout', data: body);
    } catch (_) {}

    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }
}
