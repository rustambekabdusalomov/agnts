import 'dart:async';
import 'dart:convert';

import 'package:agnts_api/agnts_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../repos/manage_widgets.dart' show confirmAction;
import 'meetings_data.dart';

/// A meeting's call (/m/abc-defg-hij, from a list, a push or a link): the
/// lobby with the camera's preview, the waiting room when the host must
/// let you in, the call, and what is left once it is over. Members join
/// with their session; hosts moderate from the people sheet and the host
/// menu as on the web.
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.code});
  final String code;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

enum _Phase { lobby, joining, waiting, connecting, inCall, left, ended, removed, refused, error }

// Topics agnts sends into the room, and the attribute of a raised hand.
const _topicChat = 'agnts.chat';
const _topicKnock = 'agnts.knock';
const _topicState = 'agnts.state';
const _topicAskUnmute = 'agnts.ask-unmute';
const _attrHand = 'agnts.hand';
const _attrRole = 'agnts.role';

class _CallScreenState extends ConsumerState<CallScreen> {
  _Phase _phase = _Phase.lobby;
  String _error = '';
  String _refusal = '';
  PublicMeeting? _info;
  MeetingGrant? _grant;
  MeetingCall? _state;
  Room? _room;
  EventsListener<RoomEvent>? _events;
  LocalVideoTrack? _preview;
  bool _micOn = true;
  bool _camOn = true;
  bool _speaker = true;
  CameraPosition _camera = CameraPosition.front;
  int _knockId = 0;
  String _knockToken = '';
  final _messages = <MeetingMessage>[];
  int _unread = 0;
  bool _chatOpen = false;
  Map<String, dynamic> _meta = const {};
  Timer? _stateTimer;
  bool _disposed = false;

  MeetingsApi get _api => ref.read(apiProvider)!.getMeetingsApi();
  String get _seat => _grant?.seat ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _disposed = true;
    _stateTimer?.cancel();
    unawaited(_preview?.stop());
    unawaited(_events?.dispose());
    unawaited(_room?.disconnect());
    unawaited(_room?.dispose());
    super.dispose();
  }

  void _set(VoidCallback fn) {
    if (!_disposed && mounted) setState(fn);
  }

  Future<void> _load() async {
    try {
      final info = (await _api.getPublicMeeting(code: widget.code)).data;
      _set(() => _info = info);
      await _startPreview();
    } catch (e) {
      _set(() {
        _phase = _Phase.error;
        _error = e is DioException && e.response?.statusCode == 404 ? 'not_found' : errorMessage(e, '');
      });
    }
  }

  Future<void> _startPreview() async {
    await _preview?.stop();
    _preview = null;
    if (!_camOn) {
      _set(() {});
      return;
    }
    try {
      final t = await LocalVideoTrack.createCameraTrack(CameraCaptureOptions(cameraPosition: _camera));
      _set(() => _preview = t);
    } catch (_) {
      _set(() => _error = 'devices');
    }
  }

  // --- Joining ---

  Future<void> _join() async {
    _set(() {
      _phase = _Phase.joining;
      _error = '';
    });
    try {
      final res = (await _api.joinMeeting(
        code: widget.code,
        meetingJoinInput: MeetingJoinInput(device: await meetingDevice()),
      )).data!;
      await _answered(res);
    } catch (e) {
      _failed(e);
    }
  }

  Future<void> _answered(MeetingJoin res) async {
    if (res.status == MeetingJoinStatusEnum.joined && res.grant != null) {
      _grant = res.grant;
      await _connect(res.grant!);
      return;
    }
    _knockId = res.knockId ?? 0;
    _knockToken = res.knockToken ?? '';
    _set(() => _phase = _Phase.waiting);
    unawaited(_waitKnock());
  }

  Future<void> _waitKnock() async {
    while (_phase == _Phase.waiting && !_disposed) {
      try {
        final res = (await _api.waitMeetingKnock(code: widget.code, knockId: _knockId, xKnockToken: _knockToken)).data!;
        if (res.status == MeetingJoinStatusEnum.joined) {
          await _answered(res);
          return;
        }
      } catch (e) {
        if (e is DioException && (e.response?.statusCode == 403 || e.response?.statusCode == 404)) {
          _failed(e);
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
  }

  void _failed(Object e) {
    final res = e is DioException ? e.response : null;
    final data = res?.data;
    _set(() {
      if (res?.statusCode == 403 && data is Map) {
        _phase = _Phase.refused;
        _refusal = '${data['code'] ?? ''}';
        _error = '${data['message'] ?? ''}';
      } else {
        _phase = _Phase.error;
        _error = errorMessage(e, '');
      }
    });
  }

  // --- The room ---

  Future<void> _connect(MeetingGrant g) async {
    _set(() => _phase = _Phase.connecting);
    await _preview?.stop();
    _preview = null;
    final room = Room(
      roomOptions: RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultCameraCaptureOptions: CameraCaptureOptions(cameraPosition: _camera),
        defaultVideoPublishOptions: const VideoPublishOptions(simulcast: true),
      ),
    );
    _room = room;
    room.addListener(_changed);
    _events = room.createListener()
      ..on<RoomDisconnectedEvent>((e) => _disconnected(e.reason))
      ..on<RoomMetadataChangedEvent>((e) => _readMeta(e.metadata))
      ..on<DataReceivedEvent>(_onData)
      ..on<ParticipantConnectedEvent>((_) => unawaited(_refreshState()))
      ..on<ParticipantDisconnectedEvent>((_) => unawaited(_refreshState()))
      ..on<ParticipantAttributesChanged>((e) {
        _changed();
        if (e.participant is LocalParticipant && e.attributes.containsKey(_attrRole)) unawaited(_refreshState());
      });
    try {
      await room.connect(g.url, g.token);
    } catch (e) {
      _set(() {
        _phase = _Phase.error;
        _error = '$e';
      });
      return;
    }
    _readMeta(room.metadata);
    _set(() => _phase = _Phase.inCall);
    if (g.rights.publish) {
      try {
        await room.localParticipant?.setMicrophoneEnabled(_micOn);
        await room.localParticipant?.setCameraEnabled(_camOn);
      } catch (_) {
        _set(() => _error = 'devices');
      }
    }
    try {
      await AudioManager.instance.setSpeakerOutputPreferred(_speaker);
    } catch (_) {}
    await Future.wait([_refreshState(), _loadMessages()]);
    _stateTimer = Timer.periodic(const Duration(seconds: 15), (_) => unawaited(_refreshState()));
  }

  void _changed() => _set(() {});

  void _readMeta(String? md) {
    try {
      _set(() => _meta = md == null || md.isEmpty ? const {} : (jsonDecode(md) as Map<String, dynamic>));
    } catch (_) {}
  }

  void _onData(DataReceivedEvent e) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(e.data)) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (e.topic) {
      case _topicChat:
        final m = MeetingMessage(
          id: body['id'] as int,
          person: '${body['person']}',
          name: '${body['name']}',
          body: '${body['body']}',
          at: DateTime.tryParse('${body['at']}') ?? DateTime.now(),
        );
        if (!_messages.any((x) => x.id == m.id)) {
          _set(() {
            _messages.add(m);
            if (!_chatOpen) _unread++;
          });
        }
      case _topicKnock:
      case _topicState:
        unawaited(_refreshState());
      case _topicAskUnmute:
        if (mounted) {
          final l = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.meetingsAskedToUnmute('${body['from'] ?? ''}')),
              action: SnackBarAction(label: l.meetingsUnmute, onPressed: () => unawaited(_toggleMic())),
            ),
          );
        }
    }
  }

  void _disconnected(DisconnectReason? reason) {
    _stateTimer?.cancel();
    if (_phase == _Phase.left) return;
    _set(() {
      _phase = switch (reason) {
        DisconnectReason.participantRemoved => _Phase.removed,
        DisconnectReason.roomDeleted => _Phase.ended,
        _ => _Phase.left,
      };
      if (reason == DisconnectReason.duplicateIdentity) _error = 'duplicate';
    });
  }

  Future<void> _refreshState() async {
    if (_seat.isEmpty) return;
    try {
      final s = (await _api.getMeetingCall(code: widget.code, xMeetingSeat: _seat)).data;
      _set(() => _state = s);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401 && _phase == _Phase.inCall) await _room?.disconnect();
    }
  }

  Future<void> _loadMessages() async {
    try {
      final got =
          (await _api.listMeetingCallMessages(
            code: widget.code,
            xMeetingSeat: _seat,
            after: _messages.isEmpty ? 0 : _messages.last.id,
          )).data ??
          [];
      _set(() {
        for (final m in got) {
          if (!_messages.any((x) => x.id == m.id)) _messages.add(m);
        }
      });
    } catch (_) {}
  }

  Future<void> _run(Future<void> Function() fn) async {
    final l = AppLocalizations.of(context);
    try {
      await fn();
      await _refreshState();
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.meetingsSomethingWrong));
    }
  }

  Future<void> _toggleMic() async {
    final p = _room?.localParticipant;
    if (p == null) return;
    _micOn = !p.isMicrophoneEnabled();
    await p.setMicrophoneEnabled(_micOn);
    _changed();
  }

  Future<void> _toggleCam() async {
    final p = _room?.localParticipant;
    if (p == null) return;
    _camOn = !p.isCameraEnabled();
    await p.setCameraEnabled(_camOn, cameraCaptureOptions: CameraCaptureOptions(cameraPosition: _camera));
    _changed();
  }

  Future<void> _flip() async {
    _camera = _camera == CameraPosition.front ? CameraPosition.back : CameraPosition.front;
    if (_phase == _Phase.lobby) {
      await _startPreview();
      return;
    }
    final pub = _room?.localParticipant?.videoTrackPublications.where((p) => p.source == TrackSource.camera).firstOrNull;
    final t = pub?.track;
    if (t != null) await t.setCameraPosition(_camera);
    _changed();
  }

  Future<void> _toggleSpeaker() async {
    _speaker = !_speaker;
    try {
      await AudioManager.instance.setSpeakerOutputPreferred(_speaker);
    } catch (_) {}
    _changed();
  }

  bool get _handUp => (_room?.localParticipant?.attributes[_attrHand] ?? '').isNotEmpty;

  Future<void> _toggleHand() async {
    await _room?.localParticipant?.setAttributes({_attrHand: _handUp ? '' : '${DateTime.now().millisecondsSinceEpoch}'});
    _changed();
  }

  /// Leaves after asking; a host is told the call goes on without them.
  Future<void> _confirmLeave() async {
    final l = AppLocalizations.of(context);
    final host = (_state?.rights.manageCohosts ?? false) && (_state?.people.length ?? 0) > 1;
    final ok = await confirmAction(
      context,
      title: l.meetingsLeaveTitle,
      message: host ? l.meetingsLeaveBodyHost : l.meetingsLeaveBody,
      confirmLabel: l.meetingsLeave,
      danger: true,
    );
    if (ok) await _leave();
  }

  /// Asks, then runs: for the host menu and the people list.
  Future<void> _confirmRun(String title, String message, String label, Future<void> Function() fn, {bool danger = false}) async {
    if (!await confirmAction(context, title: title, message: message, confirmLabel: label, danger: danger)) return;
    await _run(fn);
  }

  Future<void> _leave() async {
    _set(() => _phase = _Phase.left);
    _stateTimer?.cancel();
    await _room?.disconnect();
  }

  Future<void> _rejoin() async {
    await _events?.dispose();
    _events = null;
    _room?.removeListener(_changed);
    await _room?.dispose();
    _room = null;
    _set(() {
      _phase = _Phase.lobby;
      _error = '';
    });
    await _startPreview();
  }

  // --- Screens ---

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    if (_phase == _Phase.inCall) return _call(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/meetings')),
      body: switch (_phase) {
        _Phase.lobby || _Phase.joining => _lobby(context),
        _Phase.waiting => _message(
          context,
          l.meetingsWaitingTitle,
          l.meetingsWaitingBody,
          spinner: true,
          action: (l.meetingsCancel, () => _set(() => _phase = _Phase.lobby)),
        ),
        _Phase.connecting => _message(context, l.meetingsConnecting, null, spinner: true),
        _Phase.left => _message(
          context,
          _error == 'duplicate' ? l.meetingsJoinedElsewhere : l.meetingsYouLeft,
          null,
          action: (l.meetingsRejoin, () => unawaited(_rejoin())),
        ),
        _Phase.ended => _message(context, l.meetingsEnded, l.meetingsEndedBody),
        _Phase.removed => _message(context, l.meetingsRemovedTitle, l.meetingsRemovedBody),
        _Phase.refused => _message(context, _refusalTitle(l), _error, action: (l.meetingsTryAgain, () => unawaited(_rejoin()))),
        _ => _message(
          context,
          _error == 'not_found' ? l.meetingsNotFound : l.meetingsSomethingWrong,
          _error == 'not_found' ? null : _error,
          action: (l.meetingsTryAgain, () => unawaited(_rejoin())),
        ),
      },
    );
  }

  String _refusalTitle(AppLocalizations l) => switch (_refusal) {
    'locked' => l.meetingsRefused_locked,
    'full' => l.meetingsRefused_full,
    'removed' => l.meetingsRefused_removed,
    'guests_off' => l.meetingsRefused_guests_off,
    'not_started' => l.meetingsRefused_not_started,
    'cancelled' => l.meetingsRefused_cancelled,
    'denied' => l.meetingsRefused_denied,
    'expired' => l.meetingsRefused_expired,
    _ => _error,
  };

  Widget _message(BuildContext context, String title, String? text, {bool spinner = false, (String, VoidCallback)? action}) {
    final c = Agnts.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spinner) const Padding(padding: EdgeInsets.only(bottom: 16), child: CircularProgressIndicator()),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.ink),
            ),
            if (text != null && text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.ink3),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), FilledButton(onPressed: action.$2, child: Text(action.$1))],
          ],
        ),
      ),
    );
  }

  Widget _lobby(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final info = _info;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF1D1F22)),
                if (_preview != null)
                  VideoTrackRenderer(_preview!, fit: VideoViewFit.cover)
                else
                  Center(
                    child: Text(_camOn ? l.meetingsCameraStarting : l.meetingsCameraOff, style: const TextStyle(color: Colors.white70)),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundButton(_micOn ? 'mic' : 'micOff', off: !_micOn, onTap: () => _set(() => _micOn = !_micOn)),
                      const SizedBox(width: 14),
                      _roundButton(
                        _camOn ? 'video' : 'videoOff',
                        off: !_camOn,
                        onTap: () {
                          _camOn = !_camOn;
                          unawaited(_startPreview());
                        },
                      ),
                      const SizedBox(width: 14),
                      _roundButton('flip', onTap: () => unawaited(_flip())),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (info != null) ...[
          Text(info.workspace.toUpperCase(), style: TextStyle(fontSize: 12, letterSpacing: 0.5, color: c.ink3)),
          const SizedBox(height: 4),
          Text(
            info.title.isEmpty ? info.code : info.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.ink),
          ),
          const SizedBox(height: 4),
          if (info.hostName.isNotEmpty) Text(l.meetingsHostedBy(info.hostName), style: TextStyle(color: c.ink3)),
          const SizedBox(height: 8),
          Text(
            info.live == true ? (info.inCall > 0 ? l.meetingsInCallNow(info.inCall) : l.meetingsLiveEmpty) : l.meetingsNobodyYet,
            style: TextStyle(fontWeight: FontWeight.w700, color: info.live == true ? c.okInk : c.ink2),
          ),
          if (info.recording) _banner(context, 'record', l.meetingsLobbyRecording, c.badSoft, c.badInk),
          if (info.notes) _banner(context, 'notes', l.meetingsLobbyNotes, c.okSoft, c.okInk),
          if (info.cancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.meetingsCancelled, style: TextStyle(color: c.badInk)),
            ),
          if (_error == 'devices')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.meetingsDevicesFailed, style: TextStyle(color: c.badInk)),
            ),
          const SizedBox(height: 16),
          if (!info.cancelled)
            FilledButton(
              onPressed: _phase == _Phase.joining ? null : () => unawaited(_join()),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: Text(_phase == _Phase.joining ? l.meetingsJoining : (info.member ? l.meetingsJoinNow : l.meetingsAskToJoin)),
            ),
        ] else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _banner(BuildContext context, String icon, String text, Color bg, Color ink) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        HIcon(icon, size: 17, color: ink),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
        ),
      ],
    ),
  );

  Widget _roundButton(String icon, {bool off = false, bool on = false, required VoidCallback onTap, int badge = 0, Color? color}) {
    return InkResponse(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  color ??
                  (off
                      ? const Color(0xFFD6453D)
                      : on
                      ? const Color(0xFF8AB4F8)
                      : const Color(0xFF3C4043)),
            ),
            alignment: Alignment.center,
            child: HIcon(icon, size: 22, color: on ? const Color(0xFF131416) : Colors.white),
          ),
          if (badge > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: const Color(0xFFF0B429), borderRadius: BorderRadius.circular(9)),
                child: Text(
                  '$badge',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF131416)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Everyone's tile: the camera, or the name; a screen share large.
  List<Participant> get _people {
    final r = _room;
    if (r == null) return const [];
    return [if (r.localParticipant != null) r.localParticipant!, ...r.remoteParticipants.values];
  }

  VideoTrack? _trackOf(Participant p, TrackSource source) {
    for (final pub in p.videoTrackPublications) {
      if (pub.source == source && !pub.muted && pub.track != null) return pub.track as VideoTrack?;
    }
    return null;
  }

  Widget _call(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rights = _state?.rights ?? _grant?.rights;
    final people = _people;
    Participant? sharing;
    for (final p in people) {
      if (_trackOf(p, TrackSource.screenShareVideo) != null) sharing = p;
    }
    final knocks = _state?.canAdmit == true ? _state!.knocks : const <MeetingKnock>[];
    final title = _state?.meeting.title ?? _info?.title ?? '';
    // Back (the gesture or the button) asks before it leaves the call.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF131416),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.isEmpty ? widget.code : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    if (_meta['recording'] == true) _flag('record', l.meetingsRecording, const Color(0xFF5B1F1C), const Color(0xFFFFB4AB)),
                    if (_meta['notes'] == true) _flag('notes', l.meetingsTakingNotes, const Color(0xFF17392B), const Color(0xFF9BE0BF)),
                    if (_meta['locked'] == true) _flag('lock', l.meetingsLocked, const Color(0xFF2A2C30), Colors.white70),
                  ],
                ),
              ),
              if (knocks.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF2A2C30), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${knocks.first.name} ${l.meetingsWantsToJoin}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => unawaited(
                          _run(
                            () =>
                                _api.decideMeetingKnock(code: widget.code, knockId: knocks.first.id, decision: 'deny', xMeetingSeat: _seat),
                          ),
                        ),
                        child: Text(l.meetingsDeny),
                      ),
                      FilledButton(
                        onPressed: () => unawaited(
                          _run(
                            () => _api.decideMeetingKnock(
                              code: widget.code,
                              knockId: knocks.first.id,
                              decision: 'admit',
                              xMeetingSeat: _seat,
                            ),
                          ),
                        ),
                        child: Text(l.meetingsAdmit),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: sharing != null
                    ? Column(
                        children: [
                          Expanded(child: _tile(sharing, screen: true)),
                          SizedBox(
                            height: 110,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(8),
                              children: [
                                for (final p in people)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: SizedBox(width: 150, child: _tile(p)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : GridView.count(
                        padding: const EdgeInsets.all(8),
                        crossAxisCount: people.length <= 1 ? 1 : 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: people.length <= 2 ? 0.75 : 0.85,
                        children: [for (final p in people) _tile(p)],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (rights?.publish ?? false) ...[
                      _roundButton(
                        _room?.localParticipant?.isMicrophoneEnabled() ?? false ? 'mic' : 'micOff',
                        off: !(_room?.localParticipant?.isMicrophoneEnabled() ?? false),
                        onTap: () => unawaited(_toggleMic()),
                      ),
                      _roundButton(
                        _room?.localParticipant?.isCameraEnabled() ?? false ? 'video' : 'videoOff',
                        off: !(_room?.localParticipant?.isCameraEnabled() ?? false),
                        onTap: () => unawaited(_toggleCam()),
                      ),
                      _roundButton('flip', onTap: () => unawaited(_flip())),
                    ],
                    _roundButton('speaker', on: _speaker, onTap: () => unawaited(_toggleSpeaker())),
                    _roundButton('hand', on: _handUp, onTap: () => unawaited(_toggleHand())),
                    _roundButton('chat', badge: _unread, onTap: _openChat),
                    _roundButton('people', badge: knocks.length, onTap: _openPeople),
                    if ((rights?.moderate ?? false) || (rights?.record ?? false)) _roundButton('more', onTap: _openHostMenu),
                    _roundButton('hangup', color: const Color(0xFFD6453D), onTap: () => unawaited(_confirmLeave())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flag(String icon, String text, Color bg, Color ink) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HIcon(icon, size: 12, color: ink),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: ink, fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _tile(Participant p, {bool screen = false}) {
    final l = AppLocalizations.of(context);
    final track = _trackOf(p, screen ? TrackSource.screenShareVideo : TrackSource.camera);
    final name = p.name.isEmpty ? p.identity : p.name;
    final hand = (p.attributes[_attrHand] ?? '').isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF24272B),
          border: Border.all(color: p.isSpeaking && !screen ? const Color(0xFF4FB286) : Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (track != null)
              VideoTrackRenderer(track, fit: screen ? VideoViewFit.contain : VideoViewFit.cover)
            else
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.primaries[name.hashCode.abs() % Colors.primaries.length].shade700,
                  child: Text(
                    name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              right: 6,
              child: Row(
                children: [
                  if (!screen && p.isMuted)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFFD6453D), shape: BoxShape.circle),
                      child: const HIcon('micOff', size: 12, color: Colors.white),
                    ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        p is LocalParticipant ? l.meetingsYou(name) : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hand && !screen)
              const Positioned(
                left: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFF0B429),
                  child: HIcon('hand', size: 16, color: Color(0xFF131416)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Sheets ---

  void _openChat() {
    _set(() {
      _chatOpen = true;
      _unread = 0;
    });
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChatSheet(messages: _messages, canChat: _state?.rights.chat ?? true, me: _state?.me.key ?? '', send: _send),
    ).whenComplete(() => _set(() => _chatOpen = false));
  }

  Future<String?> _send(String body) async {
    final failed = AppLocalizations.of(context).meetingsSomethingWrong;
    try {
      final m = (await _api.sendMeetingMessage(
        code: widget.code,
        xMeetingSeat: _seat,
        sendMeetingMessageRequest: SendMeetingMessageRequest(body: body),
      )).data!;
      _set(() {
        if (!_messages.any((x) => x.id == m.id)) _messages.add(m);
      });
      return null;
    } catch (e) {
      return errorMessage(e, failed);
    }
  }

  void _openPeople() {
    final l = AppLocalizations.of(context);
    final st = _state;
    if (st == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            if (st.canAdmit && st.knocks.isNotEmpty) ...[
              SectionHeader(l.meetingsWaiting(st.knocks.length)),
              for (final k in st.knocks)
                ListTile(
                  title: Text(k.name),
                  subtitle: Text(k.guest ? (k.email ?? l.meetingsGuest) : l.meetingsMember),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          unawaited(
                            _run(() => _api.decideMeetingKnock(code: widget.code, knockId: k.id, decision: 'deny', xMeetingSeat: _seat)),
                          );
                        },
                        child: Text(l.meetingsDeny),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          unawaited(
                            _run(() => _api.decideMeetingKnock(code: widget.code, knockId: k.id, decision: 'admit', xMeetingSeat: _seat)),
                          );
                        },
                        child: Text(l.meetingsAdmit),
                      ),
                    ],
                  ),
                ),
            ],
            SectionHeader(l.meetingsInCall(st.people.length)),
            for (final p in st.people)
              ListTile(
                title: Text(p.key == st.me.key ? '${p.name} (${l.meetingsYouShort})' : p.name),
                subtitle: Text(_roleLabel(l, p.role)),
                trailing: st.rights.moderate && p.key != st.me.key
                    ? PopupMenuButton<String>(
                        onSelected: (a) {
                          Navigator.pop(ctx);
                          Future<void> act() => _api.actOnMeetingPerson(
                            code: widget.code,
                            person: p.key,
                            action: a.startsWith('mute') ? 'mute' : a,
                            xMeetingSeat: _seat,
                            actOnMeetingPersonRequest: a == 'mute-camera'
                                ? ActOnMeetingPersonRequest(source_: ActOnMeetingPersonRequestSource_Enum.camera)
                                : a == 'mute'
                                ? ActOnMeetingPersonRequest(source_: ActOnMeetingPersonRequestSource_Enum.microphone)
                                : null,
                          );
                          if (a == 'remove') {
                            unawaited(
                              _confirmRun(l.meetingsRemoveTitle(p.name), l.meetingsRemoveBody, l.meetingsRemove, act, danger: true),
                            );
                          } else if (a == 'cohost') {
                            unawaited(_confirmRun(l.meetingsCohostTitle(p.name), l.meetingsCohostBody, l.meetingsMakeCohost, act));
                          } else {
                            unawaited(_run(act));
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'mute', child: Text(l.meetingsMuteMic)),
                          PopupMenuItem(value: 'mute-camera', child: Text(l.meetingsStopCamera)),
                          PopupMenuItem(value: 'ask-unmute', child: Text(l.meetingsAskUnmute)),
                          PopupMenuItem(value: 'lower-hand', child: Text(l.meetingsLowerHand)),
                          if (st.rights.manageCohosts && p.role == MeetingPersonRoleEnum.member)
                            PopupMenuItem(value: 'cohost', child: Text(l.meetingsMakeCohost)),
                          if (st.rights.manageCohosts && p.role == MeetingPersonRoleEnum.cohost)
                            PopupMenuItem(value: 'uncohost', child: Text(l.meetingsUncohost)),
                          PopupMenuItem(value: 'remove', child: Text(l.meetingsRemove)),
                        ],
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(AppLocalizations l, MeetingPersonRoleEnum r) => switch (r) {
    MeetingPersonRoleEnum.host => l.meetingsRole_host,
    MeetingPersonRoleEnum.cohost => l.meetingsRole_cohost,
    MeetingPersonRoleEnum.member => l.meetingsRole_member,
    _ => l.meetingsRole_guest,
  };

  void _openHostMenu() {
    final l = AppLocalizations.of(context);
    final st = _state;
    if (st == null) return;
    final recording = _meta['recording'] == true;
    final notes = _meta['notes'] == true;
    final locked = _meta['locked'] == true;
    Future<void> change(MeetingCallSettings s) =>
        _api.setMeetingCallSettings(code: widget.code, xMeetingSeat: _seat, meetingCallSettings: s);
    Future<void> settings(MeetingCallSettings s) => _run(() => change(s));
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (st.rights.record && st.recordingAvailable)
              ListTile(
                leading: const HIcon('record'),
                title: Text(recording ? l.meetingsStopRecording : l.meetingsStartRecording),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(
                    recording
                        ? _confirmRun(
                            l.meetingsStopRecordingTitle,
                            l.meetingsStopRecordingBody,
                            l.meetingsStopRecording,
                            () => change(MeetingCallSettings(recording: false)),
                          )
                        : _confirmRun(
                            l.meetingsRecordTitle,
                            l.meetingsRecordBody,
                            l.meetingsStartRecording,
                            () => change(MeetingCallSettings(recording: true)),
                          ),
                  );
                },
              ),
            if (st.rights.record && st.notesAvailable)
              ListTile(
                leading: const HIcon('notes'),
                title: Text(notes ? l.meetingsStopNotes : l.meetingsStartNotes),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(
                    notes
                        ? _confirmRun(
                            l.meetingsStopNotesTitle,
                            l.meetingsStopNotesBody,
                            l.meetingsStopNotes,
                            () => change(MeetingCallSettings(notes: false)),
                          )
                        : settings(MeetingCallSettings(notes: true)),
                  );
                },
              ),
            if (st.rights.moderate) ...[
              ListTile(
                leading: const HIcon('lock'),
                title: Text(locked ? l.meetingsUnlock : l.meetingsLock),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(
                    locked
                        ? settings(MeetingCallSettings(locked: false))
                        : _confirmRun(
                            l.meetingsLockTitle,
                            l.meetingsLockBody,
                            l.meetingsLock,
                            () => change(MeetingCallSettings(locked: true)),
                          ),
                  );
                },
              ),
              ListTile(
                leading: const HIcon('micOff'),
                title: Text(l.meetingsMuteAll),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(
                    _confirmRun(
                      l.meetingsMuteAllTitle,
                      l.meetingsMuteAllBody,
                      l.meetingsMuteAll,
                      () => _api.muteAllInMeeting(code: widget.code, xMeetingSeat: _seat),
                    ),
                  );
                },
              ),
            ],
            if (st.rights.manageCohosts)
              ListTile(
                leading: HIcon('hangup', color: Agnts.of(context).badInk),
                title: Text(l.meetingsEndForAll, style: TextStyle(color: Agnts.of(context).badInk)),
                onTap: () {
                  Navigator.pop(ctx);
                  unawaited(
                    _confirmRun(
                      l.meetingsEndTitle,
                      l.meetingsEndBody,
                      l.meetingsEndForAll,
                      () => _api.endMeetingCall(code: widget.code, xMeetingSeat: _seat),
                      danger: true,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// The call's chat in a sheet: what was said, and a box to write.
class _ChatSheet extends StatefulWidget {
  const _ChatSheet({required this.messages, required this.canChat, required this.me, required this.send});
  final List<MeetingMessage> messages;
  final bool canChat;
  final String me;
  final Future<String?> Function(String body) send;

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _text = TextEditingController();
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _busy) return;
    setState(() => _busy = true);
    final err = await widget.send(body);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err ?? '';
      if (err == null) _text.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                l.meetingsChat,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink),
              ),
            ),
            Expanded(
              child: widget.messages.isEmpty
                  ? Center(
                      child: Text(
                        l.meetingsChatEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.ink3),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      reverse: true,
                      children: [
                        for (final m in widget.messages.reversed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: m.person == widget.me ? c.primary : c.ink,
                                  ),
                                ),
                                SelectableText(m.body, style: TextStyle(fontSize: 14.5, color: c.ink)),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error, style: TextStyle(color: c.badInk)),
              ),
            if (widget.canChat)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          maxLength: 2000,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => unawaited(_send()),
                          decoration: InputDecoration(hintText: l.meetingsChatPlaceholder, counterText: ''),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : () => unawaited(_send()),
                        icon: HIcon('chevron', color: c.primary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.meetingsChatOff, style: TextStyle(color: c.ink3)),
              ),
          ],
        ),
      ),
    );
  }
}
