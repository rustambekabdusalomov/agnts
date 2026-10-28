// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingCWProxy {
  Meeting id(int id);

  Meeting code(String code);

  Meeting link(String link);

  Meeting title(String title);

  Meeting description(String description);

  Meeting hostId(int? hostId);

  Meeting hostName(String hostName);

  Meeting kind(MeetingKindEnum kind);

  Meeting startsAt(DateTime? startsAt);

  Meeting endsAt(DateTime? endsAt);

  Meeting durationMin(int durationMin);

  Meeting timeZone(String timeZone);

  Meeting access(MeetingAccessEnum access);

  Meeting guests(MeetingGuestsEnum guests);

  Meeting locked(bool locked);

  Meeting autoRecord(bool autoRecord);

  Meeting autoNotes(bool autoNotes);

  Meeting language(MeetingLanguageEnum language);

  Meeting cohostIds(List<int> cohostIds);

  Meeting cancelledAt(DateTime? cancelledAt);

  Meeting createdAt(DateTime createdAt);

  Meeting live(MeetingLive? live);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meeting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meeting(...).copyWith(id: 12, name: "My name")
  /// ````
  Meeting call({
    int id,
    String code,
    String link,
    String title,
    String description,
    int? hostId,
    String hostName,
    MeetingKindEnum kind,
    DateTime? startsAt,
    DateTime? endsAt,
    int durationMin,
    String timeZone,
    MeetingAccessEnum access,
    MeetingGuestsEnum guests,
    bool locked,
    bool autoRecord,
    bool autoNotes,
    MeetingLanguageEnum language,
    List<int> cohostIds,
    DateTime? cancelledAt,
    DateTime createdAt,
    MeetingLive? live,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeeting.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeeting.copyWith.fieldName(...)`
class _$MeetingCWProxyImpl implements _$MeetingCWProxy {
  const _$MeetingCWProxyImpl(this._value);

  final Meeting _value;

  @override
  Meeting id(int id) => this(id: id);

  @override
  Meeting code(String code) => this(code: code);

  @override
  Meeting link(String link) => this(link: link);

  @override
  Meeting title(String title) => this(title: title);

  @override
  Meeting description(String description) => this(description: description);

  @override
  Meeting hostId(int? hostId) => this(hostId: hostId);

  @override
  Meeting hostName(String hostName) => this(hostName: hostName);

  @override
  Meeting kind(MeetingKindEnum kind) => this(kind: kind);

  @override
  Meeting startsAt(DateTime? startsAt) => this(startsAt: startsAt);

  @override
  Meeting endsAt(DateTime? endsAt) => this(endsAt: endsAt);

  @override
  Meeting durationMin(int durationMin) => this(durationMin: durationMin);

  @override
  Meeting timeZone(String timeZone) => this(timeZone: timeZone);

  @override
  Meeting access(MeetingAccessEnum access) => this(access: access);

  @override
  Meeting guests(MeetingGuestsEnum guests) => this(guests: guests);

  @override
  Meeting locked(bool locked) => this(locked: locked);

  @override
  Meeting autoRecord(bool autoRecord) => this(autoRecord: autoRecord);

  @override
  Meeting autoNotes(bool autoNotes) => this(autoNotes: autoNotes);

  @override
  Meeting language(MeetingLanguageEnum language) => this(language: language);

  @override
  Meeting cohostIds(List<int> cohostIds) => this(cohostIds: cohostIds);

  @override
  Meeting cancelledAt(DateTime? cancelledAt) => this(cancelledAt: cancelledAt);

  @override
  Meeting createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Meeting live(MeetingLive? live) => this(live: live);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meeting(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meeting(...).copyWith(id: 12, name: "My name")
  /// ````
  Meeting call({
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
  }) {
    return Meeting(
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
          : kind as MeetingKindEnum,
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
          : access as MeetingAccessEnum,
      guests: guests == const $CopyWithPlaceholder()
          ? _value.guests
          // ignore: cast_nullable_to_non_nullable
          : guests as MeetingGuestsEnum,
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
          : language as MeetingLanguageEnum,
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
    );
  }
}

extension $MeetingCopyWith on Meeting {
  /// Returns a callable class that can be used as follows: `instanceOfMeeting.copyWith(...)` or like so:`instanceOfMeeting.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingCWProxy get copyWith => _$MeetingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meeting _$MeetingFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('Meeting', json, ($checkedConvert) {
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
    ],
  );
  final val = Meeting(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    code: $checkedConvert('code', (v) => v as String),
    link: $checkedConvert('link', (v) => v as String),
    title: $checkedConvert('title', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    hostId: $checkedConvert('hostId', (v) => (v as num?)?.toInt()),
    hostName: $checkedConvert('hostName', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(_$MeetingKindEnumEnumMap, v),
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
      (v) => $enumDecode(_$MeetingAccessEnumEnumMap, v),
    ),
    guests: $checkedConvert(
      'guests',
      (v) => $enumDecode(_$MeetingGuestsEnumEnumMap, v),
    ),
    locked: $checkedConvert('locked', (v) => v as bool),
    autoRecord: $checkedConvert('autoRecord', (v) => v as bool),
    autoNotes: $checkedConvert('autoNotes', (v) => v as bool),
    language: $checkedConvert(
      'language',
      (v) => $enumDecode(_$MeetingLanguageEnumEnumMap, v),
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
  );
  return val;
});

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'link': instance.link,
  'title': instance.title,
  'description': instance.description,
  'hostId': ?instance.hostId,
  'hostName': instance.hostName,
  'kind': _$MeetingKindEnumEnumMap[instance.kind]!,
  'startsAt': ?instance.startsAt?.toIso8601String(),
  'endsAt': ?instance.endsAt?.toIso8601String(),
  'durationMin': instance.durationMin,
  'timeZone': instance.timeZone,
  'access': _$MeetingAccessEnumEnumMap[instance.access]!,
  'guests': _$MeetingGuestsEnumEnumMap[instance.guests]!,
  'locked': instance.locked,
  'autoRecord': instance.autoRecord,
  'autoNotes': instance.autoNotes,
  'language': _$MeetingLanguageEnumEnumMap[instance.language]!,
  'cohostIds': instance.cohostIds,
  'cancelledAt': ?instance.cancelledAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'live': ?instance.live?.toJson(),
};

const _$MeetingKindEnumEnumMap = {
  MeetingKindEnum.instant: 'instant',
  MeetingKindEnum.scheduled: 'scheduled',
};

const _$MeetingAccessEnumEnumMap = {
  MeetingAccessEnum.workspace: 'workspace',
  MeetingAccessEnum.invited: 'invited',
};

const _$MeetingGuestsEnumEnumMap = {
  MeetingGuestsEnum.off: 'off',
  MeetingGuestsEnum.knock: 'knock',
  MeetingGuestsEnum.open: 'open',
};

const _$MeetingLanguageEnumEnumMap = {
  MeetingLanguageEnum.auto: 'auto',
  MeetingLanguageEnum.en: 'en',
  MeetingLanguageEnum.ru: 'ru',
  MeetingLanguageEnum.uz: 'uz',
};
