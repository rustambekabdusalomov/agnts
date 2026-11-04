//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_invitee.dart';
import 'package:agnts_api/src/model/meeting_live.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingDetail {
  /// Returns a new [MeetingDetail] instance.
  MeetingDetail({

    required  this.id,

    required  this.code,

    required  this.link,

    required  this.title,

    required  this.description,

     this.hostId,

    required  this.hostName,

    required  this.kind,

     this.startsAt,

     this.endsAt,

    required  this.durationMin,

    required  this.timeZone,

    required  this.access,

    required  this.guests,

    required  this.locked,

    required  this.autoRecord,

    required  this.autoNotes,

    required  this.language,

    required  this.cohostIds,

     this.cancelledAt,

    required  this.createdAt,

     this.live,

    required  this.invitees,

     this.myRsvp,

    required  this.canManage,

    required  this.canUpload,

    required  this.maxUploadMb,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// abc-defg-hij
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



      /// The meeting's public link
  @JsonKey(
    
    name: r'link',
    required: true,
    includeIfNull: false,
  )


  final String link;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'hostId',
    required: false,
    includeIfNull: false,
  )


  final int? hostId;



  @JsonKey(
    
    name: r'hostName',
    required: true,
    includeIfNull: false,
  )


  final String hostName;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final MeetingDetailKindEnum kind;



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
    
    name: r'durationMin',
    required: true,
    includeIfNull: false,
  )


  final int durationMin;



  @JsonKey(
    
    name: r'timeZone',
    required: true,
    includeIfNull: false,
  )


  final String timeZone;



      /// workspace: every member joins; invited: only invitees, other members knock
  @JsonKey(
    
    name: r'access',
    required: true,
    includeIfNull: false,
  )


  final MeetingDetailAccessEnum access;



      /// What people without a membership may do
  @JsonKey(
    
    name: r'guests',
    required: true,
    includeIfNull: false,
  )


  final MeetingDetailGuestsEnum guests;



  @JsonKey(
    
    name: r'locked',
    required: true,
    includeIfNull: false,
  )


  final bool locked;



  @JsonKey(
    
    name: r'autoRecord',
    required: true,
    includeIfNull: false,
  )


  final bool autoRecord;



  @JsonKey(
    
    name: r'autoNotes',
    required: true,
    includeIfNull: false,
  )


  final bool autoNotes;



  @JsonKey(
    
    name: r'language',
    required: true,
    includeIfNull: false,
  )


  final MeetingDetailLanguageEnum language;



  @JsonKey(
    
    name: r'cohostIds',
    required: true,
    includeIfNull: false,
  )


  final List<int> cohostIds;



  @JsonKey(
    
    name: r'cancelledAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? cancelledAt;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'live',
    required: false,
    includeIfNull: false,
  )


  final MeetingLive? live;



  @JsonKey(
    
    name: r'invitees',
    required: true,
    includeIfNull: false,
  )


  final List<MeetingInvitee> invitees;



      /// Set when you are invited
  @JsonKey(
    
    name: r'myRsvp',
    required: false,
    includeIfNull: false,
  )


  final MeetingDetailMyRsvpEnum? myRsvp;



      /// You may change, invite, cancel
  @JsonKey(
    
    name: r'canManage',
    required: true,
    includeIfNull: false,
  )


  final bool canManage;



      /// You may upload a recording of it (uploadMeetingRecording): you host it and this server hears uploads
  @JsonKey(
    
    name: r'canUpload',
    required: true,
    includeIfNull: false,
  )


  final bool canUpload;



      /// The largest recording that can be uploaded
  @JsonKey(
    
    name: r'maxUploadMb',
    required: true,
    includeIfNull: false,
  )


  final int maxUploadMb;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingDetail &&
      other.id == id &&
      other.code == code &&
      other.link == link &&
      other.title == title &&
      other.description == description &&
      other.hostId == hostId &&
      other.hostName == hostName &&
      other.kind == kind &&
      other.startsAt == startsAt &&
      other.endsAt == endsAt &&
      other.durationMin == durationMin &&
      other.timeZone == timeZone &&
      other.access == access &&
      other.guests == guests &&
      other.locked == locked &&
      other.autoRecord == autoRecord &&
      other.autoNotes == autoNotes &&
      other.language == language &&
      other.cohostIds == cohostIds &&
      other.cancelledAt == cancelledAt &&
      other.createdAt == createdAt &&
      other.live == live &&
      other.invitees == invitees &&
      other.myRsvp == myRsvp &&
      other.canManage == canManage &&
      other.canUpload == canUpload &&
      other.maxUploadMb == maxUploadMb;

    @override
    int get hashCode =>
        id.hashCode +
        code.hashCode +
        link.hashCode +
        title.hashCode +
        description.hashCode +
        hostId.hashCode +
        hostName.hashCode +
        kind.hashCode +
        startsAt.hashCode +
        endsAt.hashCode +
        durationMin.hashCode +
        timeZone.hashCode +
        access.hashCode +
        guests.hashCode +
        locked.hashCode +
        autoRecord.hashCode +
        autoNotes.hashCode +
        language.hashCode +
        cohostIds.hashCode +
        cancelledAt.hashCode +
        createdAt.hashCode +
        live.hashCode +
        invitees.hashCode +
        myRsvp.hashCode +
        canManage.hashCode +
        canUpload.hashCode +
        maxUploadMb.hashCode;

  factory MeetingDetail.fromJson(Map<String, dynamic> json) => _$MeetingDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingDetailKindEnum {
@JsonValue(r'instant')
instant(r'instant'),
@JsonValue(r'scheduled')
scheduled(r'scheduled');

const MeetingDetailKindEnum(this.value);

final String value;

@override
String toString() => value;
}


/// workspace: every member joins; invited: only invitees, other members knock
enum MeetingDetailAccessEnum {
@JsonValue(r'workspace')
workspace(r'workspace'),
@JsonValue(r'invited')
invited(r'invited');

const MeetingDetailAccessEnum(this.value);

final String value;

@override
String toString() => value;
}


/// What people without a membership may do
enum MeetingDetailGuestsEnum {
@JsonValue(r'off')
off(r'off'),
@JsonValue(r'knock')
knock(r'knock'),
@JsonValue(r'open')
open(r'open');

const MeetingDetailGuestsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MeetingDetailLanguageEnum {
@JsonValue(r'auto')
auto(r'auto'),
@JsonValue(r'en')
en(r'en'),
@JsonValue(r'ru')
ru(r'ru'),
@JsonValue(r'uz')
uz(r'uz');

const MeetingDetailLanguageEnum(this.value);

final String value;

@override
String toString() => value;
}


/// Set when you are invited
enum MeetingDetailMyRsvpEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'true')
true_(r'true'),
@JsonValue(r'false')
false_(r'false'),
@JsonValue(r'maybe')
maybe(r'maybe');

const MeetingDetailMyRsvpEnum(this.value);

final String value;

@override
String toString() => value;
}


