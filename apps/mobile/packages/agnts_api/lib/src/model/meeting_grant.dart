//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/meeting_rights.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_grant.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingGrant {
  /// Returns a new [MeetingGrant] instance.
  MeetingGrant({

    required  this.url,

    required  this.token,

    required  this.identity,

     this.seat,

    required  this.role,

    required  this.rights,

    required  this.sessionId,

    required  this.name,
  });

      /// The LiveKit server (wss://)
  @JsonKey(
    
    name: r'url',
    required: true,
    includeIfNull: false,
  )


  final String url;



      /// The LiveKit access token
  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'identity',
    required: true,
    includeIfNull: false,
  )


  final String identity;



      /// Send as X-Meeting-Seat with in-call requests
  @JsonKey(
    
    name: r'seat',
    required: false,
    includeIfNull: false,
  )


  final String? seat;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final MeetingGrantRoleEnum role;



  @JsonKey(
    
    name: r'rights',
    required: true,
    includeIfNull: false,
  )


  final MeetingRights rights;



  @JsonKey(
    
    name: r'sessionId',
    required: true,
    includeIfNull: false,
  )


  final int sessionId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingGrant &&
      other.url == url &&
      other.token == token &&
      other.identity == identity &&
      other.seat == seat &&
      other.role == role &&
      other.rights == rights &&
      other.sessionId == sessionId &&
      other.name == name;

    @override
    int get hashCode =>
        url.hashCode +
        token.hashCode +
        identity.hashCode +
        seat.hashCode +
        role.hashCode +
        rights.hashCode +
        sessionId.hashCode +
        name.hashCode;

  factory MeetingGrant.fromJson(Map<String, dynamic> json) => _$MeetingGrantFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingGrantToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingGrantRoleEnum {
@JsonValue(r'host')
host(r'host'),
@JsonValue(r'cohost')
cohost(r'cohost'),
@JsonValue(r'member')
member(r'member'),
@JsonValue(r'guest')
guest(r'guest');

const MeetingGrantRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


