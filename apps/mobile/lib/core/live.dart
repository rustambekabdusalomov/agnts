import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _events.stream;

  void start() {
    if (_running) return;
    _running = true;
    unawaited(_loop());
  }

  void stop() {
    _running = false;
    _cancel?.cancel();
  }

  Future<void> _loop() async {
    var backoff = const Duration(seconds: 2);
    while (_running) {
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
      if (!_running) return;
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
    final key = e['ticketKey'] as String? ?? '';
    ref.invalidate(dashboardProvider);
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
      case 'lessons_found':
        ref.invalidate(lessonsProvider);
        ref.invalidate(ticketLessonsProvider);
    }
    if (e['step'] == 'learn') ref.invalidate(learnQueueProvider);
  }
}

final liveProvider = Provider<LiveStream>((ref) {
  final live = LiveStream(ref);
  ref.onDispose(live.stop);
  return live;
});
