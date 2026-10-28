//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_meeting.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicMeeting {
  /// Returns a new [PublicMeeting] instance.
  PublicMeeting({

    required  this.code,

    required  this.title,

    required  this.hostName,

    required  this.workspace,

    required  this.kind,

     this.startsAt,

     this.endsAt,

     this.timeZone,

    required  this.cancelled,

    required  this.guests,

     this.live,

    required  this.inCall,

    required  this.recording,

    required  this.notes,

    required  this.member,

     this.name,

     this.googleClientId,
  });

  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'hostName',
    required: true,
    includeIfNull: false,
  )


  final String hostName;



      /// The workspace's name
  @JsonKey(
    
    name: r'workspace',
    required: true,
    includeIfNull: false,
  )


  final String workspace;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PublicMeetingKindEnum kind;



  @JsonKey(
    
    name: r'startsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startsAt;



  @JsonKey(
    
    name: r'endsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? endsAt;



  @JsonKey(
    
    name: r'timeZone',
    required: false,
    includeIfNull: false,
  )


  final String? timeZone;



  @JsonKey(
    
    name: r'cancelled',
    required: true,
    includeIfNull: false,
  )


  final bool cancelled;



  @JsonKey(
    
    name: r'guests',
    required: true,
    includeIfNull: false,
  )


  final PublicMeetingGuestsEnum guests;



  @JsonKey(
    
    name: r'live',
    required: false,
    includeIfNull: false,
  )


  final bool? live;



  @JsonKey(
    
    name: r'inCall',
    required: true,
    includeIfNull: false,
  )


  final int inCall;



      /// The call is being recorded
  @JsonKey(
    
    name: r'recording',
    required: true,
    includeIfNull: false,
  )


  final bool recording;



      /// agnts is taking notes of the call
  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: false,
  )


  final bool notes;



      /// You are signed in as a member of its workspace
  @JsonKey(
    
    name: r'member',
    required: true,
    includeIfNull: false,
  )


  final bool member;



      /// Your name, when signed in
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// For \"Continue with Google\"
  @JsonKey(
    
    name: r'googleClientId',
    required: false,
    includeIfNull: false,
  )


  final String? googleClientId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PublicMeeting &&
      other.code == code &&
      other.title == title &&
      other.hostName == hostName &&
      other.workspace == workspace &&
      other.kind == kind &&
      other.startsAt == startsAt &&
      other.endsAt == endsAt &&
      other.timeZone == timeZone &&
      other.cancelled == cancelled &&
      other.guests == guests &&
      other.live == live &&
      other.inCall == inCall &&
      other.recording == recording &&
      other.notes == notes &&
      other.member == member &&
      other.name == name &&
      other.googleClientId == googleClientId;

    @override
    int get hashCode =>
        code.hashCode +
        title.hashCode +
        hostName.hashCode +
        workspace.hashCode +
        kind.hashCode +
        startsAt.hashCode +
        endsAt.hashCode +
        timeZone.hashCode +
        cancelled.hashCode +
        guests.hashCode +
        live.hashCode +
        inCall.hashCode +
        recording.hashCode +
        notes.hashCode +
        member.hashCode +
        name.hashCode +
        googleClientId.hashCode;

  factory PublicMeeting.fromJson(Map<String, dynamic> json) => _$PublicMeetingFromJson(json);

  Map<String, dynamic> toJson() => _$PublicMeetingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PublicMeetingKindEnum {
@JsonValue(r'instant')
instant(r'instant'),
@JsonValue(r'scheduled')
scheduled(r'scheduled');

const PublicMeetingKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum PublicMeetingGuestsEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'knock')
knock(r'knock'),
@JsonValue(r'open')
open(r'open');

const PublicMeetingGuestsEnum(this.value);

final String value;

@override
String toString() => value;
}


