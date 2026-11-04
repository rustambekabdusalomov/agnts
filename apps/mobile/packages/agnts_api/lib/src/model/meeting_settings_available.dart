//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_settings_available.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingSettingsAvailable {
  /// Returns a new [MeetingSettingsAvailable] instance.
  MeetingSettingsAvailable({

    required  this.meetings,

    required  this.recording,

    required  this.notes,

    required  this.uploads,

    required  this.maxUploadMb,
  });

  @JsonKey(
    
    name: r'meetings',
    required: true,
    includeIfNull: false,
  )


  final bool meetings;



  @JsonKey(
    
    name: r'recording',
    required: true,
    includeIfNull: false,
  )


  final bool recording;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final bool notes;



      /// Recordings can be uploaded and heard
  @JsonKey(
    
    name: r'uploads',
    required: true,
    includeIfNull: false,
  )


  final bool uploads;



      /// The largest recording that can be uploaded
  @JsonKey(
    
    name: r'maxUploadMb',
    required: true,
    includeIfNull: false,
  )


  final int maxUploadMb;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingSettingsAvailable &&
      other.meetings == meetings &&
      other.recording == recording &&
      other.notes == notes &&
      other.uploads == uploads &&
      other.maxUploadMb == maxUploadMb;

    @override
    int get hashCode =>
        meetings.hashCode +
        recording.hashCode +
        notes.hashCode +
        uploads.hashCode +
        maxUploadMb.hashCode;

  factory MeetingSettingsAvailable.fromJson(Map<String, dynamic> json) => _$MeetingSettingsAvailableFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingSettingsAvailableToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

