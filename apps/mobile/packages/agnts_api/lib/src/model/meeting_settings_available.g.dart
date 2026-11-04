// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_settings_available.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingSettingsAvailableCWProxy {
  MeetingSettingsAvailable meetings(bool meetings);

  MeetingSettingsAvailable recording(bool recording);

  MeetingSettingsAvailable notes(bool notes);

  MeetingSettingsAvailable uploads(bool uploads);

  MeetingSettingsAvailable maxUploadMb(int maxUploadMb);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettingsAvailable(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettingsAvailable(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettingsAvailable call({
    bool meetings,
    bool recording,
    bool notes,
    bool uploads,
    int maxUploadMb,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingSettingsAvailable.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingSettingsAvailable.copyWith.fieldName(...)`
class _$MeetingSettingsAvailableCWProxyImpl
    implements _$MeetingSettingsAvailableCWProxy {
  const _$MeetingSettingsAvailableCWProxyImpl(this._value);

  final MeetingSettingsAvailable _value;

  @override
  MeetingSettingsAvailable meetings(bool meetings) => this(meetings: meetings);

  @override
  MeetingSettingsAvailable recording(bool recording) =>
      this(recording: recording);

  @override
  MeetingSettingsAvailable notes(bool notes) => this(notes: notes);

  @override
  MeetingSettingsAvailable uploads(bool uploads) => this(uploads: uploads);

  @override
  MeetingSettingsAvailable maxUploadMb(int maxUploadMb) =>
      this(maxUploadMb: maxUploadMb);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingSettingsAvailable(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingSettingsAvailable(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingSettingsAvailable call({
    Object? meetings = const $CopyWithPlaceholder(),
    Object? recording = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? uploads = const $CopyWithPlaceholder(),
    Object? maxUploadMb = const $CopyWithPlaceholder(),
  }) {
    return MeetingSettingsAvailable(
      meetings: meetings == const $CopyWithPlaceholder()
          ? _value.meetings
          // ignore: cast_nullable_to_non_nullable
          : meetings as bool,
      recording: recording == const $CopyWithPlaceholder()
          ? _value.recording
          // ignore: cast_nullable_to_non_nullable
          : recording as bool,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as bool,
      uploads: uploads == const $CopyWithPlaceholder()
          ? _value.uploads
          // ignore: cast_nullable_to_non_nullable
          : uploads as bool,
      maxUploadMb: maxUploadMb == const $CopyWithPlaceholder()
          ? _value.maxUploadMb
          // ignore: cast_nullable_to_non_nullable
          : maxUploadMb as int,
    );
  }
}

extension $MeetingSettingsAvailableCopyWith on MeetingSettingsAvailable {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingSettingsAvailable.copyWith(...)` or like so:`instanceOfMeetingSettingsAvailable.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingSettingsAvailableCWProxy get copyWith =>
      _$MeetingSettingsAvailableCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingSettingsAvailable _$MeetingSettingsAvailableFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MeetingSettingsAvailable', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'meetings',
      'recording',
      'notes',
      'uploads',
      'maxUploadMb',
    ],
  );
  final val = MeetingSettingsAvailable(
    meetings: $checkedConvert('meetings', (v) => v as bool),
    recording: $checkedConvert('recording', (v) => v as bool),
    notes: $checkedConvert('notes', (v) => v as bool),
    uploads: $checkedConvert('uploads', (v) => v as bool),
    maxUploadMb: $checkedConvert('maxUploadMb', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$MeetingSettingsAvailableToJson(
  MeetingSettingsAvailable instance,
) => <String, dynamic>{
  'meetings': instance.meetings,
  'recording': instance.recording,
  'notes': instance.notes,
  'uploads': instance.uploads,
  'maxUploadMb': instance.maxUploadMb,
};
