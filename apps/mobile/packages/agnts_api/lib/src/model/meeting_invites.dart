//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_invites.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingInvites {
  /// Returns a new [MeetingInvites] instance.
  MeetingInvites({

     this.users,

     this.emails,
  });

  @JsonKey(
    
    name: r'users',
    required: false,
    includeIfNull: false,
  )


  final List<int>? users;



  @JsonKey(
    
    name: r'emails',
    required: false,
    includeIfNull: false,
  )


  final List<String>? emails;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingInvites &&
      other.users == users &&
      other.emails == emails;

    @override
    int get hashCode =>
        users.hashCode +
        emails.hashCode;

  factory MeetingInvites.fromJson(Map<String, dynamic> json) => _$MeetingInvitesFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingInvitesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

