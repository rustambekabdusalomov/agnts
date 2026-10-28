//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_prefs.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingPrefs {
  /// Returns a new [MeetingPrefs] instance.
  MeetingPrefs({

    required  this.reminderMinutes,
  });

      /// 0 turns reminders off
  @JsonKey(
    
    name: r'reminderMinutes',
    required: true,
    includeIfNull: false,
  )


  final MeetingPrefsReminderMinutesEnum reminderMinutes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingPrefs &&
      other.reminderMinutes == reminderMinutes;

    @override
    int get hashCode =>
        reminderMinutes.hashCode;

  factory MeetingPrefs.fromJson(Map<String, dynamic> json) => _$MeetingPrefsFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingPrefsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// 0 turns reminders off
enum MeetingPrefsReminderMinutesEnum {
@JsonValue(0)
number0('0'),
@JsonValue(5)
number5('5'),
@JsonValue(10)
number10('10'),
@JsonValue(15)
number15('15');

const MeetingPrefsReminderMinutesEnum(this.value);

final String value;

@override
String toString() => value;
}


