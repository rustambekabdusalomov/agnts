//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answers_request_answers_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnswersRequestAnswersInner {
  /// Returns a new [AnswersRequestAnswersInner] instance.
  AnswersRequestAnswersInner({

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



      /// For a multiple-choice question, the chosen options, one per line
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



      /// Uploads to attach to this answer
  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnswersRequestAnswersInner &&
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

  factory AnswersRequestAnswersInner.fromJson(Map<String, dynamic> json) => _$AnswersRequestAnswersInnerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswersRequestAnswersInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

