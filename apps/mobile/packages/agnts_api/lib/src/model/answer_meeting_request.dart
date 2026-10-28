//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_meeting_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswerMeetingRequest {
  /// Returns a new [AnswerMeetingRequest] instance.
  AnswerMeetingRequest({

    required  this.answer,
  });

  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final AnswerMeetingRequestAnswerEnum answer;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswerMeetingRequest &&
      other.answer == answer;

    @override
    int get hashCode =>
        answer.hashCode;

  factory AnswerMeetingRequest.fromJson(Map<String, dynamic> json) => _$AnswerMeetingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerMeetingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AnswerMeetingRequestAnswerEnum {
@JsonValue(r'true')
true_(r'true'),
@JsonValue(r'false')
false_(r'false'),
@JsonValue(r'maybe')
maybe(r'maybe');

const AnswerMeetingRequestAnswerEnum(this.value);

final String value;

@override
String toString() => value;
}


