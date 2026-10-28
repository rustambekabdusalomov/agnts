//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_send_answers_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeSendAnswersInner {
  /// Returns a new [CodeSendAnswersInner] instance.
  CodeSendAnswersInner({

    required  this.questionId,

    required  this.answer,
  });

  @JsonKey(
    
    name: r'questionId',
    required: true,
    includeIfNull: false,
  )


  final int questionId;



  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeSendAnswersInner &&
      other.questionId == questionId &&
      other.answer == answer;

    @override
    int get hashCode =>
        questionId.hashCode +
        answer.hashCode;

  factory CodeSendAnswersInner.fromJson(Map<String, dynamic> json) => _$CodeSendAnswersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CodeSendAnswersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

