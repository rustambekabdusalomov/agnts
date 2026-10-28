// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_meeting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicMeetingCWProxy {
  PublicMeeting code(String code);

  PublicMeeting title(String title);

  PublicMeeting hostName(String hostName);

  PublicMeeting workspace(String workspace);

  PublicMeeting kind(PublicMeetingKindEnum kind);

  PublicMeeting startsAt(DateTime? startsAt);

  PublicMeeting endsAt(DateTime? endsAt);

  PublicMeeting timeZone(String? timeZone);

  PublicMeeting cancelled(bool cancelled);

  PublicMeeting guests(PublicMeetingGuestsEnum guests);

  PublicMeeting live(bool? live);

  PublicMeeting inCall(int inCall);

  PublicMeeting recording(bool recording);

  PublicMeeting notes(bool notes);

  PublicMeeting member(bool member);

  PublicMeeting name(String? name);

  PublicMeeting googleClientId(String? googleClientId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicMeeting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicMeeting(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicMeeting call({
    String code,
    String title,
    String hostName,
    String workspace,
    PublicMeetingKindEnum kind,
    DateTime? startsAt,
    DateTime? endsAt,
    String? timeZone,
    bool cancelled,
    PublicMeetingGuestsEnum guests,
    bool? live,
    int inCall,
    bool recording,
    bool notes,
    bool member,
    String? name,
    String? googleClientId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicMeeting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicMeeting.copyWith.fieldName(...)`
class _$PublicMeetingCWProxyImpl implements _$PublicMeetingCWProxy {
  const _$PublicMeetingCWProxyImpl(this._value);

  final PublicMeeting _value;

  @override
  PublicMeeting code(String code) => this(code: code);

  @override
  PublicMeeting title(String title) => this(title: title);

  @override
  PublicMeeting hostName(String hostName) => this(hostName: hostName);

  @override
  PublicMeeting workspace(String workspace) => this(workspace: workspace);

  @override
  PublicMeeting kind(PublicMeetingKindEnum kind) => this(kind: kind);

  @override
  PublicMeeting startsAt(DateTime? startsAt) => this(startsAt: startsAt);

  @override
  PublicMeeting endsAt(DateTime? endsAt) => this(endsAt: endsAt);

  @override
  PublicMeeting timeZone(String? timeZone) => this(timeZone: timeZone);

  @override
  PublicMeeting cancelled(bool cancelled) => this(cancelled: cancelled);

  @override
  PublicMeeting guests(PublicMeetingGuestsEnum guests) => this(guests: guests);

  @override
  PublicMeeting live(bool? live) => this(live: live);

  @override
  PublicMeeting inCall(int inCall) => this(inCall: inCall);

  @override
  PublicMeeting recording(bool recording) => this(recording: recording);

  @override
  PublicMeeting notes(bool notes) => this(notes: notes);

  @override
  PublicMeeting member(bool member) => this(member: member);

  @override
  PublicMeeting name(String? name) => this(name: name);

  @override
  PublicMeeting googleClientId(String? googleClientId) =>
      this(googleClientId: googleClientId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicMeeting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicMeeting(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicMeeting call({
    Object? code = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? hostName = const $CopyWithPlaceholder(),
    Object? workspace = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? startsAt = const $CopyWithPlaceholder(),
    Object? endsAt = const $CopyWithPlaceholder(),
    Object? timeZone = const $CopyWithPlaceholder(),
    Object? cancelled = const $CopyWithPlaceholder(),
    Object? guests = const $CopyWithPlaceholder(),
    Object? live = const $CopyWithPlaceholder(),
    Object? inCall = const $CopyWithPlaceholder(),
    Object? recording = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? member = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? googleClientId = const $CopyWithPlaceholder(),
  }) {
    return PublicMeeting(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      hostName: hostName == const $CopyWithPlaceholder()
          ? _value.hostName
          // ignore: cast_nullable_to_non_nullable
          : hostName as String,
      workspace: workspace == const $CopyWithPlaceholder()
          ? _value.workspace
          // ignore: cast_nullable_to_non_nullable
          : workspace as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as PublicMeetingKindEnum,
      startsAt: startsAt == const $CopyWithPlaceholder()
          ? _value.startsAt
          // ignore: cast_nullable_to_non_nullable
          : startsAt as DateTime?,
      endsAt: endsAt == const $CopyWithPlaceholder()
          ? _value.endsAt
          // ignore: cast_nullable_to_non_nullable
          : endsAt as DateTime?,
      timeZone: timeZone == const $CopyWithPlaceholder()
          ? _value.timeZone
          // ignore: cast_nullable_to_non_nullable
          : timeZone as String?,
      cancelled: cancelled == const $CopyWithPlaceholder()
          ? _value.cancelled
          // ignore: cast_nullable_to_non_nullable
          : cancelled as bool,
      guests: guests == const $CopyWithPlaceholder()
          ? _value.guests
          // ignore: cast_nullable_to_non_nullable
          : guests as PublicMeetingGuestsEnum,
      live: live == const $CopyWithPlaceholder()
          ? _value.live
          // ignore: cast_nullable_to_non_nullable
          : live as bool?,
      inCall: inCall == const $CopyWithPlaceholder()
          ? _value.inCall
          // ignore: cast_nullable_to_non_nullable
          : inCall as int,
      recording: recording == const $CopyWithPlaceholder()
          ? _value.recording
          // ignore: cast_nullable_to_non_nullable
          : recording as bool,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as bool,
      member: member == const $CopyWithPlaceholder()
          ? _value.member
          // ignore: cast_nullable_to_non_nullable
          : member as bool,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      googleClientId: googleClientId == const $CopyWithPlaceholder()
          ? _value.googleClientId
          // ignore: cast_nullable_to_non_nullable
          : googleClientId as String?,
    );
  }
}

extension $PublicMeetingCopyWith on PublicMeeting {
  /// Returns a callable class that can be used as follows: `instanceOfPublicMeeting.copyWith(...)` or like so:`instanceOfPublicMeeting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicMeetingCWProxy get copyWith => _$PublicMeetingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicMeeting _$PublicMeetingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PublicMeeting', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'code',
          'title',
          'hostName',
          'workspace',
          'kind',
          'cancelled',
          'guests',
          'inCall',
          'recording',
          'notes',
          'member',
        ],
      );
      final val = PublicMeeting(
        code: $checkedConvert('code', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        hostName: $checkedConvert('hostName', (v) => v as String),
        workspace: $checkedConvert('workspace', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$PublicMeetingKindEnumEnumMap, v),
        ),
        startsAt: $checkedConvert(
          'startsAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        endsAt: $checkedConvert(
          'endsAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        timeZone: $checkedConvert('timeZone', (v) => v as String?),
        cancelled: $checkedConvert('cancelled', (v) => v as bool),
        guests: $checkedConvert(
          'guests',
          (v) => $enumDecode(_$PublicMeetingGuestsEnumEnumMap, v),
        ),
        live: $checkedConvert('live', (v) => v as bool?),
        inCall: $checkedConvert('inCall', (v) => (v as num).toInt()),
        recording: $checkedConvert('recording', (v) => v as bool),
        notes: $checkedConvert('notes', (v) => v as bool),
        member: $checkedConvert('member', (v) => v as bool),
        name: $checkedConvert('name', (v) => v as String?),
        googleClientId: $checkedConvert('googleClientId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PublicMeetingToJson(PublicMeeting instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'hostName': instance.hostName,
      'workspace': instance.workspace,
      'kind': _$PublicMeetingKindEnumEnumMap[instance.kind]!,
      'startsAt': ?instance.startsAt?.toIso8601String(),
      'endsAt': ?instance.endsAt?.toIso8601String(),
      'timeZone': ?instance.timeZone,
      'cancelled': instance.cancelled,
      'guests': _$PublicMeetingGuestsEnumEnumMap[instance.guests]!,
      'live': ?instance.live,
      'inCall': instance.inCall,
      'recording': instance.recording,
      'notes': instance.notes,
      'member': instance.member,
      'name': ?instance.name,
      'googleClientId': ?instance.googleClientId,
    };

const _$PublicMeetingKindEnumEnumMap = {
  PublicMeetingKindEnum.instant: 'instant',
  PublicMeetingKindEnum.scheduled: 'scheduled',
};

const _$PublicMeetingGuestsEnumEnumMap = {
  PublicMeetingGuestsEnum.off: 'off',
  PublicMeetingGuestsEnum.knock: 'knock',
  PublicMeetingGuestsEnum.open: 'open',
};
