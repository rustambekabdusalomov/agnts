//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_draft_request_answers_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswerDraftRequestAnswersInner {
  /// Returns a new [AnswerDraftRequestAnswersInner] instance.
  AnswerDraftRequestAnswersInner({

    required  this.questionId,

    required  this.answer,

     this.note,

     this.attachments,
  });

  @JsonKey(
    
    name: r'questionId',
    required: true,
    includeIfNull: false,
  )


  final int questionId;



      /// As in AnswersRequest; may be empty
  @JsonKey(
    
    name: r'answer',
    required: true,
    includeIfNull: false,
  )


  final String answer;



  @JsonKey(
    
    name: r'note',
    required: false,
    includeIfNull: false,
  )


  final String? note;



      /// Pending uploads the answer will attach; they stay pending
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswerDraftRequestAnswersInner &&
      other.questionId == questionId &&
      other.answer == answer &&
      other.note == note &&
      other.attachments == attachments;

    @override
    int get hashCode =>
        questionId.hashCode +
        answer.hashCode +
        note.hashCode +
        attachments.hashCode;

  factory AnswerDraftRequestAnswersInner.fromJson(Map<String, dynamic> json) => _$AnswerDraftRequestAnswersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerDraftRequestAnswersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

