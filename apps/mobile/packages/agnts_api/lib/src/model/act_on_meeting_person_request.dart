//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'act_on_meeting_person_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActOnMeetingPersonRequest {
  /// Returns a new [ActOnMeetingPersonRequest] instance.
  ActOnMeetingPersonRequest({

     this.source_,
  });

  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final ActOnMeetingPersonRequestSource_Enum? source_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActOnMeetingPersonRequest &&
      other.source_ == source_;

    @override
    int get hashCode =>
        source_.hashCode;

  factory ActOnMeetingPersonRequest.fromJson(Map<String, dynamic> json) => _$ActOnMeetingPersonRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ActOnMeetingPersonRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ActOnMeetingPersonRequestSource_Enum {
@JsonValue(r'microphone')
microphone(r'microphone'),
@JsonValue(r'camera')
camera(r'camera'),
@JsonValue(r'screen_share')
screenShare(r'screen_share');

const ActOnMeetingPersonRequestSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


