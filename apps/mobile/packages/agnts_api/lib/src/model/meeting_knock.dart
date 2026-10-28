//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_knock.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingKnock {
  /// Returns a new [MeetingKnock] instance.
  MeetingKnock({

    required  this.id,

    required  this.name,

     this.email,

    required  this.guest,

    required  this.at,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'guest',
    required: true,
    includeIfNull: false,
  )


  final bool guest;



  @JsonKey(
    
    name: r'at',
    required: true,
    includeIfNull: false,
  )


  final DateTime at;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingKnock &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.guest == guest &&
      other.at == at;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        email.hashCode +
        guest.hashCode +
        at.hashCode;

  factory MeetingKnock.fromJson(Map<String, dynamic> json) => _$MeetingKnockFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingKnockToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

