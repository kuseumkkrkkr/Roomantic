import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    final token = await getToken();
    final options = Options(headers: {});
    if (token != null) {
      options.headers!['Authorization'] = 'Bearer $token';
    }
    return _dio.get(path, queryParameters: queryParams, options: options);
  }

  Future<Response> post(String path, {dynamic data}) async {
    final token = await getToken();
    final options = Options(headers: {});
    if (token != null) {
      options.headers!['Authorization'] = 'Bearer $token';
    }
    return _dio.post(path, data: data, options: options);
  }

  // Auth
  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post('/auth/register', data: data);

  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post('/auth/login', data: data);

  Future<Response> getMe() => get('/me');

  // Profile
  Future<Response> getProfile() => get('/profile');
  Future<Response> saveProfile(Map<String, dynamic> data) =>
      post('/profile', data: data);

  // Matching
  Future<Response> getTopMatches({int topN = 5, bool excludeBlocked = true}) =>
      get('/match/top', queryParams: {'top_n': topN, 'exclude_blocked': excludeBlocked});

  Future<Response> getPairs({bool excludeBlocked = true}) =>
      get('/match/pairs', queryParams: {'exclude_blocked': excludeBlocked});
}
