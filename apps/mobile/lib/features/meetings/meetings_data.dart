import 'dart:math';

import 'package:agnts_api/agnts_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api.dart';
import '../../core/data.dart';

/// Live and upcoming meetings (the live ones first). The live stream
/// refreshes it on meeting events.
final upcomingMeetingsProvider = FutureProvider.autoDispose<List<Meeting>>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getMeetingsApi().listMeetings(view: 'upcoming')).data ?? const [];
});

/// Calls that happened, newest first.
final pastMeetingsProvider = FutureProvider.autoDispose<List<MeetingSessionSummary>>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getMeetingsApi().listPastMeetingSessions(limit: 50)).data ?? const [];
});

/// What the server can do with meetings (and the workspace's rules).
final meetingSettingsProvider = FutureProvider.autoDispose<MeetingSettings>((ref) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getMeetingsApi().getMeetingSettings()).data!;
});

/// Refreshes everything showing meetings (a meeting event).
void invalidateMeetings(Ref ref) {
  ref.invalidate(upcomingMeetingsProvider);
  ref.invalidate(pastMeetingsProvider);
}

/// Whether a call's notes are still being made.
bool notesBusy(MeetingNotesStatus s) =>
    s == MeetingNotesStatus.queued || s == MeetingNotesStatus.transcribing || s == MeetingNotesStatus.writing;

/// Reads a meeting code from what people type or paste (the link too);
/// null when it is none. The result is abc-defg-hij.
String? parseMeetingCode(String s) {
  var v = s.trim();
  final i = v.lastIndexOf('/m/');
  if (i >= 0) v = v.substring(i + 3);
  v = v.split(RegExp(r'[?#]')).first.toLowerCase().replaceAll(RegExp(r'[-\s]'), '');
  if (!RegExp(r'^[a-z]{10}$').hasMatch(v)) return null;
  return '${v.substring(0, 3)}-${v.substring(3, 7)}-${v.substring(7)}';
}

/// The id this phone keeps, part of its identity in calls: a laptop and
/// this phone are two connections of the same person.
Future<String> meetingDevice() async {
  final p = await SharedPreferences.getInstance();
  var id = p.getString('meet.device') ?? '';
  if (!RegExp(r'^[a-z0-9]{4,16}$').hasMatch(id)) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random.secure();
    id = List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
    await p.setString('meet.device', id);
  }
  return id;
}

/// A time from the call's start as m:ss or h:mm:ss.
String meetingOffset(int ms) {
  final s = ms ~/ 1000;
  String two(int n) => n.toString().padLeft(2, '0');
  return s >= 3600 ? '${s ~/ 3600}:${two(s ~/ 60 % 60)}:${two(s % 60)}' : '${s ~/ 60}:${two(s % 60)}';
}
