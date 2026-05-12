import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _singleton = ApiService._internal();
  factory ApiService() => _singleton;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:5000/api'
          : 'http://localhost:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          clearToken();
        }
        handler.next(e);
      },
    ));
  }

  late final Dio _dio;

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('jwt_token');
  }

  Future<void> setToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('jwt_token');
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data is Map ? res.data : {'data': res.data};
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.post(path, data: data);
      return res.data is Map ? res.data : {'data': res.data};
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final res = await _dio.patch(path, data: data);
      return res.data is Map ? res.data : {'data': res.data};
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      return e.response!.data['error']?.toString() ?? e.message ?? '요청 실패';
    }
    return e.message ?? '네트워크 오류';
  }

  // Auth
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) => post('/auth/register', data: body);
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) => post('/auth/login', data: body);
  Future<Map<String, dynamic>> getMe() => get('/me');

  // Profile
  Future<Map<String, dynamic>> getProfile() => get('/profile');
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> body) => post('/profile', data: body);

  // Persona
  Future<Map<String, dynamic>> getPersona() => get('/persona');

  // Matches
  Future<Map<String, dynamic>> getTopMatches() => get('/match/top');
  Future<List<dynamic>> getPairs() async {
    final res = await get('/match/pairs');
    return res['pairs'] ?? [];
  }

  // Match requests
  Future<Map<String, dynamic>> createMatchRequest(String targetUid) =>
      post('/match/request', data: {'to_user': targetUid});
  Future<Map<String, dynamic>> respondMatchRequest(String requestId, String status) =>
      patch('/match/request/$requestId', data: {'status': status});
  Future<Map<String, dynamic>> getMatchRequests({String direction = 'in'}) =>
      get('/match/requests', query: {'direction': direction});

  // Chat
  Future<Map<String, dynamic>> sendChat(String receiverUid, String text) =>
      post('/chat/send', data: {'receiver': receiverUid, 'content': text, 'type': 'text'});
  Future<Map<String, dynamic>> getMessages(String partnerUid, {int limit = 50}) =>
      get('/chat/messages', query: {'with': partnerUid, 'limit': limit});
  Future<Map<String, dynamic>> markRead(String partnerUid) =>
      post('/chat/read', data: {'with': partnerUid});

  Stream<Map<String, dynamic>> chatStream() async* {
    final token = await getToken();
    if (token == null) throw ApiException('Not authenticated');
    final client = Dio(BaseOptions(
      baseUrl: _dio.options.baseUrl,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'text/event-stream'},
      responseType: ResponseType.stream,
    ));
    try {
      final response = await client.get('/chat/stream');
      final stream = response.data.stream as Stream<List<int>>;
      await for (final chunk in stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final payload = line.substring(6).trim();
            if (payload.isEmpty) continue;
            try {
              final json = jsonDecode(payload);
              yield json is Map<String, dynamic> ? json : {'data': json};
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      throw ApiException(_extractError(e), statusCode: e.response?.statusCode);
    }
  }

  // Reviews
  Future<Map<String, dynamic>> submitReview(String revieweeUid, int rating, String text) =>
      post('/reviews', data: {'reviewee': revieweeUid, 'rating': rating, 'body': text});
  Future<Map<String, dynamic>> getReviews(String revieweeUid) => get('/reviews/$revieweeUid');
}
