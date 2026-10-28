//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_invites.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingInput {
  /// Returns a new [MeetingInput] instance.
  MeetingInput({

     this.title,

     this.description,

     this.kind,

     this.startsAt,

     this.durationMin,

     this.timeZone,

     this.access,

     this.guests,

     this.autoRecord,

     this.autoNotes,

     this.language,

     this.invite,
  });

  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



      /// instant when absent
  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final MeetingInputKindEnum? kind;



  @JsonKey(
    
    name: r'startsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startsAt;



          // minimum: 5
          // maximum: 720
  @JsonKey(
    
    name: r'durationMin',
    required: false,
    includeIfNull: false,
  )


  final int? durationMin;



      /// IANA, e.g. Asia/Tashkent
  @JsonKey(
    
    name: r'timeZone',
    required: false,
    includeIfNull: false,
  )


  final String? timeZone;



  @JsonKey(
    
    name: r'access',
    required: false,
    includeIfNull: false,
  )


  final MeetingInputAccessEnum? access;



  @JsonKey(
    
    name: r'guests',
    required: false,
    includeIfNull: false,
  )


  final MeetingInputGuestsEnum? guests;



  @JsonKey(
    
    name: r'autoRecord',
    required: false,
    includeIfNull: false,
  )


  final bool? autoRecord;



  @JsonKey(
    
    name: r'autoNotes',
    required: false,
    includeIfNull: false,
  )


  final bool? autoNotes;



  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final MeetingInputLanguageEnum? language;



  @JsonKey(
    
    name: r'invite',
    required: false,
    includeIfNull: false,
  )


  final MeetingInvites? invite;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingInput &&
      other.title == title &&
      other.description == description &&
      other.kind == kind &&
      other.startsAt == startsAt &&
      other.durationMin == durationMin &&
      other.timeZone == timeZone &&
      other.access == access &&
      other.guests == guests &&
      other.autoRecord == autoRecord &&
      other.autoNotes == autoNotes &&
      other.language == language &&
      other.invite == invite;

    @override
    int get hashCode =>
        title.hashCode +
        description.hashCode +
        kind.hashCode +
        startsAt.hashCode +
        durationMin.hashCode +
        timeZone.hashCode +
        access.hashCode +
        guests.hashCode +
        autoRecord.hashCode +
        autoNotes.hashCode +
        language.hashCode +
        invite.hashCode;

  factory MeetingInput.fromJson(Map<String, dynamic> json) => _$MeetingInputFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// instant when absent
enum MeetingInputKindEnum {
@JsonValue(r'instant')
instant(r'instant'),
@JsonValue(r'scheduled')
scheduled(r'scheduled');

const MeetingInputKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MeetingInputAccessEnum {
@JsonValue(r'workspace')
workspace(r'workspace'),
@JsonValue(r'invited')
invited(r'invited');

const MeetingInputAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MeetingInputGuestsEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'knock')
knock(r'knock'),
@JsonValue(r'open')
open(r'open');

const MeetingInputGuestsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MeetingInputLanguageEnum {
@JsonValue(r'auto')
auto(r'auto'),
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const MeetingInputLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


