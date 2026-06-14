import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/chat_local_store.dart';

class MatchController extends GetxController {
  final _api = ApiService();
  final _chatLocalStore = ChatLocalStore();

  // Legacy fields (kept for backward compat)
  final topMatches = <Map<String, dynamic>>[].obs;
  final pairs = <Map<String, dynamic>>[].obs;

  // New protocol fields
  final poolCandidates = <Map<String, dynamic>>[].obs;
  final activeSessions = <Map<String, dynamic>>[].obs;
  final chatThreads = <Map<String, dynamic>>[].obs;
  final threadMessages = <String, List<Map<String, dynamic>>>{}.obs;
  final threadHasMoreHistory = <String, bool>{}.obs;
  final threadOlderLoading = <String, bool>{}.obs;
  final cooldownUntil = Rxn<DateTime>();
  final isLoading = false.obs;
  final poolRefreshCount = 0.obs;
  final Map<String, String> _threadOldestCreatedAt = {};
  final Map<String, String> _threadOldestUid = {};
  final Map<String, List<Map<String, dynamic>>> _threadSendQueue = {};
  final Set<String> _threadQueueProcessing = <String>{};
  static const Duration _sendFailTimeout = Duration(minutes: 1);
  static const Duration _minSendingVisible = Duration(milliseconds: 180);

  String? _currentUserUid;
  String get currentUserUid => _currentUserUid ?? '';
  Future<void>? _loadMeFuture;

  StreamSubscription<Map<String, dynamic>>? _chatStreamSub;
  Timer? _streamReconnectTimer;
  Timer? _pendingWatchdog;
  bool _isConnectingStream = false;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    _pendingWatchdog = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _expireStalledPendingMessages(),
    );
  }

  @override
  void onClose() {
    _streamReconnectTimer?.cancel();
    _chatStreamSub?.cancel();
    _pendingWatchdog?.cancel();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await _loadMe();
    await Future.wait([
      fetchPool(),
      fetchActiveSessions(),
      fetchThreads(),
      fetchCooldown(),
    ]);
    fetchLegacyMatches();
    _startChatStream();
  }

  Future<void> _loadMe() async {
    try {
      final me = await _api.getMe();
      _currentUserUid = me['uid']?.toString();
    } catch (_) {}
  }

  Future<void> _ensureCurrentUserLoaded() async {
    if ((_currentUserUid ?? '').isNotEmpty) {
      return;
    }
    _loadMeFuture ??= _loadMe().whenComplete(() {
      _loadMeFuture = null;
    });
    await _loadMeFuture;
  }

  void _startChatStream() {
    if (_chatStreamSub != null || _isConnectingStream) {
      return;
    }
    _isConnectingStream = true;
    _api
        .chatStream()
        .listen(
          _handleStreamEvent,
          onError: (_) {
            _chatStreamSub = null;
            _scheduleReconnect();
          },
          onDone: () {
            _chatStreamSub = null;
            _scheduleReconnect();
          },
          cancelOnError: true,
        )
        .let((sub) {
          _chatStreamSub = sub;
          _isConnectingStream = false;
        });
  }

  void _scheduleReconnect() {
    if (_streamReconnectTimer?.isActive == true) {
      return;
    }
    _streamReconnectTimer = Timer(const Duration(seconds: 3), () {
      _streamReconnectTimer = null;
      _startChatStream();
    });
  }

  void _handleStreamEvent(Map<String, dynamic> raw) {
    final event = raw['event']?.toString() ?? '';
    final payload = (raw['payload'] is Map<String, dynamic>)
        ? raw['payload'] as Map<String, dynamic>
        : <String, dynamic>{};

    switch (event) {
      case 'chat_message':
        _applyIncomingMessage(payload);
        break;
      case 'thread_state':
        _applyThreadState(payload);
        break;
      case 'match_confirmed':
      case 'rematch_notice':
        fetchActiveSessions();
        fetchThreads();
        fetchCooldown();
        break;
      default:
        break;
    }
  }

  void _applyIncomingMessage(Map<String, dynamic> payload) {
    final threadId = payload['thread_id']?.toString() ?? '';
    if (threadId.isEmpty) {
      return;
    }

    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final messageUid = payload['uid']?.toString();
    final exists =
        messageUid != null &&
        messageUid.isNotEmpty &&
        current.any((m) => m['uid']?.toString() == messageUid);
    if (!exists) {
      current.add(payload);
      current.sort(_sortByCreatedAt);
      threadMessages[threadId] = current;
      threadMessages.refresh();
      if (currentUserUid.isNotEmpty) {
        unawaited(_saveStoredThreadMessages(threadId, current));
      }
    }

    _upsertThread(
      threadId: threadId,
      sessionId: payload['session_id']?.toString(),
      status: 'open',
      closedReason: null,
    );

    // Server delete policy is handled by /threads/{id}/read.
    // Do not ACK-delete on receive to keep message pending until user read.
  }

  void _applyThreadState(Map<String, dynamic> payload) {
    final threadId = payload['thread_id']?.toString() ?? '';
    if (threadId.isEmpty) {
      return;
    }
    final status = payload['status']?.toString() ?? 'closed';
    final closedReason = payload['closed_reason']?.toString();
    final leftBy = payload['left_by']?.toString();

    if (closedReason == 'left' &&
        (leftBy?.isNotEmpty ?? false) &&
        leftBy == currentUserUid) {
      threadMessages.remove(threadId);
      threadMessages.refresh();
      threadHasMoreHistory.remove(threadId);
      threadHasMoreHistory.refresh();
      threadOlderLoading.remove(threadId);
      threadOlderLoading.refresh();
      _threadOldestCreatedAt.remove(threadId);
      _threadOldestUid.remove(threadId);
      chatThreads.removeWhere(
        (t) => t['thread_id'] == threadId || t['id'] == threadId,
      );
      chatThreads.refresh();
      return;
    }

    _upsertThread(
      threadId: threadId,
      sessionId: payload['session_id']?.toString(),
      status: status,
      closedReason: closedReason,
    );

    if (status != 'open') {
      _appendSystemMessageIfMissing(threadId, _closedReasonLabel(closedReason));
    }
  }

  void _upsertThread({
    required String threadId,
    required String status,
    required String? closedReason,
    String? sessionId,
  }) {
    final idx = chatThreads.indexWhere(
      (t) =>
          (t['thread_id']?.toString() ?? t['id']?.toString() ?? '') == threadId,
    );
    if (idx >= 0) {
      final updated = Map<String, dynamic>.from(chatThreads[idx]);
      updated['status'] = status;
      updated['closed_reason'] = closedReason;
      if (sessionId != null && sessionId.isNotEmpty) {
        updated['session_id'] = sessionId;
      }
      chatThreads[idx] = updated;
      chatThreads.refresh();
      return;
    }
    fetchThreads();
  }

  void _appendSystemMessageIfMissing(String threadId, String text) {
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final alreadyExists = current.any(
      (m) =>
          (m['type']?.toString() == 'system') &&
          (m['content']?.toString() == text),
    );
    if (alreadyExists) {
      return;
    }
    current.add({
      'uid': 'local-system-${DateTime.now().microsecondsSinceEpoch}',
      'thread_id': threadId,
      'sender': 'system',
      'type': 'system',
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    });
    current.sort(_sortByCreatedAt);
    threadMessages[threadId] = current;
    threadMessages.refresh();
    if (currentUserUid.isNotEmpty) {
      unawaited(_saveStoredThreadMessages(threadId, current));
    }
  }

  String _closedReasonLabel(String? reason) {
    if (reason == 'already_matched') return '사용자가 이미 매칭됨';
    if (reason == 'no_response') return '2일 무응답으로 종료됨';
    if (reason == 'cancelled') return '梨꾪똿??痍⑥냼?섏뿀?듬땲??';
    if (reason == 'rematch') return '재매칭으로 종료됨';
    if (reason == 'left') return '梨꾪똿諛⑹뿉???섍컮?듬땲??';
    return '梨꾪똿??醫낅즺?섏뿀?듬땲??';
  }

  // Legacy
  Future<void> fetchLegacyMatches() async {
    isLoading.value = true;
    try {
      final top = await _api.getTopMatches();
      if (top['matches'] != null) {
        topMatches.value = List<Map<String, dynamic>>.from(top['matches']);
      }
      pairs.value = List<Map<String, dynamic>>.from(await _api.getPairs());
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPool() async {
    try {
      final res = await _api.getPool();
      final data = res['candidates'] ?? res['pool'];
      if (data != null) {
        poolCandidates.value = List<Map<String, dynamic>>.from(data);
      }
    } catch (_) {}
  }

  Future<bool> refreshPool() async {
    isLoading.value = true;
    try {
      final res = await _api.refreshPool();
      final data = res['candidates'] ?? res['pool'];
      if (data != null) {
        poolCandidates.value = List<Map<String, dynamic>>.from(data);
        poolRefreshCount.value++;
        return poolCandidates.isNotEmpty;
      }
      return false;
    } catch (e) {
      Get.snackbar('??살첒', '?? ??덉쨮?⑥쥙臾???쎈솭: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveSessions() async {
    try {
      final sessions = await _api.getActiveSessions();
      activeSessions.value = List<Map<String, dynamic>>.from(sessions);
    } catch (_) {
      activeSessions.clear();
    }
  }

  Future<String?> enterSession(List<String> candidateUids) async {
    isLoading.value = true;
    try {
      final res = await _api.enterSession(candidateUids);
      await fetchActiveSessions();
      await fetchThreads();
      return res['session_id']?.toString();
    } catch (e) {
      Get.snackbar('??살첒', '?紐꾨???놁삢 ??쎈솭: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> confirmMatch(String sessionId) async {
    isLoading.value = true;
    try {
      final res = await _api.confirmMatch(sessionId);
      await fetchActiveSessions();
      await fetchThreads();
      await fetchCooldown();
      final status = res['status']?.toString() ?? 'waiting';
      if (status == 'confirmed') {
        Get.snackbar('筌띲끉臾??袁⑥┷', '筌띲끉臾???類ㅼ젟??뤿???щ빍??');
      } else if (status == 'waiting_delegate') {
        Get.snackbar('대기 중', '상대 사용자의 확인을 기다리고 있습니다.');
      }
      return true;
    } catch (e) {
      Get.snackbar('??살첒', '筌띲끉臾??類ㅼ젟 ??쎈솭: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelSession(String sessionId) async {
    isLoading.value = true;
    try {
      await _api.cancelSession(sessionId);
      await fetchActiveSessions();
      await fetchThreads();
      return true;
    } catch (e) {
      Get.snackbar('??살첒', '?紐꾨??띯뫁????쎈솭: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchThreads() async {
    try {
      chatThreads.value = List<Map<String, dynamic>>.from(
        await _api.getThreads(),
      );
    } catch (_) {
      chatThreads.clear();
    }
  }

  Future<bool> sendThreadMessage(String threadId, String text) async {
    if (isThreadClosed(threadId)) {
      Get.snackbar('??', '??? ????? ???? ?? ? ????.');
      return false;
    }
    final now = DateTime.now();
    final pendingUid = 'local-pending-${now.microsecondsSinceEpoch}';
    final pending = <String, dynamic>{
      'uid': pendingUid,
      'thread_id': threadId,
      'sender': currentUserUid,
      'content': text,
      'type': 'text',
      'created_at': now.toIso8601String(),
      'local_queued_at': now.toIso8601String(),
      'local_status': 'sending',
    };
    final staged = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    )..add(pending);
    staged.sort(_sortByCreatedAt);
    threadMessages[threadId] = staged;
    threadMessages.refresh();
    _updateOldestCursor(threadId, staged);
    if (currentUserUid.isNotEmpty) {
      unawaited(_saveAndReloadThreadMessages(threadId, staged));
    }
    _threadSendQueue.putIfAbsent(threadId, () => <Map<String, dynamic>>[]).add({
      'local_uid': pendingUid,
      'text': text,
      'queued_at': now.toIso8601String(),
    });
    unawaited(_processThreadQueue(threadId));
    if (currentUserUid.isEmpty) {
      unawaited(_ensureCurrentUserLoaded());
    }
    return true;
  }

  Future<bool> retryThreadMessage(String threadId, String localUid) async {
    await _ensureCurrentUserLoaded();
    if (isThreadClosed(threadId)) {
      return false;
    }
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final idx = current.indexWhere((m) => m['uid']?.toString() == localUid);
    if (idx < 0) {
      return false;
    }
    final msg = Map<String, dynamic>.from(current[idx]);
    final text = msg['content']?.toString() ?? '';
    if (text.trim().isEmpty) {
      return false;
    }
    msg['local_status'] = 'sending';
    final retryNow = DateTime.now();
    msg['created_at'] = retryNow.toIso8601String();
    msg['local_queued_at'] = retryNow.toIso8601String();
    current[idx] = msg;
    current.sort(_sortByCreatedAt);
    threadMessages[threadId] = current;
    threadMessages.refresh();
    _updateOldestCursor(threadId, current);
    if (currentUserUid.isNotEmpty) {
      unawaited(_saveAndReloadThreadMessages(threadId, current));
    }
    _threadSendQueue.putIfAbsent(threadId, () => <Map<String, dynamic>>[]).add({
      'local_uid': localUid,
      'text': text,
      'queued_at': DateTime.now().toIso8601String(),
    });
    unawaited(_processThreadQueue(threadId));
    return true;
  }

  Future<void> fetchThreadMessages(
    String threadId, {
    int limit = 30,
    bool reset = true,
  }) async {
    try {
      final server = List<Map<String, dynamic>>.from(
        await _api.getThreadMessages(threadId, limit: limit),
      );
      final normalized = server.map((m) {
        final next = Map<String, dynamic>.from(m);
        next.remove('local_pending');
        return next;
      }).toList()..sort(_sortByCreatedAt);
      final merged = _mergeWithCurrentMessages(threadId, normalized);
      threadMessages[threadId] = merged;
      threadMessages.refresh();
      threadHasMoreHistory[threadId] = normalized.length >= limit;
      threadHasMoreHistory.refresh();
      threadOlderLoading[threadId] = false;
      threadOlderLoading.refresh();
      _updateOldestCursor(threadId, merged);
      if (currentUserUid.isNotEmpty) {
        await _saveStoredThreadMessages(threadId, merged);
      }
    } catch (_) {}
  }

  Future<void> openThreadMessages(String threadId, {int limit = 30}) async {
    await _ensureCurrentUserLoaded();
    final local = await _loadStoredThreadMessages(threadId);
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final mergedLocal = _mergeMessages(current, local);
    mergedLocal.sort(_sortByCreatedAt);
    threadMessages[threadId] = mergedLocal;
    threadMessages.refresh();
    _updateOldestCursor(threadId, mergedLocal);
    threadHasMoreHistory[threadId] = true;
    threadHasMoreHistory.refresh();
    await fetchThreadMessages(threadId, limit: limit, reset: true);
  }

  Future<bool> fetchOlderThreadMessages(
    String threadId, {
    int limit = 30,
  }) async {
    final isLoading = threadOlderLoading[threadId] == true;
    if (isLoading || threadHasMoreHistory[threadId] == false) {
      return false;
    }
    final beforeCreatedAt = _threadOldestCreatedAt[threadId];
    if (beforeCreatedAt == null || beforeCreatedAt.isEmpty) {
      return false;
    }
    threadOlderLoading[threadId] = true;
    threadOlderLoading.refresh();
    try {
      final older = List<Map<String, dynamic>>.from(
        await _api.getThreadMessages(
          threadId,
          limit: limit,
          beforeCreatedAt: beforeCreatedAt,
          beforeUid: _threadOldestUid[threadId],
        ),
      );
      if (older.isEmpty) {
        threadHasMoreHistory[threadId] = false;
        threadHasMoreHistory.refresh();
        return false;
      }
      final current = List<Map<String, dynamic>>.from(
        threadMessages[threadId] ?? const [],
      );
      final merged = _mergeMessages(older, current);
      threadMessages[threadId] = merged;
      threadMessages.refresh();
      threadHasMoreHistory[threadId] = older.length >= limit;
      threadHasMoreHistory.refresh();
      _updateOldestCursor(threadId, merged);
      if (currentUserUid.isNotEmpty) {
        await _saveStoredThreadMessages(threadId, merged);
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      threadOlderLoading[threadId] = false;
      threadOlderLoading.refresh();
    }
  }

  Future<void> markThreadRead(String threadId) async {
    try {
      await _api.markThreadRead(threadId);
    } catch (_) {}
  }

  Future<bool> leaveThread(String threadId) async {
    try {
      await _api.leaveThread(threadId);
      await _removeStoredThreadMessages(threadId);
      threadMessages.remove(threadId);
      threadMessages.refresh();
      threadHasMoreHistory.remove(threadId);
      threadHasMoreHistory.refresh();
      threadOlderLoading.remove(threadId);
      threadOlderLoading.refresh();
      _threadOldestCreatedAt.remove(threadId);
      _threadOldestUid.remove(threadId);
      chatThreads.removeWhere(
        (t) => t['thread_id'] == threadId || t['id'] == threadId,
      );
      chatThreads.refresh();
      return true;
    } catch (e) {
      Get.snackbar('??살첒', '筌?쑵?욤쳸????疫???쎈솭: $e');
      return false;
    }
  }

  Future<void> fetchCooldown() async {
    try {
      final res = await _api.getCooldownStatus();
      final until = res['cooldown_until'];
      if (until != null) {
        cooldownUntil.value = DateTime.tryParse(until.toString());
      } else {
        cooldownUntil.value = null;
      }
    } catch (_) {
      cooldownUntil.value = null;
    }
  }

  bool get isInCooldown {
    if (cooldownUntil.value == null) return false;
    return DateTime.now().isBefore(cooldownUntil.value!);
  }

  bool isThreadClosed(String threadId) {
    final t = getThreadById(threadId);
    if (t == null) return false;
    return (t['status']?.toString() ?? 'open') != 'open';
  }

  String threadClosedReason(String threadId) {
    final t = getThreadById(threadId);
    if (t == null) return '';
    return t['closed_reason']?.toString() ?? '';
  }

  bool get canRematch {
    if (chatThreads.isEmpty || isInCooldown) return false;
    return chatThreads.every(
      (t) => (t['status']?.toString() ?? 'open') != 'open',
    );
  }

  Map<String, dynamic>? getPoolCandidateByUid(String uid) {
    return poolCandidates.firstWhereOrNull(
      (c) => c['uid'] == uid || c['user_uid'] == uid,
    );
  }

  Map<String, dynamic>? getSessionById(String sessionId) {
    return activeSessions.firstWhereOrNull(
      (s) => s['session_id'] == sessionId || s['id'] == sessionId,
    );
  }

  Map<String, dynamic>? getThreadById(String threadId) {
    return chatThreads.firstWhereOrNull(
      (t) => t['thread_id'] == threadId || t['id'] == threadId,
    );
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> server,
  ) {
    final merged = <String, Map<String, dynamic>>{};
    for (final m in [...local, ...server]) {
      merged[_messageKey(m)] = Map<String, dynamic>.from(m);
    }
    final list = merged.values.toList();
    list.sort(_sortByCreatedAt);
    return list;
  }

  List<Map<String, dynamic>> _mergeWithCurrentMessages(
    String threadId,
    List<Map<String, dynamic>> serverMessages,
  ) {
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    return _mergeMessages(current, serverMessages);
  }

  String _messageKey(Map<String, dynamic> m) {
    final uid = m['uid']?.toString() ?? '';
    if (uid.isNotEmpty) {
      return 'uid:$uid';
    }
    final sender = m['sender']?.toString() ?? '';
    final receiver = m['receiver']?.toString() ?? '';
    final type = m['type']?.toString() ?? '';
    final content = m['content']?.toString() ?? '';
    final createdAt = m['created_at']?.toString() ?? '';
    final threadId = m['thread_id']?.toString() ?? '';
    return 'legacy:$threadId|$sender|$receiver|$type|$content|$createdAt';
  }

  int _sortByCreatedAt(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aTs = DateTime.tryParse(a['created_at']?.toString() ?? '');
    final bTs = DateTime.tryParse(b['created_at']?.toString() ?? '');
    if (aTs == null && bTs == null) return 0;
    if (aTs == null) return -1;
    if (bTs == null) return 1;
    return aTs.compareTo(bTs);
  }

  void _updateOldestCursor(
    String threadId,
    List<Map<String, dynamic>> messages,
  ) {
    if (messages.isEmpty) {
      _threadOldestCreatedAt.remove(threadId);
      _threadOldestUid.remove(threadId);
      return;
    }
    final oldest = messages.firstWhereOrNull(
      (m) => (m['created_at']?.toString().isNotEmpty ?? false),
    );
    if (oldest == null) {
      _threadOldestCreatedAt.remove(threadId);
      _threadOldestUid.remove(threadId);
      return;
    }
    _threadOldestCreatedAt[threadId] = oldest['created_at']?.toString() ?? '';
    _threadOldestUid[threadId] = oldest['uid']?.toString() ?? '';
  }

  Future<void> _processThreadQueue(String threadId) async {
    if (_threadQueueProcessing.contains(threadId)) {
      return;
    }
    _threadQueueProcessing.add(threadId);
    try {
      await _ensureCurrentUserLoaded();
      while ((_threadSendQueue[threadId]?.isNotEmpty ?? false)) {
        final queue = _threadSendQueue[threadId]!;
        final task = Map<String, dynamic>.from(queue.removeAt(0));
        final localUid = task['local_uid']?.toString() ?? '';
        final text = task['text']?.toString() ?? '';
        final queuedAt = DateTime.tryParse(task['queued_at']?.toString() ?? '');

        if (localUid.isEmpty || text.isEmpty) {
          continue;
        }
        if (queuedAt != null &&
            DateTime.now().difference(queuedAt) >= _sendFailTimeout) {
          await _markMessageAsFailed(threadId, localUid);
          continue;
        }
        if (currentUserUid.isEmpty) {
          await _markMessageAsFailed(threadId, localUid);
          continue;
        }
        if (isThreadClosed(threadId)) {
          await _markMessageAsFailed(threadId, localUid);
          continue;
        }

        try {
          final res = await _api
              .sendThreadMessage(threadId, text)
              .timeout(_sendFailTimeout);
          await _resolvePendingMessage(threadId, localUid, text, res);
        } catch (_) {
          await _markMessageAsFailed(threadId, localUid);
        }
      }
    } finally {
      _threadQueueProcessing.remove(threadId);
    }
  }

  Future<void> _resolvePendingMessage(
    String threadId,
    String localUid,
    String text,
    Map<String, dynamic> res,
  ) async {
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final pendingIndex = current.indexWhere((m) => m['uid']?.toString() == localUid);
    if (pendingIndex >= 0) {
      final pendingMsg = current[pendingIndex];
      final queuedAt = DateTime.tryParse(
        pendingMsg['local_queued_at']?.toString() ??
            pendingMsg['created_at']?.toString() ??
            '',
      );
      if (queuedAt != null) {
        final elapsed = DateTime.now().difference(queuedAt);
        if (elapsed < _minSendingVisible) {
          await Future<void>.delayed(_minSendingVisible - elapsed);
        }
      }
    }

    final resolved = <String, dynamic>{
      'uid':
          res['uid']?.toString() ??
          'local-${DateTime.now().microsecondsSinceEpoch}',
      'thread_id': threadId,
      'sender': currentUserUid,
      'content': text,
      'type': 'text',
      'created_at':
          res['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    };

    final idx = current.indexWhere((m) => m['uid']?.toString() == localUid);
    if (idx >= 0) {
      current[idx] = resolved;
    } else {
      final fallbackIdx = current.lastIndexWhere(
        (m) =>
            (m['local_status']?.toString() == 'sending' ||
                m['local_status']?.toString() == 'failed') &&
            (m['sender']?.toString() ?? '') == currentUserUid &&
            (m['content']?.toString() ?? '') == text,
      );
      if (fallbackIdx >= 0) {
        current[fallbackIdx] = resolved;
      } else {
        current.add(resolved);
      }
    }

    current.sort(_sortByCreatedAt);
    threadMessages[threadId] = current;
    threadMessages.refresh();
    _updateOldestCursor(threadId, current);
    if (currentUserUid.isNotEmpty) {
      unawaited(_saveAndReloadThreadMessages(threadId, current));
    }
  }

  Future<void> _markMessageAsFailed(String threadId, String localUid) async {
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final idx = current.indexWhere((m) => m['uid']?.toString() == localUid);
    if (idx < 0) {
      return;
    }

    final updated = Map<String, dynamic>.from(current[idx]);
    updated['local_status'] = 'failed';
    updated['local_failed_at'] = DateTime.now().toIso8601String();
    current[idx] = updated;
    current.sort(_sortByCreatedAt);
    threadMessages[threadId] = current;
    threadMessages.refresh();
    _updateOldestCursor(threadId, current);
    if (currentUserUid.isNotEmpty) {
      unawaited(_saveAndReloadThreadMessages(threadId, current));
    }
  }

  Future<void> _saveStoredThreadMessages(
    String threadId,
    List<Map<String, dynamic>> messages,
  ) async {
    await _ensureCurrentUserLoaded();
    if (currentUserUid.isEmpty) {
      return;
    }
    if (kIsWeb) {
      await _api.putWebLocalThreadMessages(threadId, messages);
      return;
    }
    await _chatLocalStore.saveThreadMessages(
      currentUserUid,
      threadId,
      messages,
    );
  }

  Future<List<Map<String, dynamic>>> _loadStoredThreadMessages(
    String threadId,
  ) async {
    await _ensureCurrentUserLoaded();
    if (currentUserUid.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    if (kIsWeb) {
      final rows = await _api.getWebLocalThreadMessages(threadId);
      return List<Map<String, dynamic>>.from(rows);
    }
    return _chatLocalStore.getThreadMessages(currentUserUid, threadId);
  }

  Future<void> _saveAndReloadThreadMessages(
    String threadId,
    List<Map<String, dynamic>> messages,
  ) async {
    await _saveStoredThreadMessages(threadId, messages);
    final reloaded = await _loadStoredThreadMessages(threadId);
    final current = List<Map<String, dynamic>>.from(
      threadMessages[threadId] ?? const [],
    );
    final merged = _mergeMessages(reloaded, current);
    merged.sort(_sortByCreatedAt);
    threadMessages[threadId] = merged;
    threadMessages.refresh();
    _updateOldestCursor(threadId, merged);
  }

  Future<void> _removeStoredThreadMessages(String threadId) async {
    await _ensureCurrentUserLoaded();
    if (currentUserUid.isEmpty) {
      return;
    }
    if (kIsWeb) {
      await _api.deleteWebLocalThreadMessages(threadId);
      return;
    }
    await _chatLocalStore.deleteThreadMessages(currentUserUid, threadId);
  }

  void _expireStalledPendingMessages() {
    final now = DateTime.now();
    for (final entry in threadMessages.entries) {
      final threadId = entry.key;
      final messages = List<Map<String, dynamic>>.from(entry.value);
      var touched = false;
      for (var i = 0; i < messages.length; i++) {
        final m = Map<String, dynamic>.from(messages[i]);
        if (m['local_status']?.toString() != 'sending') {
          continue;
        }
        final created = DateTime.tryParse(m['created_at']?.toString() ?? '');
        if (created == null) {
          continue;
        }
        if (now.difference(created) >= _sendFailTimeout) {
          m['local_status'] = 'failed';
          m['local_failed_at'] = now.toIso8601String();
          messages[i] = m;
          touched = true;
          final localUid = m['uid']?.toString() ?? '';
          if (localUid.isNotEmpty) {
            _threadSendQueue[threadId]?.removeWhere(
              (task) => task['local_uid']?.toString() == localUid,
            );
          }
        }
      }
      if (touched) {
        messages.sort(_sortByCreatedAt);
        threadMessages[threadId] = messages;
        _updateOldestCursor(threadId, messages);
        if (currentUserUid.isNotEmpty) {
          unawaited(_saveAndReloadThreadMessages(threadId, messages));
        }
      }
    }
    threadMessages.refresh();
  }
}

extension _LetExt<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
