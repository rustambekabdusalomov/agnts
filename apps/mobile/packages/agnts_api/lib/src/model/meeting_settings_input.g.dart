// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_settings_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSettingsInputCWProxy {
  MeetingSettingsInput allowRecording(bool allowRecording);

  MeetingSettingsInput retentionDays(int retentionDays);

  MeetingSettingsInput keepAudio(bool keepAudio);

  MeetingSettingsInput maxParticipants(int maxParticipants);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettingsInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettingsInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettingsInput call({
    bool allowRecording,
    int retentionDays,
    bool keepAudio,
    int maxParticipants,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSettingsInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSettingsInput.copyWith.fieldName(...)`
class _$MeetingSettingsInputCWProxyImpl
    implements _$MeetingSettingsInputCWProxy {
  const _$MeetingSettingsInputCWProxyImpl(this._value);

  final MeetingSettingsInput _value;

  @override
  MeetingSettingsInput allowRecording(bool allowRecording) =>
      this(allowRecording: allowRecording);

  @override
  MeetingSettingsInput retentionDays(int retentionDays) =>
      this(retentionDays: retentionDays);

  @override
  MeetingSettingsInput keepAudio(bool keepAudio) => this(keepAudio: keepAudio);

  @override
  MeetingSettingsInput maxParticipants(int maxParticipants) =>
      this(maxParticipants: maxParticipants);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettingsInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettingsInput(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettingsInput call({
    Object? allowRecording = const $CopyWithPlaceholder(),
    Object? retentionDays = const $CopyWithPlaceholder(),
    Object? keepAudio = const $CopyWithPlaceholder(),
    Object? maxParticipants = const $CopyWithPlaceholder(),
  }) {
    return MeetingSettingsInput(
      allowRecording: allowRecording == const $CopyWithPlaceholder()
          ? _value.allowRecording
          // ignore: cast_nullable_to_non_nullable
          : allowRecording as bool,
      retentionDays: retentionDays == const $CopyWithPlaceholder()
          ? _value.retentionDays
          // ignore: cast_nullable_to_non_nullable
          : retentionDays as int,
      keepAudio: keepAudio == const $CopyWithPlaceholder()
          ? _value.keepAudio
          // ignore: cast_nullable_to_non_nullable
          : keepAudio as bool,
      maxParticipants: maxParticipants == const $CopyWithPlaceholder()
          ? _value.maxParticipants
          // ignore: cast_nullable_to_non_nullable
          : maxParticipants as int,
    );
  }
}

extension $MeetingSettingsInputCopyWith on MeetingSettingsInput {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSettingsInput.copyWith(...)` or like so:`instanceOfMeetingSettingsInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSettingsInputCWProxy get copyWith =>
      _$MeetingSettingsInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSettingsInput _$MeetingSettingsInputFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingSettingsInput', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'allowRecording',
      'retentionDays',
      'keepAudio',
      'maxParticipants',
    ],
  );
  final val = MeetingSettingsInput(
    allowRecording: $checkedConvert('allowRecording', (v) => v as bool),
    retentionDays: $checkedConvert('retentionDays', (v) => (v as num).toInt()),
    keepAudio: $checkedConvert('keepAudio', (v) => v as bool),
    maxParticipants: $checkedConvert(
      'maxParticipants',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$MeetingSettingsInputToJson(
  MeetingSettingsInput instance,
) => <String, dynamic>{
  'allowRecording': instance.allowRecording,
  'retentionDays': instance.retentionDays,
  'keepAudio': instance.keepAudio,
  'maxParticipants': instance.maxParticipants,
};
