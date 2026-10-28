//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_settings_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSettingsInput {
  /// Returns a new [MeetingSettingsInput] instance.
  MeetingSettingsInput({

    required  this.allowRecording,

    required  this.retentionDays,

    required  this.keepAudio,

    required  this.maxParticipants,
  });

  @JsonKey(
    
    name: r'allowRecording',
    required: true,
    includeIfNull: false,
  )


  final bool allowRecording;



          // minimum: 0
          // maximum: 3650
  @JsonKey(
    
    name: r'retentionDays',
    required: true,
    includeIfNull: false,
  )


  final int retentionDays;



  @JsonKey(
    
    name: r'keepAudio',
    required: true,
    includeIfNull: false,
  )


  final bool keepAudio;



          // minimum: 2
          // maximum: 100
  @JsonKey(
    
    name: r'maxParticipants',
    required: true,
    includeIfNull: false,
  )


  final int maxParticipants;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSettingsInput &&
      other.allowRecording == allowRecording &&
      other.retentionDays == retentionDays &&
      other.keepAudio == keepAudio &&
      other.maxParticipants == maxParticipants;

    @override
    int get hashCode =>
        allowRecording.hashCode +
        retentionDays.hashCode +
        keepAudio.hashCode +
        maxParticipants.hashCode;

  factory MeetingSettingsInput.fromJson(Map<String, dynamic> json) => _$MeetingSettingsInputFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSettingsInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

