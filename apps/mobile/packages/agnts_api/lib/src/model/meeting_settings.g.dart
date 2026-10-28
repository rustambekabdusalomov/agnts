// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSettingsCWProxy {
  MeetingSettings allowRecording(bool allowRecording);

  MeetingSettings retentionDays(int retentionDays);

  MeetingSettings keepAudio(bool keepAudio);

  MeetingSettings maxParticipants(int maxParticipants);

  MeetingSettings available(MeetingSettingsAvailable available);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettings call({
    bool allowRecording,
    int retentionDays,
    bool keepAudio,
    int maxParticipants,
    MeetingSettingsAvailable available,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSettings.copyWith.fieldName(...)`
class _$MeetingSettingsCWProxyImpl implements _$MeetingSettingsCWProxy {
  const _$MeetingSettingsCWProxyImpl(this._value);

  final MeetingSettings _value;

  @override
  MeetingSettings allowRecording(bool allowRecording) =>
      this(allowRecording: allowRecording);

  @override
  MeetingSettings retentionDays(int retentionDays) =>
      this(retentionDays: retentionDays);

  @override
  MeetingSettings keepAudio(bool keepAudio) => this(keepAudio: keepAudio);

  @override
  MeetingSettings maxParticipants(int maxParticipants) =>
      this(maxParticipants: maxParticipants);

  @override
  MeetingSettings available(MeetingSettingsAvailable available) =>
      this(available: available);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettings call({
    Object? allowRecording = const $CopyWithPlaceholder(),
    Object? retentionDays = const $CopyWithPlaceholder(),
    Object? keepAudio = const $CopyWithPlaceholder(),
    Object? maxParticipants = const $CopyWithPlaceholder(),
    Object? available = const $CopyWithPlaceholder(),
  }) {
    return MeetingSettings(
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
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as MeetingSettingsAvailable,
    );
  }
}

extension $MeetingSettingsCopyWith on MeetingSettings {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSettings.copyWith(...)` or like so:`instanceOfMeetingSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSettingsCWProxy get copyWith => _$MeetingSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSettings _$MeetingSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingSettings', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'allowRecording',
          'retentionDays',
          'keepAudio',
          'maxParticipants',
          'available',
        ],
      );
      final val = MeetingSettings(
        allowRecording: $checkedConvert('allowRecording', (v) => v as bool),
        retentionDays: $checkedConvert(
          'retentionDays',
          (v) => (v as num).toInt(),
        ),
        keepAudio: $checkedConvert('keepAudio', (v) => v as bool),
        maxParticipants: $checkedConvert(
          'maxParticipants',
          (v) => (v as num).toInt(),
        ),
        available: $checkedConvert(
          'available',
          (v) => MeetingSettingsAvailable.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingSettingsToJson(MeetingSettings instance) =>
    <String, dynamic>{
      'allowRecording': instance.allowRecording,
      'retentionDays': instance.retentionDays,
      'keepAudio': instance.keepAudio,
      'maxParticipants': instance.maxParticipants,
      'available': instance.available.toJson(),
    };
