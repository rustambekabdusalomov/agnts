//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_person.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingPerson {
  /// Returns a new [MeetingPerson] instance.
  MeetingPerson({

    required  this.key,

    required  this.name,

    required  this.role,

    required  this.identities,

     this.email,

    required  this.knocked,
  });

      /// u<id> or g<id>
  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final MeetingPersonRoleEnum role;



      /// Their connections (one per device)
  @JsonKey(
    
    name: r'identities',
    required: true,
    includeIfNull: false,
  )


  final List<String> identities;



      /// A guest's, for hosts
  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'knocked',
    required: true,
    includeIfNull: false,
  )


  final bool knocked;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingPerson &&
      other.key == key &&
      other.name == name &&
      other.role == role &&
      other.identities == identities &&
      other.email == email &&
      other.knocked == knocked;

    @override
    int get hashCode =>
        key.hashCode +
        name.hashCode +
        role.hashCode +
        identities.hashCode +
        email.hashCode +
        knocked.hashCode;

  factory MeetingPerson.fromJson(Map<String, dynamic> json) => _$MeetingPersonFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingPersonToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MeetingPersonRoleEnum {
@JsonValue(r'host')
host(r'host'),
@JsonValue(r'cohost')
cohost(r'cohost'),
@JsonValue(r'member')
member(r'member'),
@JsonValue(r'guest')
guest(r'guest');

const MeetingPersonRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


