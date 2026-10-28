//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_join_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingJoinInput {
  /// Returns a new [MeetingJoinInput] instance.
  MeetingJoinInput({

     this.name,

     this.googleCredential,

     this.invite,

     this.device,
  });

      /// A guest's name
  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



      /// A Google ID token: the guest is who Google says
  @JsonKey(
    
    name: r'googleCredential',
    required: false,
    includeIfNull: false,
  )


  final String? googleCredential;



      /// The token of an invitation link (?i=)
  @JsonKey(
    
    name: r'invite',
    required: false,
    includeIfNull: false,
  )


  final String? invite;



      /// The browser or phone: 4-16 letters and digits it keeps
  @JsonKey(
    
    name: r'device',
    required: false,
    includeIfNull: false,
  )


  final String? device;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingJoinInput &&
      other.name == name &&
      other.googleCredential == googleCredential &&
      other.invite == invite &&
      other.device == device;

    @override
    int get hashCode =>
        name.hashCode +
        googleCredential.hashCode +
        invite.hashCode +
        device.hashCode;

  factory MeetingJoinInput.fromJson(Map<String, dynamic> json) => _$MeetingJoinInputFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingJoinInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

