//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/answer_draft_request_answers_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_draft_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswerDraftRequest {
  /// Returns a new [AnswerDraftRequest] instance.
  AnswerDraftRequest({

    required  this.answers,
  });

  @JsonKey(
    
    name: r'answers',
    required: true,
    includeIfNull: false,
  )


  final List<AnswerDraftRequestAnswersInner> answers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswerDraftRequest &&
      other.answers == answers;

    @override
    int get hashCode =>
        answers.hashCode;

  factory AnswerDraftRequest.fromJson(Map<String, dynamic> json) => _$AnswerDraftRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerDraftRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

