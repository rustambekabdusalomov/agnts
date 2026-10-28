// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingInputCWProxy {
  MeetingInput title(String? title);

  MeetingInput description(String? description);

  MeetingInput kind(MeetingInputKindEnum? kind);

  MeetingInput startsAt(DateTime? startsAt);

  MeetingInput durationMin(int? durationMin);

  MeetingInput timeZone(String? timeZone);

  MeetingInput access(MeetingInputAccessEnum? access);

  MeetingInput guests(MeetingInputGuestsEnum? guests);

  MeetingInput autoRecord(bool? autoRecord);

  MeetingInput autoNotes(bool? autoNotes);

  MeetingInput language(MeetingInputLanguageEnum? language);

  MeetingInput invite(MeetingInvites? invite);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInput call({
    String? title,
    String? description,
    MeetingInputKindEnum? kind,
    DateTime? startsAt,
    int? durationMin,
    String? timeZone,
    MeetingInputAccessEnum? access,
    MeetingInputGuestsEnum? guests,
    bool? autoRecord,
    bool? autoNotes,
    MeetingInputLanguageEnum? language,
    MeetingInvites? invite,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingInput.copyWith.fieldName(...)`
class _$MeetingInputCWProxyImpl implements _$MeetingInputCWProxy {
  const _$MeetingInputCWProxyImpl(this._value);

  final MeetingInput _value;

  @override
  MeetingInput title(String? title) => this(title: title);

  @override
  MeetingInput description(String? description) =>
      this(description: description);

  @override
  MeetingInput kind(MeetingInputKindEnum? kind) => this(kind: kind);

  @override
  MeetingInput startsAt(DateTime? startsAt) => this(startsAt: startsAt);

  @override
  MeetingInput durationMin(int? durationMin) => this(durationMin: durationMin);

  @override
  MeetingInput timeZone(String? timeZone) => this(timeZone: timeZone);

  @override
  MeetingInput access(MeetingInputAccessEnum? access) => this(access: access);

  @override
  MeetingInput guests(MeetingInputGuestsEnum? guests) => this(guests: guests);

  @override
  MeetingInput autoRecord(bool? autoRecord) => this(autoRecord: autoRecord);

  @override
  MeetingInput autoNotes(bool? autoNotes) => this(autoNotes: autoNotes);

  @override
  MeetingInput language(MeetingInputLanguageEnum? language) =>
      this(language: language);

  @override
  MeetingInput invite(MeetingInvites? invite) => this(invite: invite);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingInput call({
    Object? title = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? startsAt = const $CopyWithPlaceholder(),
    Object? durationMin = const $CopyWithPlaceholder(),
    Object? timeZone = const $CopyWithPlaceholder(),
    Object? access = const $CopyWithPlaceholder(),
    Object? guests = const $CopyWithPlaceholder(),
    Object? autoRecord = const $CopyWithPlaceholder(),
    Object? autoNotes = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? invite = const $CopyWithPlaceholder(),
  }) {
    return MeetingInput(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as MeetingInputKindEnum?,
      startsAt: startsAt == const $CopyWithPlaceholder()
          ? _value.startsAt
          // ignore: cast_nullable_to_non_nullable
          : startsAt as DateTime?,
      durationMin: durationMin == const $CopyWithPlaceholder()
          ? _value.durationMin
          // ignore: cast_nullable_to_non_nullable
          : durationMin as int?,
      timeZone: timeZone == const $CopyWithPlaceholder()
          ? _value.timeZone
          // ignore: cast_nullable_to_non_nullable
          : timeZone as String?,
      access: access == const $CopyWithPlaceholder()
          ? _value.access
          // ignore: cast_nullable_to_non_nullable
          : access as MeetingInputAccessEnum?,
      guests: guests == const $CopyWithPlaceholder()
          ? _value.guests
          // ignore: cast_nullable_to_non_nullable
          : guests as MeetingInputGuestsEnum?,
      autoRecord: autoRecord == const $CopyWithPlaceholder()
          ? _value.autoRecord
          // ignore: cast_nullable_to_non_nullable
          : autoRecord as bool?,
      autoNotes: autoNotes == const $CopyWithPlaceholder()
          ? _value.autoNotes
          // ignore: cast_nullable_to_non_nullable
          : autoNotes as bool?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as MeetingInputLanguageEnum?,
      invite: invite == const $CopyWithPlaceholder()
          ? _value.invite
          // ignore: cast_nullable_to_non_nullable
          : invite as MeetingInvites?,
    );
  }
}

extension $MeetingInputCopyWith on MeetingInput {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingInput.copyWith(...)` or like so:`instanceOfMeetingInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingInputCWProxy get copyWith => _$MeetingInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingInput _$MeetingInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingInput', json, ($checkedConvert) {
  final val = MeetingInput(
    title: $checkedConvert('title', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecodeNullable(_$MeetingInputKindEnumEnumMap, v),
    ),
    startsAt: $checkedConvert(
      'startsAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    durationMin: $checkedConvert('durationMin', (v) => (v as num?)?.toInt()),
    timeZone: $checkedConvert('timeZone', (v) => v as String?),
    access: $checkedConvert(
      'access',
      (v) => $enumDecodeNullable(_$MeetingInputAccessEnumEnumMap, v),
    ),
    guests: $checkedConvert(
      'guests',
      (v) => $enumDecodeNullable(_$MeetingInputGuestsEnumEnumMap, v),
    ),
    autoRecord: $checkedConvert('autoRecord', (v) => v as bool?),
    autoNotes: $checkedConvert('autoNotes', (v) => v as bool?),
    language: $checkedConvert(
      'language',
      (v) => $enumDecodeNullable(_$MeetingInputLanguageEnumEnumMap, v),
    ),
    invite: $checkedConvert(
      'invite',
      (v) =>
          v == null ? null : MeetingInvites.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MeetingInputToJson(MeetingInput instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'description': ?instance.description,
      'kind': ?_$MeetingInputKindEnumEnumMap[instance.kind],
      'startsAt': ?instance.startsAt?.toIso8601String(),
      'durationMin': ?instance.durationMin,
      'timeZone': ?instance.timeZone,
      'access': ?_$MeetingInputAccessEnumEnumMap[instance.access],
      'guests': ?_$MeetingInputGuestsEnumEnumMap[instance.guests],
      'autoRecord': ?instance.autoRecord,
      'autoNotes': ?instance.autoNotes,
      'language': ?_$MeetingInputLanguageEnumEnumMap[instance.language],
      'invite': ?instance.invite?.toJson(),
    };

const _$MeetingInputKindEnumEnumMap = {
  MeetingInputKindEnum.instant: 'instant',
  MeetingInputKindEnum.scheduled: 'scheduled',
};

const _$MeetingInputAccessEnumEnumMap = {
  MeetingInputAccessEnum.workspace: 'workspace',
  MeetingInputAccessEnum.invited: 'invited',
};

const _$MeetingInputGuestsEnumEnumMap = {
  MeetingInputGuestsEnum.off: 'off',
  MeetingInputGuestsEnum.knock: 'knock',
  MeetingInputGuestsEnum.open: 'open',
};

const _$MeetingInputLanguageEnumEnumMap = {
  MeetingInputLanguageEnum.auto: 'auto',
  MeetingInputLanguageEnum.en: 'en',
  MeetingInputLanguageEnum.ru: 'ru',
  MeetingInputLanguageEnum.uz: 'uz',
};
