//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agnts_api/src/model/code_send_answers_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'code_send.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CodeSend {
  /// Returns a new [CodeSend] instance.
  CodeSend({

     this.text,

     this.attachments,

     this.answers,
  });

  @JsonKey(
    
    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;



  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<int>? attachments;



      /// Answers to the ticket's questions, one per question (the question card)
  @JsonKey(
    
    name: r'answers',
    required: false,
    includeIfNull: false,
  )


  final List<CodeSendAnswersInner>? answers;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CodeSend &&
      other.text == text &&
      other.attachments == attachments &&
      other.answers == answers;

    @override
    int get hashCode =>
        text.hashCode +
        attachments.hashCode +
        answers.hashCode;

  factory CodeSend.fromJson(Map<String, dynamic> json) => _$CodeSendFromJson(json);

  Map<String, dynamic> toJson() => _$CodeSendToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

