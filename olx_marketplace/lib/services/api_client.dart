import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  CENTRAL API CLIENT
//  Single HTTP layer for all backend calls.
//  • Selects correct base URL per platform
//  • Injects JWT Bearer token on every request
//  • Unwraps { success, message, data } wrapper
//  • Throws typed exceptions on errors
// ─────────────────────────────────────────────

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;
  ApiClient._internal();

  static const String _tokenKey = 'auth_token';

  /// Base URL: 10.0.2.2 for Android emulator, localhost everywhere else
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  String? _token;

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Load token from SharedPreferences on app start
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  /// Persist token after login/register
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear token on logout
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Header builders ────────────────────────────────────────────────
  Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Response unwrapping ────────────────────────────────────────────
  dynamic _unwrap(http.Response response) {
    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Invalid response format', response.statusCode);
    }
    if (response.statusCode >= 400) {
      throw ApiException(
        body is Map ? (body['message'] ?? 'An error occurred') : 'An error occurred',
        response.statusCode,
      );
    }
    return body is Map ? body['data'] : body;
  }

  // ── HTTP methods ───────────────────────────────────────────────────

  Future<dynamic> get(String path, {bool auth = false, Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.get(
        uri,
        headers: auth ? _authHeaders : _publicHeaders,
      ).timeout(const Duration(seconds: 15));
      return _unwrap(response);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      debugPrint('GET $path error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String path, {dynamic body, bool auth = false, Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse('$baseUrl$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final response = await http.post(
        uri,
        headers: auth ? _authHeaders : _publicHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _unwrap(response);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      debugPrint('POST $path error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _unwrap(response);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      debugPrint('PUT $path error: $e');
      rethrow;
    }
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _unwrap(response);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      debugPrint('PATCH $path error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _authHeaders,
      ).timeout(const Duration(seconds: 15));
      return _unwrap(response);
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      debugPrint('DELETE $path error: $e');
      rethrow;
    }
  }

  /// Upload a single image file (multipart/form-data)
  Future<String?> uploadImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/image'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      final data = _unwrap(response);
      return data is Map ? data['url'] as String? : null;
    } catch (e) {
      debugPrint('uploadImage error: $e');
      return null;
    }
  }

  /// Upload multiple image files (multipart/form-data)
  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/images'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      for (final path in filePaths) {
        request.files.add(await http.MultipartFile.fromPath('files', path));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      final data = _unwrap(response);
      if (data is Map && data['urls'] is List) {
        return List<String>.from(data['urls']);
      }
      return [];
    } catch (e) {
      debugPrint('uploadImages error: $e');
      return [];
    }
  }
}

// ── Exception types ────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException implements Exception {
  @override
  String toString() => 'UnauthorizedException: Token expired or invalid';
}
