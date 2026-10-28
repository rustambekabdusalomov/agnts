// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_prefs.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeetingPrefsCWProxy {
  MeetingPrefs reminderMinutes(MeetingPrefsReminderMinutesEnum reminderMinutes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingPrefs(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingPrefs(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingPrefs call({MeetingPrefsReminderMinutesEnum reminderMinutes});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeetingPrefs.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeetingPrefs.copyWith.fieldName(...)`
class _$MeetingPrefsCWProxyImpl implements _$MeetingPrefsCWProxy {
  const _$MeetingPrefsCWProxyImpl(this._value);

  final MeetingPrefs _value;

  @override
  MeetingPrefs reminderMinutes(
    MeetingPrefsReminderMinutesEnum reminderMinutes,
  ) => this(reminderMinutes: reminderMinutes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeetingPrefs(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeetingPrefs(...).copyWith(id: 12, name: "My name")
  /// ````
  MeetingPrefs call({Object? reminderMinutes = const $CopyWithPlaceholder()}) {
    return MeetingPrefs(
      reminderMinutes: reminderMinutes == const $CopyWithPlaceholder()
          ? _value.reminderMinutes
          // ignore: cast_nullable_to_non_nullable
          : reminderMinutes as MeetingPrefsReminderMinutesEnum,
    );
  }
}

extension $MeetingPrefsCopyWith on MeetingPrefs {
  /// Returns a callable class that can be used as follows: `instanceOfMeetingPrefs.copyWith(...)` or like so:`instanceOfMeetingPrefs.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeetingPrefsCWProxy get copyWith => _$MeetingPrefsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingPrefs _$MeetingPrefsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeetingPrefs', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reminderMinutes']);
      final val = MeetingPrefs(
        reminderMinutes: $checkedConvert(
          'reminderMinutes',
          (v) => $enumDecode(_$MeetingPrefsReminderMinutesEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeetingPrefsToJson(MeetingPrefs instance) =>
    <String, dynamic>{
      'reminderMinutes':
          _$MeetingPrefsReminderMinutesEnumEnumMap[instance.reminderMinutes]!,
    };

const _$MeetingPrefsReminderMinutesEnumEnumMap = {
  MeetingPrefsReminderMinutesEnum.number0: 0,
  MeetingPrefsReminderMinutesEnum.number5: 5,
  MeetingPrefsReminderMinutesEnum.number10: 10,
  MeetingPrefsReminderMinutesEnum.number15: 15,
};
