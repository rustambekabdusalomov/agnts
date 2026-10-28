//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_invitee.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingInvitee {
  /// Returns a new [MeetingInvitee] instance.
  MeetingInvitee({

    required  this.id,

     this.userId,

    required  this.email,

    required  this.name,

    required  this.rsvp,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



      /// A member; absent for an email address
  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final int? userId;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'rsvp',
    required: true,
    includeIfNull: false,
  )


  final MeetingInviteeRsvpEnum rsvp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingInvitee &&
      other.id == id &&
      other.userId == userId &&
      other.email == email &&
      other.name == name &&
      other.rsvp == rsvp;

    @override
    int get hashCode =>
        id.hashCode +
        userId.hashCode +
        email.hashCode +
        name.hashCode +
        rsvp.hashCode;

  factory MeetingInvitee.fromJson(Map<String, dynamic> json) => _$MeetingInviteeFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingInviteeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingInviteeRsvpEnum {
@JsonValue(r'none')
none(r'none'),
@JsonValue(r'true')
true_(r'true'),
@JsonValue(r'false')
false_(r'false'),
@JsonValue(r'maybe')
maybe(r'maybe');

const MeetingInviteeRsvpEnum(this.value);

final String value;

@override
String toString() => value;
}


