import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────
//  AUTHENTICATION SERVICE
//  Single source of truth for auth state.
//  JWT token is persisted via ApiClient ↔ SharedPreferences,
//  so the user stays logged in across app restarts.
//
//  Endpoints:
//  • POST /api/auth/login
//  • POST /api/auth/register
//  • POST /api/auth/google
// ─────────────────────────────────────────────

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  static const String googleClientId =
      '1080132158665-cr3aiotc8u1f29soaefe95dshg1hfd0u.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: googleClientId,
    scopes: ['email', 'profile'],
  );

  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get authToken => ApiClient.instance.token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── App startup: restore session from persisted token ──────────────

  /// Call this once in main() before runApp().
  /// Restores a saved JWT token and marks the user as authenticated if found.
  Future<void> init() async {
    await ApiClient.instance.init();
    if (ApiClient.instance.hasToken) {
      // Token exists — restore auth state immediately (before async fetch)
      _isAuthenticated = true;
      _tryRestoreUserFromToken(); // populate minimal user from JWT claims
      notifyListeners();
      // Fetch full user profile from backend in background
      _fetchUserProfile();
    }
  }

  /// Fetch full user profile from /api/users/me and update _currentUser.
  Future<void> _fetchUserProfile() async {
    try {
      final data = await ApiClient.instance.get('/users/me', auth: true);
      if (data is Map<String, dynamic>) {
        final email = data['email'] as String? ?? _currentUser?.email ?? '';
        _currentUser = _userFromJson(data, email);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthService._fetchUserProfile error: $e');
      // Non-critical — keep whatever was restored from JWT
    }
  }

  void _tryRestoreUserFromToken() {
    try {
      final token = ApiClient.instance.token;
      if (token == null) return;
      // Decode JWT payload (base64url part 1)
      final parts = token.split('.');
      if (parts.length < 2) return;
      var payload = parts[1];
      // Pad base64 string
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      // Spring Boot JWT typically has 'sub' = email
      final email = map['sub'] as String? ?? '';
      if (email.isNotEmpty && _currentUser == null) {
        _currentUser = User(
          id: '',
          name: email.split('@').first,
          email: email,
          phone: '',
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {
      // Token parsing failed — not critical
    }
  }

  // ── Email & Password Login ─────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.instance.post(
        '/auth/login',
        body: {'email': email.trim(), 'password': password},
      );

      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        if (token != null) {
          await ApiClient.instance.setToken(token);
          _currentUser = _userFromJson(data['user'] as Map<String, dynamic>? ?? {}, email);
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Login failed. Please check your credentials.';
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('Login ApiException: ${e.message}');
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ───────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await ApiClient.instance.post(
        '/auth/register',
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
        },
      );

      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        if (token != null) {
          await ApiClient.instance.setToken(token);
          _currentUser = _userFromJson(data['user'] as Map<String, dynamic>? ?? {}, email);
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Registration failed. Please try again.';
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('Register ApiException: ${e.message}');
    } catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Google Sign-In ─────────────────────────────────────────────────

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _errorMessage = 'Failed to get Google ID token.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = await ApiClient.instance.post(
        '/auth/google',
        body: {'idToken': idToken},
      );

      if (data is Map<String, dynamic>) {
        final token = data['token'] as String?;
        if (token != null) {
          await ApiClient.instance.setToken(token);
          _currentUser = _userFromJson(
            data['user'] as Map<String, dynamic>? ?? {},
            googleUser.email,
          );
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Google sign-in failed on server.';
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('Google login ApiException: ${e.message}');
    } catch (e) {
      _errorMessage = 'Google sign-in error. Please try again.';
      debugPrint('Google login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Forgot Password ────────────────────────────────────────────────

  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulated — add backend endpoint when available
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ── Logout ─────────────────────────────────────────────────────────

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await ApiClient.instance.clearToken();
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile details (like phone number) on the backend
  Future<bool> updateProfile({required String phone}) async {
    if (!isAuthenticated || _currentUser == null) return false;
    try {
      final data = await ApiClient.instance.put(
        '/users/me',
        body: {
          'name': _currentUser!.name,
          'phone': phone,
          'profileImage': _currentUser!.avatarUrl,
        },
      );
      if (data is Map<String, dynamic>) {
        _currentUser = _userFromJson(data, _currentUser!.email);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('AuthService.updateProfile error: $e');
    }
    return false;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  User _userFromJson(Map<String, dynamic> json, String fallbackEmail) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? fallbackEmail.split('@').first,
      email: json['email'] ?? fallbackEmail,
      phone: json['phone'] ?? '',
      avatarUrl: json['profileImage'] ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
