//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_settings_available.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_settings.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSettings {
  /// Returns a new [MeetingSettings] instance.
  MeetingSettings({

    required  this.allowRecording,

    required  this.retentionDays,

    required  this.keepAudio,

    required  this.maxParticipants,

    required  this.draftTickets,

    required  this.available,
  });

  @JsonKey(
    
    name: r'allowRecording',
    required: true,
    includeIfNull: false,
  )


  final bool allowRecording;



      /// Recordings, notes audio and transcripts are deleted after; 0 keeps them
  @JsonKey(
    
    name: r'retentionDays',
    required: true,
    includeIfNull: false,
  )


  final int retentionDays;



      /// Keep the audio of notes after it is heard
  @JsonKey(
    
    name: r'keepAudio',
    required: true,
    includeIfNull: false,
  )


  final bool keepAudio;



  @JsonKey(
    
    name: r'maxParticipants',
    required: true,
    includeIfNull: false,
  )


  final int maxParticipants;



      /// Every action item becomes a held draft ticket on the member who took it when the notes are written
  @JsonKey(
    
    name: r'draftTickets',
    required: true,
    includeIfNull: false,
  )


  final bool draftTickets;



  @JsonKey(
    
    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final MeetingSettingsAvailable available;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSettings &&
      other.allowRecording == allowRecording &&
      other.retentionDays == retentionDays &&
      other.keepAudio == keepAudio &&
      other.maxParticipants == maxParticipants &&
      other.draftTickets == draftTickets &&
      other.available == available;

    @override
    int get hashCode =>
        allowRecording.hashCode +
        retentionDays.hashCode +
        keepAudio.hashCode +
        maxParticipants.hashCode +
        draftTickets.hashCode +
        available.hashCode;

  factory MeetingSettings.fromJson(Map<String, dynamic> json) => _$MeetingSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

