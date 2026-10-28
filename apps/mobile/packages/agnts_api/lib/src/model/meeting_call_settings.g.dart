// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_call_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingCallSettingsCWProxy {
  MeetingCallSettings locked(bool? locked);

  MeetingCallSettings guests(MeetingCallSettingsGuestsEnum? guests);

  MeetingCallSettings guestsQuiet(bool? guestsQuiet);

  MeetingCallSettings recording(bool? recording);

  MeetingCallSettings notes(bool? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingCallSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingCallSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingCallSettings call({
    bool? locked,
    MeetingCallSettingsGuestsEnum? guests,
    bool? guestsQuiet,
    bool? recording,
    bool? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingCallSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingCallSettings.copyWith.fieldName(...)`
class _$MeetingCallSettingsCWProxyImpl implements _$MeetingCallSettingsCWProxy {
  const _$MeetingCallSettingsCWProxyImpl(this._value);

  final MeetingCallSettings _value;

  @override
  MeetingCallSettings locked(bool? locked) => this(locked: locked);

  @override
  MeetingCallSettings guests(MeetingCallSettingsGuestsEnum? guests) =>
      this(guests: guests);

  @override
  MeetingCallSettings guestsQuiet(bool? guestsQuiet) =>
      this(guestsQuiet: guestsQuiet);

  @override
  MeetingCallSettings recording(bool? recording) => this(recording: recording);

  @override
  MeetingCallSettings notes(bool? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingCallSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingCallSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingCallSettings call({
    Object? locked = const $CopyWithPlaceholder(),
    Object? guests = const $CopyWithPlaceholder(),
    Object? guestsQuiet = const $CopyWithPlaceholder(),
    Object? recording = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return MeetingCallSettings(
      locked: locked == const $CopyWithPlaceholder()
          ? _value.locked
          // ignore: cast_nullable_to_non_nullable
          : locked as bool?,
      guests: guests == const $CopyWithPlaceholder()
          ? _value.guests
          // ignore: cast_nullable_to_non_nullable
          : guests as MeetingCallSettingsGuestsEnum?,
      guestsQuiet: guestsQuiet == const $CopyWithPlaceholder()
          ? _value.guestsQuiet
          // ignore: cast_nullable_to_non_nullable
          : guestsQuiet as bool?,
      recording: recording == const $CopyWithPlaceholder()
          ? _value.recording
          // ignore: cast_nullable_to_non_nullable
          : recording as bool?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as bool?,
    );
  }
}

extension $MeetingCallSettingsCopyWith on MeetingCallSettings {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingCallSettings.copyWith(...)` or like so:`instanceOfMeetingCallSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingCallSettingsCWProxy get copyWith =>
      _$MeetingCallSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingCallSettings _$MeetingCallSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingCallSettings', json, ($checkedConvert) {
      final val = MeetingCallSettings(
        locked: $checkedConvert('locked', (v) => v as bool?),
        guests: $checkedConvert(
          'guests',
          (v) => $enumDecodeNullable(_$MeetingCallSettingsGuestsEnumEnumMap, v),
        ),
        guestsQuiet: $checkedConvert('guestsQuiet', (v) => v as bool?),
        recording: $checkedConvert('recording', (v) => v as bool?),
        notes: $checkedConvert('notes', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$MeetingCallSettingsToJson(
  MeetingCallSettings instance,
) => <String, dynamic>{
  'locked': ?instance.locked,
  'guests': ?_$MeetingCallSettingsGuestsEnumEnumMap[instance.guests],
  'guestsQuiet': ?instance.guestsQuiet,
  'recording': ?instance.recording,
  'notes': ?instance.notes,
};

const _$MeetingCallSettingsGuestsEnumEnumMap = {
  MeetingCallSettingsGuestsEnum.off: 'off',
  MeetingCallSettingsGuestsEnum.knock: 'knock',
  MeetingCallSettingsGuestsEnum.open: 'open',
};
