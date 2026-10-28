//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_attendee.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeetingAttendee {
  /// Returns a new [MeetingAttendee] instance.
  MeetingAttendee({

    required  this.person,

    required  this.name,

    required  this.guest,

     this.email,

    required  this.firstIn,

     this.lastOut,

    required  this.seconds,
  });

      /// u<id> or g<id>
  @JsonKey(
    
    name: r'person',
    required: true,
    includeIfNull: false,
  )


  final String person;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'guest',
    required: true,
    includeIfNull: false,
  )


  final bool guest;



      /// A guest's, when Google or an invitation gave it
  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'firstIn',
    required: true,
    includeIfNull: false,
  )


  final DateTime firstIn;



      /// Absent while still in the call
  @JsonKey(
    
    name: r'lastOut',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastOut;



  @JsonKey(
    
    name: r'seconds',
    required: true,
    includeIfNull: false,
  )


  final int seconds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeetingAttendee &&
      other.person == person &&
      other.name == name &&
      other.guest == guest &&
      other.email == email &&
      other.firstIn == firstIn &&
      other.lastOut == lastOut &&
      other.seconds == seconds;

    @override
    int get hashCode =>
        person.hashCode +
        name.hashCode +
        guest.hashCode +
        email.hashCode +
        firstIn.hashCode +
        lastOut.hashCode +
        seconds.hashCode;

  factory MeetingAttendee.fromJson(Map<String, dynamic> json) => _$MeetingAttendeeFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingAttendeeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

