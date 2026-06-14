import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalStore {
  static const _prefix = 'chat_history_v1_';

  String _key(String userUid) => '$_prefix$userUid';

  Future<Map<String, dynamic>> _readAll(String userUid) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key(userUid));
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _writeAll(String userUid, Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key(userUid), jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> getThreadMessages(
    String userUid,
    String threadId,
  ) async {
    if (userUid.isEmpty || threadId.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final all = await _readAll(userUid);
    final list = all[threadId];
    if (list is! List) {
      return <Map<String, dynamic>>[];
    }
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> saveThreadMessages(
    String userUid,
    String threadId,
    List<Map<String, dynamic>> messages,
  ) async {
    if (userUid.isEmpty || threadId.isEmpty) {
      return;
    }
    final all = await _readAll(userUid);
    all[threadId] = messages;
    await _writeAll(userUid, all);
  }

  Future<void> appendMessage(
    String userUid,
    String threadId,
    Map<String, dynamic> message,
  ) async {
    if (userUid.isEmpty || threadId.isEmpty) {
      return;
    }
    final all = await _readAll(userUid);
    final current = (all[threadId] is List)
        ? (all[threadId] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];
    current.add(Map<String, dynamic>.from(message));
    all[threadId] = current;
    await _writeAll(userUid, all);
  }

  Future<void> deleteThreadMessages(String userUid, String threadId) async {
    if (userUid.isEmpty || threadId.isEmpty) {
      return;
    }
    final all = await _readAll(userUid);
    all.remove(threadId);
    await _writeAll(userUid, all);
  }
}
