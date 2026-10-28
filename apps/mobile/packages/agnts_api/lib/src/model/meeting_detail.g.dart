// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingDetailCWProxy {
  MeetingDetail id(int id);

  MeetingDetail code(String code);

  MeetingDetail link(String link);

  MeetingDetail title(String title);

  MeetingDetail description(String description);

  MeetingDetail hostId(int? hostId);

  MeetingDetail hostName(String hostName);

  MeetingDetail kind(MeetingDetailKindEnum kind);

  MeetingDetail startsAt(DateTime? startsAt);

  MeetingDetail endsAt(DateTime? endsAt);

  MeetingDetail durationMin(int durationMin);

  MeetingDetail timeZone(String timeZone);

  MeetingDetail access(MeetingDetailAccessEnum access);

  MeetingDetail guests(MeetingDetailGuestsEnum guests);

  MeetingDetail locked(bool locked);

  MeetingDetail autoRecord(bool autoRecord);

  MeetingDetail autoNotes(bool autoNotes);

  MeetingDetail language(MeetingDetailLanguageEnum language);

  MeetingDetail cohostIds(List<int> cohostIds);

  MeetingDetail cancelledAt(DateTime? cancelledAt);

  MeetingDetail createdAt(DateTime createdAt);

  MeetingDetail live(MeetingLive? live);

  MeetingDetail invitees(List<MeetingInvitee> invitees);

  MeetingDetail myRsvp(MeetingDetailMyRsvpEnum? myRsvp);

  MeetingDetail canManage(bool canManage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingDetail call({
    int id,
    String code,
    String link,
    String title,
    String description,
    int? hostId,
    String hostName,
    MeetingDetailKindEnum kind,
    DateTime? startsAt,
    DateTime? endsAt,
    int durationMin,
    String timeZone,
    MeetingDetailAccessEnum access,
    MeetingDetailGuestsEnum guests,
    bool locked,
    bool autoRecord,
    bool autoNotes,
    MeetingDetailLanguageEnum language,
    List<int> cohostIds,
    DateTime? cancelledAt,
    DateTime createdAt,
    MeetingLive? live,
    List<MeetingInvitee> invitees,
    MeetingDetailMyRsvpEnum? myRsvp,
    bool canManage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingDetail.copyWith.fieldName(...)`
class _$MeetingDetailCWProxyImpl implements _$MeetingDetailCWProxy {
  const _$MeetingDetailCWProxyImpl(this._value);

  final MeetingDetail _value;

  @override
  MeetingDetail id(int id) => this(id: id);

  @override
  MeetingDetail code(String code) => this(code: code);

  @override
  MeetingDetail link(String link) => this(link: link);

  @override
  MeetingDetail title(String title) => this(title: title);

  @override
  MeetingDetail description(String description) =>
      this(description: description);

  @override
  MeetingDetail hostId(int? hostId) => this(hostId: hostId);

  @override
  MeetingDetail hostName(String hostName) => this(hostName: hostName);

  @override
  MeetingDetail kind(MeetingDetailKindEnum kind) => this(kind: kind);

  @override
  MeetingDetail startsAt(DateTime? startsAt) => this(startsAt: startsAt);

  @override
  MeetingDetail endsAt(DateTime? endsAt) => this(endsAt: endsAt);

  @override
  MeetingDetail durationMin(int durationMin) => this(durationMin: durationMin);

  @override
  MeetingDetail timeZone(String timeZone) => this(timeZone: timeZone);

  @override
  MeetingDetail access(MeetingDetailAccessEnum access) => this(access: access);

  @override
  MeetingDetail guests(MeetingDetailGuestsEnum guests) => this(guests: guests);

  @override
  MeetingDetail locked(bool locked) => this(locked: locked);

  @override
  MeetingDetail autoRecord(bool autoRecord) => this(autoRecord: autoRecord);

  @override
  MeetingDetail autoNotes(bool autoNotes) => this(autoNotes: autoNotes);

  @override
  MeetingDetail language(MeetingDetailLanguageEnum language) =>
      this(language: language);

  @override
  MeetingDetail cohostIds(List<int> cohostIds) => this(cohostIds: cohostIds);

  @override
  MeetingDetail cancelledAt(DateTime? cancelledAt) =>
      this(cancelledAt: cancelledAt);

  @override
  MeetingDetail createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  MeetingDetail live(MeetingLive? live) => this(live: live);

  @override
  MeetingDetail invitees(List<MeetingInvitee> invitees) =>
      this(invitees: invitees);

  @override
  MeetingDetail myRsvp(MeetingDetailMyRsvpEnum? myRsvp) => this(myRsvp: myRsvp);

  @override
  MeetingDetail canManage(bool canManage) => this(canManage: canManage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingDetail call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? link = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? hostId = const $CopyWithPlaceholder(),
    Object? hostName = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? startsAt = const $CopyWithPlaceholder(),
    Object? endsAt = const $CopyWithPlaceholder(),
    Object? durationMin = const $CopyWithPlaceholder(),
    Object? timeZone = const $CopyWithPlaceholder(),
    Object? access = const $CopyWithPlaceholder(),
    Object? guests = const $CopyWithPlaceholder(),
    Object? locked = const $CopyWithPlaceholder(),
    Object? autoRecord = const $CopyWithPlaceholder(),
    Object? autoNotes = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? cohostIds = const $CopyWithPlaceholder(),
    Object? cancelledAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? live = const $CopyWithPlaceholder(),
    Object? invitees = const $CopyWithPlaceholder(),
    Object? myRsvp = const $CopyWithPlaceholder(),
    Object? canManage = const $CopyWithPlaceholder(),
  }) {
    return MeetingDetail(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      link: link == const $CopyWithPlaceholder()
          ? _value.link
          // ignore: cast_nullable_to_non_nullable
          : link as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String,
      hostId: hostId == const $CopyWithPlaceholder()
          ? _value.hostId
          // ignore: cast_nullable_to_non_nullable
          : hostId as int?,
      hostName: hostName == const $CopyWithPlaceholder()
          ? _value.hostName
          // ignore: cast_nullable_to_non_nullable
          : hostName as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as MeetingDetailKindEnum,
      startsAt: startsAt == const $CopyWithPlaceholder()
          ? _value.startsAt
          // ignore: cast_nullable_to_non_nullable
          : startsAt as DateTime?,
      endsAt: endsAt == const $CopyWithPlaceholder()
          ? _value.endsAt
          // ignore: cast_nullable_to_non_nullable
          : endsAt as DateTime?,
      durationMin: durationMin == const $CopyWithPlaceholder()
          ? _value.durationMin
          // ignore: cast_nullable_to_non_nullable
          : durationMin as int,
      timeZone: timeZone == const $CopyWithPlaceholder()
          ? _value.timeZone
          // ignore: cast_nullable_to_non_nullable
          : timeZone as String,
      access: access == const $CopyWithPlaceholder()
          ? _value.access
          // ignore: cast_nullable_to_non_nullable
          : access as MeetingDetailAccessEnum,
      guests: guests == const $CopyWithPlaceholder()
          ? _value.guests
          // ignore: cast_nullable_to_non_nullable
          : guests as MeetingDetailGuestsEnum,
      locked: locked == const $CopyWithPlaceholder()
          ? _value.locked
          // ignore: cast_nullable_to_non_nullable
          : locked as bool,
      autoRecord: autoRecord == const $CopyWithPlaceholder()
          ? _value.autoRecord
          // ignore: cast_nullable_to_non_nullable
          : autoRecord as bool,
      autoNotes: autoNotes == const $CopyWithPlaceholder()
          ? _value.autoNotes
          // ignore: cast_nullable_to_non_nullable
          : autoNotes as bool,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as MeetingDetailLanguageEnum,
      cohostIds: cohostIds == const $CopyWithPlaceholder()
          ? _value.cohostIds
          // ignore: cast_nullable_to_non_nullable
          : cohostIds as List<int>,
      cancelledAt: cancelledAt == const $CopyWithPlaceholder()
          ? _value.cancelledAt
          // ignore: cast_nullable_to_non_nullable
          : cancelledAt as DateTime?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      live: live == const $CopyWithPlaceholder()
          ? _value.live
          // ignore: cast_nullable_to_non_nullable
          : live as MeetingLive?,
      invitees: invitees == const $CopyWithPlaceholder()
          ? _value.invitees
          // ignore: cast_nullable_to_non_nullable
          : invitees as List<MeetingInvitee>,
      myRsvp: myRsvp == const $CopyWithPlaceholder()
          ? _value.myRsvp
          // ignore: cast_nullable_to_non_nullable
          : myRsvp as MeetingDetailMyRsvpEnum?,
      canManage: canManage == const $CopyWithPlaceholder()
          ? _value.canManage
          // ignore: cast_nullable_to_non_nullable
          : canManage as bool,
    );
  }
}

extension $MeetingDetailCopyWith on MeetingDetail {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingDetail.copyWith(...)` or like so:`instanceOfMeetingDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingDetailCWProxy get copyWith => _$MeetingDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingDetail _$MeetingDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingDetail', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'code',
      'link',
      'title',
      'description',
      'hostName',
      'kind',
      'durationMin',
      'timeZone',
      'access',
      'guests',
      'locked',
      'autoRecord',
      'autoNotes',
      'language',
      'cohostIds',
      'createdAt',
      'invitees',
      'canManage',
    ],
  );
  final val = MeetingDetail(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    code: $checkedConvert('code', (v) => v as String),
    link: $checkedConvert('link', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    hostId: $checkedConvert('hostId', (v) => (v as num?)?.toInt()),
    hostName: $checkedConvert('hostName', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$MeetingDetailKindEnumEnumMap, v),
    ),
    startsAt: $checkedConvert(
      'startsAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    endsAt: $checkedConvert(
      'endsAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    durationMin: $checkedConvert('durationMin', (v) => (v as num).toInt()),
    timeZone: $checkedConvert('timeZone', (v) => v as String),
    access: $checkedConvert(
      'access',
      (v) => $enumDecode(_$MeetingDetailAccessEnumEnumMap, v),
    ),
    guests: $checkedConvert(
      'guests',
      (v) => $enumDecode(_$MeetingDetailGuestsEnumEnumMap, v),
    ),
    locked: $checkedConvert('locked', (v) => v as bool),
    autoRecord: $checkedConvert('autoRecord', (v) => v as bool),
    autoNotes: $checkedConvert('autoNotes', (v) => v as bool),
    language: $checkedConvert(
      'language',
      (v) => $enumDecode(_$MeetingDetailLanguageEnumEnumMap, v),
    ),
    cohostIds: $checkedConvert(
      'cohostIds',
      (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
    cancelledAt: $checkedConvert(
      'cancelledAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    live: $checkedConvert(
      'live',
      (v) => v == null ? null : MeetingLive.fromJson(v as Map<String, dynamic>),
    ),
    invitees: $checkedConvert(
      'invitees',
      (v) => (v as List<dynamic>)
          .map((e) => MeetingInvitee.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    myRsvp: $checkedConvert(
      'myRsvp',
      (v) => $enumDecodeNullable(_$MeetingDetailMyRsvpEnumEnumMap, v),
    ),
    canManage: $checkedConvert('canManage', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$MeetingDetailToJson(MeetingDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'link': instance.link,
      'title': instance.title,
      'description': instance.description,
      'hostId': ?instance.hostId,
      'hostName': instance.hostName,
      'kind': _$MeetingDetailKindEnumEnumMap[instance.kind]!,
      'startsAt': ?instance.startsAt?.toIso8601String(),
      'endsAt': ?instance.endsAt?.toIso8601String(),
      'durationMin': instance.durationMin,
      'timeZone': instance.timeZone,
      'access': _$MeetingDetailAccessEnumEnumMap[instance.access]!,
      'guests': _$MeetingDetailGuestsEnumEnumMap[instance.guests]!,
      'locked': instance.locked,
      'autoRecord': instance.autoRecord,
      'autoNotes': instance.autoNotes,
      'language': _$MeetingDetailLanguageEnumEnumMap[instance.language]!,
      'cohostIds': instance.cohostIds,
      'cancelledAt': ?instance.cancelledAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'live': ?instance.live?.toJson(),
      'invitees': instance.invitees.map((e) => e.toJson()).toList(),
      'myRsvp': ?_$MeetingDetailMyRsvpEnumEnumMap[instance.myRsvp],
      'canManage': instance.canManage,
    };

const _$MeetingDetailKindEnumEnumMap = {
  MeetingDetailKindEnum.instant: 'instant',
  MeetingDetailKindEnum.scheduled: 'scheduled',
};

const _$MeetingDetailAccessEnumEnumMap = {
  MeetingDetailAccessEnum.workspace: 'workspace',
  MeetingDetailAccessEnum.invited: 'invited',
};

const _$MeetingDetailGuestsEnumEnumMap = {
  MeetingDetailGuestsEnum.off: 'off',
  MeetingDetailGuestsEnum.knock: 'knock',
  MeetingDetailGuestsEnum.open: 'open',
};

const _$MeetingDetailLanguageEnumEnumMap = {
  MeetingDetailLanguageEnum.auto: 'auto',
  MeetingDetailLanguageEnum.en: 'en',
  MeetingDetailLanguageEnum.ru: 'ru',
  MeetingDetailLanguageEnum.uz: 'uz',
};

const _$MeetingDetailMyRsvpEnumEnumMap = {
  MeetingDetailMyRsvpEnum.none: 'none',
  MeetingDetailMyRsvpEnum.true_: 'true',
  MeetingDetailMyRsvpEnum.false_: 'false',
  MeetingDetailMyRsvpEnum.maybe: 'maybe',
};
