//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_call_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingCallSettings {
  /// Returns a new [MeetingCallSettings] instance.
  MeetingCallSettings({

     this.locked,

     this.guests,

     this.guestsQuiet,

     this.recording,

     this.notes,
  });

  @JsonKey(
    
    name: r'locked',
    required: false,
    includeIfNull: false,
  )


  final bool? locked;



  @JsonKey(
    
    name: r'guests',
    required: false,
    includeIfNull: false,
  )


  final MeetingCallSettingsGuestsEnum? guests;



      /// Guests can't chat or share their screen
  @JsonKey(
    
    name: r'guestsQuiet',
    required: false,
    includeIfNull: false,
  )


  final bool? guestsQuiet;



      /// Start or stop the video recording
  @JsonKey(
    
    name: r'recording',
    required: false,
    includeIfNull: false,
  )


  final bool? recording;



      /// Start or stop taking notes
  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final bool? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingCallSettings &&
      other.locked == locked &&
      other.guests == guests &&
      other.guestsQuiet == guestsQuiet &&
      other.recording == recording &&
      other.notes == notes;

    @override
    int get hashCode =>
        locked.hashCode +
        guests.hashCode +
        guestsQuiet.hashCode +
        recording.hashCode +
        notes.hashCode;

  factory MeetingCallSettings.fromJson(Map<String, dynamic> json) => _$MeetingCallSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingCallSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingCallSettingsGuestsEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'knock')
knock(r'knock'),
@JsonValue(r'open')
open(r'open');

const MeetingCallSettingsGuestsEnum(this.value);

final String value;

@override
String toString() => value;
}


