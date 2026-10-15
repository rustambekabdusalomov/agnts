import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/assistant/assistant_data.dart';
import '../features/tickets/pull_comments.dart';
import 'api.dart';
import 'data.dart';

/// Follows the server's event stream while the app is open and refreshes
/// whatever the event affects. Reconnects with Last-Event-ID after drops.
class LiveStream {
  LiveStream(this.ref);
  final Ref ref;
  CancelToken? _cancel;
  int _lastId = 0;
  bool _running = false;
  int _gen = 0; // bumped on stop, so an old loop ends instead of running on
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _events.stream;

  void start() {
    // The stream belongs to a workspace; an Admin account with none has no
    // stream to follow (the server answers 409).
    if (_running || (ref.read(adminProvider)?.only ?? false)) return;
    _running = true;
    unawaited(_loop(_gen));
  }

  void stop() {
    _running = false;
    _gen++;
    _cancel?.cancel();
  }

  /// Follows another workspace's stream from its start: the old event ids
  /// mean nothing there.
  void restart() {
    stop();
    _lastId = 0;
    start();
  }

  Future<void> _loop(int gen) async {
    bool live() => _running && gen == _gen;
    var backoff = const Duration(seconds: 2);
    while (live()) {
      final api = ref.read(apiProvider);
      if (api == null) return;
      _cancel = CancelToken();
      try {
        final res = await api.dio.get<ResponseBody>(
          '/events/stream',
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(minutes: 2), // the server pings every 25s
            headers: {'Accept': 'text/event-stream', if (_lastId > 0) 'Last-Event-ID': '$_lastId'},
          ),
          cancelToken: _cancel,
        );
        backoff = const Duration(seconds: 2);
        var data = StringBuffer();
        await for (final line in res.data!.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter())) {
          if (!live()) break;
          if (line.startsWith('id: ')) {
            _lastId = int.tryParse(line.substring(4)) ?? _lastId;
          } else if (line.startsWith('data: ')) {
            data.write(line.substring(6));
          } else if (line.isEmpty && data.isNotEmpty) {
            _handle(data.toString());
            data = StringBuffer();
          }
        }
      } catch (_) {
        // Dropped, timed out or cancelled: retry below.
      }
      if (!live()) return;
      await Future<void>.delayed(backoff);
      backoff = Duration(seconds: (backoff.inSeconds * 2).clamp(2, 30));
    }
  }

  void _handle(String raw) {
    Map<String, dynamic> e;
    try {
      e = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    _events.add(e);
    // The asker's own answers being made: nothing else changed.
    if ((e['type'] as String? ?? '').startsWith('assistant_')) {
      onAssistantEvent(ref, e);
      return;
    }
    final key = e['ticketKey'] as String? ?? '';
    ref.invalidate(dashboardProvider);
    ref.invalidate(queueProvider);
    if (key.isNotEmpty) {
      ref.invalidate(ticketProvider(key));
      ref.invalidate(ticketEventsProvider(key));
      ref.invalidate(ticketsProvider);
    }
    switch (e['type']) {
      case 'usage_updated':
      case 'rate_limit':
        ref.invalidate(usageProvider);
      case 'settings_changed':
        ref.invalidate(settingsProvider);
      case 'integration_changed':
        ref.invalidate(integrationsProvider);
      case 'workspace':
        ref.invalidate(meProvider);
      case 'lessons_found':
        ref.invalidate(lessonsProvider);
        ref.invalidate(ticketLessonsProvider);
      case 'pr_comment':
      case 'threads_feedback':
      case 'review_posted':
        ref.invalidate(pullThreadsProvider); // a pull request's conversation on the git host changed
        ref.invalidate(reviewDraftsProvider);
      case 'ci_failure':
        ref.invalidate(ciFailuresProvider);
        ref.invalidate(ciFailureProvider);
        ref.invalidate(ticketCIProvider);
    }
    if (e['step'] == 'learn') ref.invalidate(learnQueueProvider);
    // A finished review run writes its drafts.
    if (e['type'] == 'state_changed') ref.invalidate(reviewDraftsProvider);
  }
}

final liveProvider = Provider<LiveStream>((ref) {
  final live = LiveStream(ref);
  ref.onDispose(live.stop);
  return live;
});
