//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:hiro_api/src/model/answers_request_answers_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answers_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswersRequest {
  /// Returns a new [AnswersRequest] instance.
  AnswersRequest({

    required  this.answers,
  });

  @JsonKey(
    
    name: r'answers',
    required: true,
    includeIfNull: false,
  )


  final List<AnswersRequestAnswersInner> answers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswersRequest &&
      other.answers == answers;

    @override
    int get hashCode =>
        answers.hashCode;

  factory AnswersRequest.fromJson(Map<String, dynamic> json) => _$AnswersRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnswersRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

